alter table public.profiles
  add column if not exists is_bean_records_enabled boolean not null default true,
  add column if not exists is_coffee_records_enabled boolean not null default true;
