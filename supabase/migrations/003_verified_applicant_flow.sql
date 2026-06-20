-- ROOM +962 verified applicant flow.
-- New production rule: an applicant creates an account first, verifies their
-- email, then completes the questionnaire. Admin decision emails are automated.

create extension if not exists pgcrypto;

create table if not exists applicant_accounts (
  id uuid primary key default gen_random_uuid(),
  supabase_user_id uuid unique references auth.users(id) on delete cascade,
  email text not null unique,
  email_verified boolean not null default false,
  verification_sent_at timestamptz,
  verified_at timestamptz,
  created_at timestamptz default now()
);

alter table applicant_accounts enable row level security;

drop policy if exists "Applicants can read own applicant account" on applicant_accounts;
create policy "Applicants can read own applicant account"
  on applicant_accounts for select
  using (supabase_user_id = auth.uid());

alter table applications
  add column if not exists applicant_account_id uuid references applicant_accounts(id),
  add column if not exists confirmation_email_sent_at timestamptz,
  add column if not exists admin_review_email_sent_at timestamptz,
  add column if not exists decision_email_sent_at timestamptz;

alter table events
  alter column capacity set not null;

alter table events
  add constraint events_capacity_positive check (capacity > 0);

create or replace function queue_application_received_emails()
returns trigger
language plpgsql
security definer
as $$
begin
  insert into notification_deliveries (
    recipient_type,
    recipient_email,
    channel,
    status
  ) values (
    'applicant',
    new.applicant_email,
    'email',
    'queued'
  );

  insert into admin_notifications (title, body, source_type, source_id, channel, target)
  values (
    'New application',
    coalesce(new.full_name, 'An applicant') || ' applied. Open the app to review.',
    'application',
    new.id,
    'email_push',
    'active_admins'
  );

  return new;
end;
$$;

drop trigger if exists on_application_insert_queue_received_emails on applications;
create trigger on_application_insert_queue_received_emails
after insert on applications
for each row execute function queue_application_received_emails();

create or replace function queue_application_decision_email()
returns trigger
language plpgsql
security definer
as $$
begin
  if new.status in ('accepted', 'declined') and old.status is distinct from new.status then
    insert into notification_deliveries (
      recipient_type,
      recipient_email,
      channel,
      status
    ) values (
      'applicant',
      new.applicant_email,
      'email',
      'queued'
    );
  end if;

  return new;
end;
$$;

drop trigger if exists on_application_decision_queue_email on applications;
create trigger on_application_decision_queue_email
after update of status on applications
for each row execute function queue_application_decision_email();
