begin;

alter table public.profiles
  add column if not exists is_withdrawn boolean not null default false,
  add column if not exists withdrawn_at timestamptz;

alter table public.community_posts
  add column if not exists is_withdrawn_content boolean not null default false;

alter table public.community_comments
  add column if not exists is_withdrawn_content boolean not null default false;

drop index if exists public.profiles_nickname_unique_normalized_idx;
drop index if exists public.profiles_nickname_unique_active_normalized_idx;

create unique index if not exists profiles_nickname_unique_active_normalized_idx
  on public.profiles ((lower(btrim(nickname))))
  where is_withdrawn = false;

do $$
declare
  fk record;
begin
  for fk in
    select c.conname
    from pg_constraint c
    join pg_class t on t.oid = c.conrelid
    join pg_namespace n on n.oid = t.relnamespace
    where c.contype = 'f'
      and n.nspname = 'public'
      and t.relname = 'profiles'
      and c.confrelid = 'auth.users'::regclass
  loop
    execute format(
      'alter table public.profiles drop constraint if exists %I',
      fk.conname
    );
  end loop;
end;
$$;

create table if not exists public.withdraw_storage_cleanup_failures (
  id bigserial primary key,
  user_id uuid not null,
  bucket text not null,
  object_prefix text not null,
  error_message text not null,
  created_at timestamptz not null default now()
);

create index if not exists withdraw_storage_cleanup_failures_user_id_idx
  on public.withdraw_storage_cleanup_failures (user_id);

create or replace function public.withdraw_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth, storage, pg_temp
as $$
declare
  v_user_id uuid := auth.uid();
  v_bucket text;
  v_buckets text[] := array['beans', 'logs', 'avatars', 'community'];
  v_object_prefix text;
begin
  if v_user_id is null then
    raise exception using
      errcode = 'P0001',
      message = 'withdraw_auth_required',
      hint = 'Authentication is required to withdraw account.';
  end if;

  perform pg_advisory_xact_lock(hashtext('withdraw_account:' || v_user_id::text));

  delete from public.coffee_logs
   where user_id = v_user_id;

  delete from public.coffee_beans
   where user_id = v_user_id;

  update public.community_posts
     set title = '[withdrawn_post]',
         content = '[withdrawn_post_content]',
         is_withdrawn_content = true,
         updated_at = now()
   where user_id = v_user_id;

  update public.community_comments
     set content = '[withdrawn_comment]',
         is_withdrawn_content = true,
         updated_at = now()
   where user_id = v_user_id;

  update public.profiles
     set nickname = 'withdrawn-user',
         email = 'withdrawn+' || v_user_id::text || '@example.invalid',
         avatar_url = null,
         is_withdrawn = true,
         withdrawn_at = now(),
         updated_at = now()
   where id = v_user_id;

  delete from auth.users
   where id = v_user_id;

  if not found then
    raise exception using
      errcode = 'P0001',
      message = 'withdraw_user_not_found',
      hint = 'Authenticated user no longer exists.';
  end if;

  v_object_prefix := v_user_id::text || '/';

  foreach v_bucket in array v_buckets
  loop
    begin
      delete from storage.objects
       where bucket_id = v_bucket
         and name like v_object_prefix || '%';
    exception
      when others then
        insert into public.withdraw_storage_cleanup_failures (
          user_id,
          bucket,
          object_prefix,
          error_message
        )
        values (
          v_user_id,
          v_bucket,
          v_object_prefix,
          left(sqlerrm, 500)
        );
    end;
  end loop;
end;
$$;

revoke all on function public.withdraw_my_account() from public;
grant execute on function public.withdraw_my_account() to authenticated;

commit;
