-- ROOM +962 production hardening.
-- Apply after 001_room962_admin.sql, 002_auth_flow.sql, and 003_verified_applicant_flow.sql.
-- Purpose:
-- 1) verified-email-only applications
-- 2) real queued transactional emails
-- 3) admin review notifications
-- 4) event capacity enforcement
-- 5) member-only RSVP writes

create extension if not exists pgcrypto;

-- Profiles are linked to Supabase Auth users.
create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  role text not null check (role in ('applicant','member','admin')) default 'applicant',
  full_name text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table profiles enable row level security;

create or replace function public.is_room962_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
      and p.is_active = true
  );
$$;

create or replace function public.is_room962_member()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role in ('member','admin')
      and p.is_active = true
  );
$$;

create or replace function public.is_email_confirmed(_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = auth, public
as $$
  select exists (
    select 1
    from auth.users u
    where u.id = _user_id
      and u.email_confirmed_at is not null
  );
$$;


create or replace function public.auth_user_email(_user_id uuid)
returns text
language sql
stable
security definer
set search_path = auth, public
as $$
  select lower(u.email)
  from auth.users u
  where u.id = _user_id;
$$;

-- Create an applicant profile when Supabase Auth creates the user.
create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, role)
  values (new.id, lower(new.email), 'applicant')
  on conflict (id) do update
    set email = excluded.email,
        updated_at = now();
  return new;
end;
$$;

drop trigger if exists on_auth_user_created_room962_profile on auth.users;
create trigger on_auth_user_created_room962_profile
after insert on auth.users
for each row execute function public.handle_new_auth_user();

-- Policies.
drop policy if exists "Users can read own profile" on profiles;
create policy "Users can read own profile"
  on profiles for select
  using (id = auth.uid());

drop policy if exists "Admins can read all profiles" on profiles;
create policy "Admins can read all profiles"
  on profiles for select
  using (public.is_room962_admin());

-- Application ownership and verification.
alter table applications
  add column if not exists applicant_user_id uuid references auth.users(id),
  add column if not exists applicant_email text,
  add column if not exists confirmation_email_sent_at timestamptz,
  add column if not exists admin_review_email_sent_at timestamptz,
  add column if not exists decision_email_sent_at timestamptz,
  add column if not exists reviewed_at timestamptz,
  add column if not exists review_note text;

alter table applications enable row level security;

drop policy if exists "Verified applicants can create their application" on applications;
create policy "Verified applicants can create their application"
  on applications for insert
  with check (
    applicant_user_id = auth.uid()
    and public.is_email_confirmed(auth.uid())
    and lower(applicant_email) = public.auth_user_email(auth.uid())
  );

drop policy if exists "Applicants can read own application" on applications;
create policy "Applicants can read own application"
  on applications for select
  using (applicant_user_id = auth.uid());

drop policy if exists "Admins can review applications" on applications;
create policy "Admins can review applications"
  on applications for select
  using (public.is_room962_admin());

drop policy if exists "Admins can update applications" on applications;
create policy "Admins can update applications"
  on applications for update
  using (public.is_room962_admin())
  with check (public.is_room962_admin());

-- Notification queue supports Resend/Postmark/etc.
create table if not exists notification_deliveries (
  id uuid primary key default gen_random_uuid(),
  recipient_type text not null check (recipient_type in ('admin','member','applicant')),
  recipient_email text,
  recipient_fcm_token text,
  channel text not null check (channel in ('email','push')),
  template_key text,
  payload jsonb not null default '{}'::jsonb,
  status text not null check (status in ('queued','sent','failed')) default 'queued',
  provider_message_id text,
  error_message text,
  attempts integer not null default 0,
  created_at timestamptz not null default now(),
  sent_at timestamptz
);

alter table notification_deliveries
  add column if not exists template_key text,
  add column if not exists payload jsonb not null default '{}'::jsonb,
  add column if not exists attempts integer not null default 0;

alter table notification_deliveries enable row level security;

drop policy if exists "Admins can read notification deliveries" on notification_deliveries;
create policy "Admins can read notification deliveries"
  on notification_deliveries for select
  using (public.is_room962_admin());

-- Queue applicant and admin emails when an application is submitted.
create or replace function public.queue_application_submitted_notifications()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  applicant_email text;
begin
  applicant_email := lower(new.applicant_email);

  insert into public.notification_deliveries (
    recipient_type,
    recipient_email,
    channel,
    template_key,
    payload
  ) values (
    'applicant',
    applicant_email,
    'email',
    'application_received',
    jsonb_build_object(
      'full_name', new.full_name,
      'review_window', '5 business days'
    )
  );

  insert into public.notification_deliveries (
    recipient_type,
    recipient_email,
    channel,
    template_key,
    payload
  )
  select
    'admin',
    p.email,
    'email',
    'admin_new_application',
    jsonb_build_object(
      'applicant_name', new.full_name,
      'applicant_email', applicant_email
    )
  from public.profiles p
  where p.role = 'admin'
    and p.is_active = true;

  insert into public.admin_notifications (title, body, source_type, source_id, channel, target)
  values (
    'New application',
    coalesce(new.full_name, 'An applicant') || ' completed the questionnaire.',
    'application',
    new.id,
    'email_push',
    'active_admins'
  );

  update public.applications
  set confirmation_email_sent_at = now(),
      admin_review_email_sent_at = now()
  where id = new.id;

  return new;
