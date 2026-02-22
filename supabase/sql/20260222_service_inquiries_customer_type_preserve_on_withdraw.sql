begin;

do $$
begin
  if not exists (
    select 1
      from pg_type t
      join pg_namespace n on n.oid = t.typnamespace
     where t.typname = 'inquiry_customer_type'
       and n.nspname = 'public'
  ) then
    create type public.inquiry_customer_type as enum (
      'member',
      'guest',
      'withdrawn'
    );
  end if;
end $$;

alter table public.service_inquiries
  add column if not exists customer_type public.inquiry_customer_type;

update public.service_inquiries
   set customer_type = case
     when user_id is null then 'guest'::public.inquiry_customer_type
     else 'member'::public.inquiry_customer_type
   end
 where customer_type is null;

alter table public.service_inquiries
  alter column customer_type set default 'guest'::public.inquiry_customer_type;

alter table public.service_inquiries
  alter column customer_type set not null;

alter table public.service_inquiries
  drop constraint if exists service_inquiries_user_id_fkey;

alter table public.service_inquiries
  add constraint service_inquiries_user_id_fkey
  foreign key (user_id)
  references auth.users (id)
  on delete set null;

create or replace function public.set_service_inquiry_customer_type()
returns trigger
set search_path = public
language plpgsql
as $$
begin
  if new.user_id is not null then
    new.customer_type = 'member'::public.inquiry_customer_type;
  else
    if tg_op = 'UPDATE' and old.user_id is not null then
      new.customer_type = 'withdrawn'::public.inquiry_customer_type;
    else
      new.customer_type = 'guest'::public.inquiry_customer_type;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists service_inquiries_set_customer_type on public.service_inquiries;

create trigger service_inquiries_set_customer_type
  before insert or update of user_id, customer_type
  on public.service_inquiries
  for each row
  execute function public.set_service_inquiry_customer_type();

create or replace function public.withdraw_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  v_user_id uuid := auth.uid();
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

  update public.service_inquiries
     set user_id = null,
         customer_type = 'withdrawn'::public.inquiry_customer_type,
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
end;
$$;

revoke all on function public.withdraw_my_account() from public;
grant execute on function public.withdraw_my_account() to authenticated;

commit;
