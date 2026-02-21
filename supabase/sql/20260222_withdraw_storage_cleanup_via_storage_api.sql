begin;

create or replace function public.log_withdraw_storage_cleanup_failure(
  p_bucket text,
  p_object_prefix text,
  p_error_message text
)
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

  insert into public.withdraw_storage_cleanup_failures (
    user_id,
    bucket,
    object_prefix,
    error_message
  )
  values (
    v_user_id,
    p_bucket,
    p_object_prefix,
    left(coalesce(p_error_message, 'unknown error'), 500)
  );
end;
$$;

revoke all on function public.log_withdraw_storage_cleanup_failure(text, text, text) from public;
grant execute on function public.log_withdraw_storage_cleanup_failure(text, text, text) to authenticated;

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
