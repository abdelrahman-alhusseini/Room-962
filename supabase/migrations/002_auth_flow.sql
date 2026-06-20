-- ROOM +962 auth-flow update.
-- This migration supports the revised product decision:
-- anyone can open the app and apply; accepted members and admins sign in.

create table if not exists profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  role text check (role in ('applicant','member','admin')) not null default 'applicant',
  full_name text,
  is_active boolean default true,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table profiles enable row level security;

drop policy if exists "Users can read own profile" on profiles;
create policy "Users can read own profile"
  on profiles for select
  using (id = auth.uid());

drop policy if exists "Admins can read all profiles" on profiles;
create policy "Admins can read all profiles"
  on profiles for select
  using (exists (
    select 1 from profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
      and p.is_active = true
  ));

alter table applications
  alter column code_used drop not null;

alter table applications
  add column if not exists applicant_user_id uuid references auth.users(id),
  add column if not exists password_invite_sent_at timestamptz;

-- In the new flow, application inserts can be public through a controlled
-- Edge Function or a carefully scoped insert policy. Prefer Edge Functions
-- in production to avoid exposing write rules from the client.

drop policy if exists "Admins can review applications" on applications;
create policy "Admins can review applications"
  on applications for select
  using (exists (
    select 1 from profiles p
    where p.id = auth.uid()
      and p.role = 'admin'
      and p.is_active = true
  ));
