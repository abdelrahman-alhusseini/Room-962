-- ROOM +962 production schema extension for in-app admin, event visibility,
-- and admin/applicant/member notification delivery.
-- Run after enabling pgcrypto in Supabase.

create extension if not exists pgcrypto;

create table if not exists admin_users (
  id uuid primary key default gen_random_uuid(),
  supabase_user_id uuid references auth.users(id),
  full_name text not null,
  email text not null unique,
  role text check (role in ('owner','committee','operations')) default 'committee',
  is_active boolean default true,
  wants_email_notifications boolean default true,
  wants_push_notifications boolean default true,
  fcm_token text,
  created_at timestamptz default now()
);

alter table applications
  add column if not exists applicant_email text,
  add column if not exists reviewed_at timestamptz,
  add column if not exists reviewed_by uuid references admin_users(id),
  add column if not exists review_note text;

alter table events
  add column if not exists visible_to_all_members boolean default true,
  add column if not exists show_guest_count boolean default true,
  add column if not exists notify_members_on_publish boolean default true,
  add column if not exists created_by uuid references admin_users(id),
  add column if not exists updated_at timestamptz default now();

create table if not exists event_visibility_members (
  id uuid primary key default gen_random_uuid(),
  event_id uuid references events(id) on delete cascade,
  member_id uuid references members(id) on delete cascade,
  created_at timestamptz default now(),
  unique (event_id, member_id)
);

create table if not exists admin_notifications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  body text not null,
  source_type text check (source_type in ('application','event','announcement','system')) default 'system',
  source_id uuid,
  channel text check (channel in ('email','push','email_push','in_app')) default 'email_push',
  target text,
  delivered boolean default false,
  read_at timestamptz,
  created_at timestamptz default now()
);

create table if not exists notification_deliveries (
  id uuid primary key default gen_random_uuid(),
  notification_id uuid references admin_notifications(id) on delete cascade,
  recipient_type text check (recipient_type in ('admin','member','applicant')) not null,
  recipient_email text,
  recipient_fcm_token text,
  channel text check (channel in ('email','push')) not null,
  status text check (status in ('queued','sent','failed')) default 'queued',
  provider_message_id text,
  error_message text,
  created_at timestamptz default now(),
  sent_at timestamptz
);

alter table admin_users enable row level security;
alter table event_visibility_members enable row level security;
alter table admin_notifications enable row level security;
alter table notification_deliveries enable row level security;

-- Admins can read admin-owned data. Writes should be done through Edge Functions
-- or policies that verify an auth user exists in admin_users.
drop policy if exists "Admins can read admin users" on admin_users;
create policy "Admins can read admin users"
  on admin_users for select
  using (exists (
    select 1 from admin_users current_admin
    where current_admin.supabase_user_id = auth.uid()
      and current_admin.is_active = true
  ));

drop policy if exists "Admins can read notifications" on admin_notifications;
create policy "Admins can read notifications"
  on admin_notifications for select
  using (exists (
    select 1 from admin_users current_admin
    where current_admin.supabase_user_id = auth.uid()
      and current_admin.is_active = true
  ));

drop policy if exists "Members can read visible published events" on events;
create policy "Members can read visible published events"
  on events for select
  using (
    is_published = true
    and (
      visible_to_all_members = true
      or exists (
        select 1
        from members m
        join event_visibility_members evm on evm.member_id = m.id
        where m.supabase_user_id = auth.uid()
          and evm.event_id = events.id
      )
    )
  );

create or replace function queue_admin_application_notification()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into admin_notifications (title, body, source_type, source_id, channel, target)
  values (
    'New application received',
    coalesce(new.full_name, 'An applicant') || ' has completed the Room +962 application.',
    'application',
    new.id,
    'email_push',
    'active_admins'
  );
  return new;
end;
$$;

drop trigger if exists on_application_insert_queue_admin_notification on applications;
create trigger on_application_insert_queue_admin_notification
after insert on applications
for each row execute function queue_admin_application_notification();