end;
$$;

drop trigger if exists on_application_insert_queue_received_emails on applications;
drop trigger if exists on_application_insert_queue_admin_notification on applications;
drop trigger if exists on_application_submitted_queue_production_notifications on applications;
create trigger on_application_submitted_queue_production_notifications
after insert on applications
for each row execute function public.queue_application_submitted_notifications();

-- Queue applicant decision email when status changes.
create or replace function public.queue_application_decision_notification()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  applicant_email text;
  template text;
begin
  if new.status in ('accepted', 'declined') and old.status is distinct from new.status then
    applicant_email := lower(new.applicant_email);
    template := case when new.status = 'accepted' then 'application_accepted' else 'application_declined' end;

    insert into public.notification_deliveries (
      recipient_type,
      recipient_email,
      channel,
      template_key,
      payload
    ) values (
      'applicant',
      applicant_email,
      'email',
      template,
      jsonb_build_object(
        'full_name', new.full_name,
        'status', new.status
      )
    );

    new.decision_email_sent_at := now();
    new.reviewed_at := coalesce(new.reviewed_at, now());
  end if;

  return new;
end;
$$;

drop trigger if exists on_application_decision_queue_email on applications;
drop trigger if exists on_application_decision_queue_production_email on applications;
create trigger on_application_decision_queue_production_email
before update of status on applications
for each row execute function public.queue_application_decision_notification();

-- Events must have capacity and cannot be overbooked.
alter table events
  alter column capacity set not null;

alter table events
  drop constraint if exists events_capacity_positive;
alter table events
  add constraint events_capacity_positive check (capacity > 0);

alter table rsvps enable row level security;

drop policy if exists "Members can RSVP for themselves" on rsvps;
create policy "Members can RSVP for themselves"
  on rsvps for insert
  with check (
    public.is_room962_member()
    and exists (
      select 1
      from members m
      where m.id = member_id
        and m.supabase_user_id = auth.uid()
        and m.status = 'active'
    )
  );

drop policy if exists "Members can update own RSVP" on rsvps;
create policy "Members can update own RSVP"
  on rsvps for update
  using (
    exists (
      select 1
      from members m
      where m.id = member_id
        and m.supabase_user_id = auth.uid()
        and m.status = 'active'
    )
  )
  with check (
    exists (
      select 1
      from members m
      where m.id = member_id
        and m.supabase_user_id = auth.uid()
        and m.status = 'active'
    )
  );

create or replace function public.prevent_event_over_capacity()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  event_capacity integer;
  attending_count integer;
begin
  if new.status <> 'attending' then
    return new;
  end if;

  select capacity into event_capacity
  from public.events
  where id = new.event_id;

  if event_capacity is null then
    raise exception 'event_capacity_missing';
  end if;

  select count(*) into attending_count
  from public.rsvps r
  where r.event_id = new.event_id
    and r.status = 'attending'
    and (tg_op = 'INSERT' or r.id <> new.id);

  if attending_count >= event_capacity then
    raise exception 'gathering_full';
  end if;

  return new;
end;
$$;

drop trigger if exists on_rsvp_prevent_over_capacity on rsvps;
create trigger on_rsvp_prevent_over_capacity
before insert or update of status on rsvps
for each row execute function public.prevent_event_over_capacity();

-- Queue member email when a published event goes live.
create or replace function public.queue_event_published_notifications()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.is_published = true
     and coalesce(new.notify_members_on_publish, true) = true
     and (tg_op = 'INSERT' or old.is_published is distinct from true) then
    insert into public.notification_deliveries (
      recipient_type,
      recipient_email,
      channel,
      template_key,
      payload
    )
    select
      'member',
      m.email,
      'email',
      'event_published',
      jsonb_build_object(
        'event_title', new.title,
        'event_date', new.event_date,
        'capacity', new.capacity
      )
    from public.members m
    where m.status = 'active'
      and (
        coalesce(new.visible_to_all_members, true) = true
        or exists (
          select 1
          from public.event_visibility_members evm
          where evm.event_id = new.id
            and evm.member_id = m.id
        )
      );
  end if;

  return new;
end;
$$;

drop trigger if exists on_event_publish_queue_member_notifications on events;
create trigger on_event_publish_queue_member_notifications
after insert or update of is_published on events
for each row execute function public.queue_event_published_notifications();
