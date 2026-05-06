-- SmartNOC / NOC Verse schema
-- Run this in the Supabase SQL editor or as a migration.

create extension if not exists pgcrypto;

create or replace function public.is_officer()
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from public.profiles p
    where p.id = auth.uid()
      and p.role = 'officer'
  );
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text unique not null,
  role text not null check (role in ('user', 'officer')),
  created_at timestamptz not null default now()
);

create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  description text not null,
  category text not null,
  location text not null,
  priority text not null check (priority in ('High', 'Medium', 'Low')),
  status text not null check (status in ('Pending', 'Under Review', 'Approved', 'Declined', 'On Hold')),
  image_url text,
  remarks text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger applications_set_updated_at
before update on public.applications
for each row
execute function public.set_updated_at();

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  application_id uuid not null references public.applications(id) on delete cascade,
  title text not null,
  message text not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.applications enable row level security;
alter table public.notifications enable row level security;

create policy "profiles_select_own_or_officer"
  on public.profiles
  for select
  using (auth.uid() = id or public.is_officer());

create policy "profiles_insert_own"
  on public.profiles
  for insert
  with check (auth.uid() = id);

create policy "profiles_update_own_or_officer"
  on public.profiles
  for update
  using (auth.uid() = id or public.is_officer())
  with check (auth.uid() = id or public.is_officer());

create policy "applications_select_own_or_officer"
  on public.applications
  for select
  using (auth.uid() = user_id or public.is_officer());

create policy "applications_insert_own"
  on public.applications
  for insert
  with check (auth.uid() = user_id);

create policy "applications_update_own_or_officer"
  on public.applications
  for update
  using (auth.uid() = user_id or public.is_officer())
  with check (auth.uid() = user_id or public.is_officer());

create policy "applications_delete_own_or_officer"
  on public.applications
  for delete
  using (auth.uid() = user_id or public.is_officer());

create policy "notifications_select_own"
  on public.notifications
  for select
  using (auth.uid() = user_id);

create policy "notifications_update_own"
  on public.notifications
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "notifications_insert_officer"
  on public.notifications
  for insert
  with check (public.is_officer());

insert into storage.buckets (id, name, public)
values ('application-documents', 'application-documents', true)
on conflict (id) do update
set name = excluded.name,
    public = excluded.public;

create policy "application_documents_upload_own"
  on storage.objects
  for insert
  with check (
    bucket_id = 'application-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "application_documents_update_own"
  on storage.objects
  for update
  using (
    bucket_id = 'application-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  )
  with check (
    bucket_id = 'application-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "application_documents_delete_own"
  on storage.objects
  for delete
  using (
    bucket_id = 'application-documents'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
