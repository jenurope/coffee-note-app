begin;

create index if not exists community_posts_user_id_created_at_idx
  on public.community_posts (user_id, created_at desc);

create index if not exists community_comments_user_id_created_at_idx
  on public.community_comments (user_id, created_at desc);

create or replace function public.community_hourly_write_limits(p_user_id uuid)
returns table(post_limit integer, comment_limit integer)
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  joined_at timestamptz;
  membership_days integer;
begin
  if p_user_id is null then
    return query select 3, 10;
    return;
  end if;

  select u.created_at
    into joined_at
    from auth.users u
   where u.id = p_user_id;

  if joined_at is null then
    select p.created_at
      into joined_at
      from public.profiles p
     where p.id = p_user_id;
  end if;

  membership_days := greatest(
    0,
    floor(
      extract(epoch from (now() - coalesce(joined_at, now())))
      / 86400
    )::integer
  );

  if membership_days >= 365 then
    return query select 20, 50;
  elsif membership_days >= 30 then
    return query select 10, 30;
  else
    return query select 3, 10;
  end if;
end;
$$;

create or replace function public.enforce_community_post_hourly_limit()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  max_posts integer;
  posts_in_last_hour integer;
begin
  if new.user_id is null then
    return new;
  end if;

  perform pg_advisory_xact_lock(hashtext('community_post_limit:' || new.user_id::text));

  select l.post_limit
    into max_posts
    from public.community_hourly_write_limits(new.user_id) l;

  select count(*)
    into posts_in_last_hour
    from public.community_posts p
   where p.user_id = new.user_id
     and p.created_at >= now() - interval '1 hour';

  if posts_in_last_hour >= max_posts then
    raise exception using
      errcode = 'P0001',
      message = 'community_post_hourly_limit_exceeded',
      detail = format('limit=%s;window=1h', max_posts),
      hint = '시간당 게시글 작성 제한을 초과했습니다. 잠시 후 다시 시도해주세요.';
  end if;

  return new;
end;
$$;

create or replace function public.enforce_community_comment_hourly_limit()
returns trigger
language plpgsql
security definer
set search_path = public, auth, pg_temp
as $$
declare
  max_comments integer;
  comments_in_last_hour integer;
begin
  if new.user_id is null then
    return new;
  end if;

  perform pg_advisory_xact_lock(hashtext('community_comment_limit:' || new.user_id::text));

  select l.comment_limit
    into max_comments
    from public.community_hourly_write_limits(new.user_id) l;

  select count(*)
    into comments_in_last_hour
    from public.community_comments c
   where c.user_id = new.user_id
     and c.created_at >= now() - interval '1 hour';

  if comments_in_last_hour >= max_comments then
    raise exception using
      errcode = 'P0001',
      message = 'community_comment_hourly_limit_exceeded',
      detail = format('limit=%s;window=1h', max_comments),
      hint = '시간당 댓글 작성 제한을 초과했습니다. 잠시 후 다시 시도해주세요.';
  end if;

  return new;
end;
$$;

drop trigger if exists community_posts_hourly_limit_trigger
  on public.community_posts;

create trigger community_posts_hourly_limit_trigger
before insert on public.community_posts
for each row
execute function public.enforce_community_post_hourly_limit();

drop trigger if exists community_comments_hourly_limit_trigger
  on public.community_comments;

create trigger community_comments_hourly_limit_trigger
before insert on public.community_comments
for each row
execute function public.enforce_community_comment_hourly_limit();

commit;
