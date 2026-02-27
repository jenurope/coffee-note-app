begin;

create table if not exists public.bean_recipes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  name text not null,
  brew_method text not null,
  recipe text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bean_recipes_brew_method_check
    check (
      brew_method in (
        'espresso','pour_over','french_press','moka_pot',
        'aeropress','cold_brew','siphon','turkish','other'
      )
    ),
  constraint bean_recipes_user_id_fkey
    foreign key (user_id)
    references auth.users(id)
    on delete cascade
);

create index if not exists idx_bean_recipes_user_id_created_at_desc
  on public.bean_recipes(user_id, created_at desc);

alter table public.bean_recipes enable row level security;

drop policy if exists "사용자는 자신의 레시피만 조회할 수 있음" on public.bean_recipes;
drop policy if exists "사용자는 자신의 레시피만 생성할 수 있음" on public.bean_recipes;
drop policy if exists "사용자는 자신의 레시피만 수정할 수 있음" on public.bean_recipes;
drop policy if exists "사용자는 자신의 레시피만 삭제할 수 있음" on public.bean_recipes;

create policy "사용자는 자신의 레시피만 조회할 수 있음"
  on public.bean_recipes
  for select
  to public
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 레시피만 생성할 수 있음"
  on public.bean_recipes
  for insert
  to public
  with check ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 레시피만 수정할 수 있음"
  on public.bean_recipes
  for update
  to public
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 레시피만 삭제할 수 있음"
  on public.bean_recipes
  for delete
  to public
  using ((select auth.uid() as uid) = user_id);

drop trigger if exists bean_recipes_updated_at on public.bean_recipes;
create trigger bean_recipes_updated_at
before update on public.bean_recipes
for each row
execute function public.update_updated_at_column();

grant all privileges on table public.bean_recipes to anon, authenticated, service_role;

commit;
