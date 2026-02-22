begin;

-- Ensure legacy enum definitions remain available.
do $$
begin
  if not exists (select 1 from pg_type where typname = 'inquiry_type') then
    create type inquiry_type as enum (
      'general',
      'bug',
      'feature',
      'account',
      'technical'
    );
  end if;
end $$;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'inquiry_status') then
    create type inquiry_status as enum (
      'pending',
      'in_progress',
      'resolved',
      'closed'
    );
  end if;
end $$;

-- Ensure table exists with the current enum-based schema.
do $$
begin
  if not exists (
    select 1
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public'
       and c.relname = 'service_inquiries'
       and c.relkind = 'r'
  ) then
    create table public.service_inquiries (
      id uuid primary key default gen_random_uuid(),
      user_id uuid references auth.users(id) on delete cascade,
      inquiry_type inquiry_type not null default 'general',
      status inquiry_status not null default 'pending',
      title text not null,
      content text not null,
      email text not null,
      attachments text[],
      admin_response text,
      admin_user_id uuid references auth.users(id),
      personal_info_consent boolean not null default false,
      created_at timestamptz not null default now(),
      updated_at timestamptz not null default now(),
      resolved_at timestamptz
    );
  end if;
end $$;

alter table public.service_inquiries
  alter column user_id drop not null;

alter table public.service_inquiries
  add column if not exists personal_info_consent boolean not null default false;

alter table public.service_inquiries
  drop column if exists phone;

create index if not exists idx_service_inquiries_user_id_created_at_desc
  on public.service_inquiries (user_id, created_at desc);

create index if not exists idx_service_inquiries_status_created_at_desc
  on public.service_inquiries (status, created_at desc);

alter table public.service_inquiries enable row level security;

drop policy if exists "사용자는 자신의 문의만 조회할 수 있음" on public.service_inquiries;
drop policy if exists "사용자는 문의를 생성할 수 있음" on public.service_inquiries;
drop policy if exists "사용자는 대기중인 자신의 문의만 수정할 수 있음" on public.service_inquiries;
drop policy if exists "사용자는 대기중인 자신의 문의만 삭제할 수 있음" on public.service_inquiries;
drop policy if exists "users_read_own_service_inquiries" on public.service_inquiries;
drop policy if exists "users_create_own_service_inquiries" on public.service_inquiries;
drop policy if exists "guests_create_service_inquiries" on public.service_inquiries;

create policy "users_read_own_service_inquiries"
  on public.service_inquiries
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "users_create_own_service_inquiries"
  on public.service_inquiries
  for insert
  to authenticated
  with check (
    (select auth.uid()) = user_id
    and nullif(btrim(email), '') is not null
  );

create policy "guests_create_service_inquiries"
  on public.service_inquiries
  for insert
  to anon
  with check (
    user_id is null
    and nullif(btrim(email), '') is not null
    and personal_info_consent = true
  );

create or replace function public.update_service_inquiries_updated_at_column()
returns trigger
set search_path = public
language plpgsql
as $$
begin
  new.updated_at = now();

  if new.status in ('resolved', 'closed')
     and old.status not in ('resolved', 'closed') then
    new.resolved_at = now();
  end if;

  return new;
end;
$$;

drop trigger if exists service_inquiries_updated_at on public.service_inquiries;
drop trigger if exists update_service_inquiries_updated_at on public.service_inquiries;

create trigger service_inquiries_updated_at
  before update on public.service_inquiries
  for each row
  execute function public.update_service_inquiries_updated_at_column();

commit;
