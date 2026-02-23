-- 개발 프로젝트(csfsencsdhfmhgaezhno) 전용 최종 통합 SQL
-- 목적: prod(jbfcltrhniuwxswatyqg)와 동일한 public/storage 구성을 한 번에 재현
-- 실행 권장 Role: postgres
--
-- 구성:
--   1) public 스키마/정책/함수/트리거/권한/시드
--   2) storage buckets
--   3) storage.objects 정책
--   4) 검증 쿼리

begin;

-- auth.users 트리거는 public.handle_new_user 함수에 의존하므로 재생성 전 제거
-- (dev 전용 환경에서만 실행)
drop trigger if exists on_auth_user_created on auth.users;

-- 뷰/테이블/타입 초기화 (재실행 가능)
drop view if exists public.community_posts_with_comment_count;
drop view if exists public.profile_public;

drop table if exists public.user_terms_consents cascade;
drop table if exists public.terms_contents cascade;
drop table if exists public.terms_catalog cascade;
drop table if exists public.service_inquiries cascade;
drop table if exists public.community_comments cascade;
drop table if exists public.community_posts cascade;
drop table if exists public.coffee_logs cascade;
drop table if exists public.coffee_beans cascade;
drop table if exists public.profiles cascade;
drop table if exists public.withdraw_storage_cleanup_failures cascade;

drop type if exists public.inquiry_customer_type cascade;
drop type if exists public.inquiry_status cascade;
drop type if exists public.inquiry_type cascade;

-- ===== 타입 =====
create type public.inquiry_type as enum (
  'general',
  'bug',
  'feature',
  'account',
  'technical'
);

create type public.inquiry_status as enum (
  'pending',
  'in_progress',
  'resolved',
  'closed'
);

create type public.inquiry_customer_type as enum (
  'member',
  'guest',
  'withdrawn'
);

-- ===== 테이블 =====
create table public.profiles (
  id uuid primary key,
  nickname text not null,
  email text not null,
  created_at timestamptz not null default timezone('utc'::text, now()),
  updated_at timestamptz not null default timezone('utc'::text, now()),
  avatar_url text,
  is_withdrawn boolean not null default false,
  withdrawn_at timestamptz,
  constraint profiles_nickname_format_check
    check (
      nickname is not null
      and btrim(nickname) <> ''
      and char_length(btrim(nickname)) between 2 and 20
    )
);

create table public.coffee_beans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  name text not null,
  roastery text not null,
  purchase_date date not null,
  rating numeric not null,
  tasting_notes text,
  roast_level text,
  price integer,
  purchase_location text,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint coffee_beans_rating_check check (rating >= 0 and rating <= 5),
  constraint coffee_beans_roast_level_check
    check (
      roast_level is null
      or roast_level in ('light','medium_light','medium','medium_dark','dark')
    ),
  constraint coffee_beans_user_id_fkey
    foreign key (user_id)
    references auth.users(id)
    on delete cascade
);

create table public.coffee_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  cafe_visit_date date not null,
  coffee_type text not null,
  coffee_name text,
  cafe_name text not null,
  rating numeric not null,
  notes text,
  image_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint coffee_logs_rating_check check (rating >= 0 and rating <= 5),
  constraint coffee_logs_coffee_type_check
    check (
      coffee_type in (
        'espresso','americano','latte','cappuccino','mocha',
        'macchiato','flat_white','cold_brew','affogato','other'
      )
    ),
  constraint coffee_logs_user_id_fkey
    foreign key (user_id)
    references auth.users(id)
    on delete cascade
);

create table public.community_posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  title text not null,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  is_withdrawn_content boolean not null default false,
  constraint community_posts_user_id_fkey
    foreign key (user_id)
    references public.profiles(id)
    on delete cascade
);

create table public.community_comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null,
  user_id uuid not null,
  content text not null,
  parent_id uuid,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  is_withdrawn_content boolean not null default false,
  is_deleted_content boolean not null default false,
  constraint community_comments_post_id_fkey
    foreign key (post_id)
    references public.community_posts(id)
    on delete cascade,
  constraint community_comments_user_id_fkey
    foreign key (user_id)
    references public.profiles(id)
    on delete cascade,
  constraint community_comments_parent_id_fkey
    foreign key (parent_id)
    references public.community_comments(id)
    on delete cascade
);

create table public.terms_catalog (
  code text primary key,
  is_required boolean not null,
  is_active boolean not null default true,
  current_version integer not null check (current_version > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.terms_contents (
  term_code text not null,
  version integer not null check (version > 0),
  locale text not null,
  title text not null,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (term_code, version, locale),
  constraint terms_contents_locale_check
    check (locale in ('ko', 'en', 'ja')),
  constraint terms_contents_term_code_fkey
    foreign key (term_code)
    references public.terms_catalog(code)
    on delete cascade
);

create table public.user_terms_consents (
  user_id uuid not null,
  term_code text not null,
  version integer not null check (version > 0),
  agreed boolean not null,
  agreed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, term_code, version),
  constraint user_terms_consents_term_code_fkey
    foreign key (term_code)
    references public.terms_catalog(code)
    on delete cascade
);

create table public.withdraw_storage_cleanup_failures (
  id bigserial primary key,
  user_id uuid not null,
  bucket text not null,
  object_prefix text not null,
  error_message text not null,
  created_at timestamptz not null default now()
);

create table public.service_inquiries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  inquiry_type public.inquiry_type not null default 'general',
  status public.inquiry_status not null default 'pending',
  title text not null,
  content text not null,
  email text not null,
  attachments text[],
  admin_user_id uuid references auth.users(id),
  admin_response text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz,
  personal_info_consent boolean not null default false,
  customer_type public.inquiry_customer_type not null default 'guest',
  constraint service_inquiries_user_id_fkey
    foreign key (user_id)
    references auth.users(id)
    on delete set null
);

-- prod의 물리 컬럼 순서(attnum)와 동일하게 맞추기 위한 레거시 드롭 이력 반영
alter table public.service_inquiries
  drop column if exists attachments,
  drop column if exists admin_user_id,
  drop column if exists phone;

-- ===== 인덱스 =====
create index idx_coffee_beans_user_id
  on public.coffee_beans(user_id);

create index idx_coffee_logs_user_id
  on public.coffee_logs(user_id);

create index idx_coffee_logs_cafe_visit_date
  on public.coffee_logs(cafe_visit_date);

create index idx_community_posts_user_id
  on public.community_posts(user_id);

create index idx_community_posts_created_at
  on public.community_posts(created_at desc);

create index idx_community_posts_user_created
  on public.community_posts(user_id, created_at desc);

create index community_posts_user_id_created_at_idx
  on public.community_posts(user_id, created_at desc);

create index idx_community_comments_post_id
  on public.community_comments(post_id);

create index idx_community_comments_user_id
  on public.community_comments(user_id);

create index idx_community_comments_parent_id
  on public.community_comments(parent_id);

create index idx_community_comments_created_at
  on public.community_comments(created_at);

create index community_comments_user_id_created_at_idx
  on public.community_comments(user_id, created_at desc);

create unique index profiles_nickname_unique_active_normalized_idx
  on public.profiles((lower(btrim(nickname))))
  where is_withdrawn = false;

create index idx_service_inquiries_user_id_created_at_desc
  on public.service_inquiries(user_id, created_at desc);

create index idx_service_inquiries_status_created_at_desc
  on public.service_inquiries(status, created_at desc);

create index terms_catalog_is_active_required_idx
  on public.terms_catalog(is_active, is_required, sort_order);

create index terms_contents_lookup_idx
  on public.terms_contents(term_code, locale, version);

create index user_terms_consents_user_id_idx
  on public.user_terms_consents(user_id);

create index withdraw_storage_cleanup_failures_user_id_idx
  on public.withdraw_storage_cleanup_failures(user_id);

-- ===== RLS 활성화 =====
alter table public.coffee_beans enable row level security;
alter table public.coffee_logs enable row level security;
alter table public.community_comments enable row level security;
alter table public.community_posts enable row level security;
alter table public.profiles enable row level security;
alter table public.service_inquiries enable row level security;
alter table public.terms_catalog enable row level security;
alter table public.terms_contents enable row level security;
alter table public.user_terms_consents enable row level security;
alter table public.withdraw_storage_cleanup_failures enable row level security;

-- ===== 정책 =====
-- coffee_beans
drop policy if exists "사용자는 자신의 커피 원두만 조회할 수 있음" on public.coffee_beans;
drop policy if exists "사용자는 자신의 커피 원두만 생성할 수 있음" on public.coffee_beans;
drop policy if exists "사용자는 자신의 커피 원두만 수정할 수 있음" on public.coffee_beans;
drop policy if exists "사용자는 자신의 커피 원두만 삭제할 수 있음" on public.coffee_beans;

create policy "사용자는 자신의 커피 원두만 조회할 수 있음"
  on public.coffee_beans
  for select
  to public
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 커피 원두만 생성할 수 있음"
  on public.coffee_beans
  for insert
  to public
  with check ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 커피 원두만 수정할 수 있음"
  on public.coffee_beans
  for update
  to public
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 커피 원두만 삭제할 수 있음"
  on public.coffee_beans
  for delete
  to public
  using ((select auth.uid() as uid) = user_id);

-- coffee_logs
drop policy if exists "사용자는 자신의 커피 기록만 조회할 수 있음" on public.coffee_logs;
drop policy if exists "사용자는 자신의 커피 기록만 생성할 수 있음" on public.coffee_logs;
drop policy if exists "사용자는 자신의 커피 기록만 수정할 수 있음" on public.coffee_logs;
drop policy if exists "사용자는 자신의 커피 기록만 삭제할 수 있음" on public.coffee_logs;

create policy "사용자는 자신의 커피 기록만 조회할 수 있음"
  on public.coffee_logs
  for select
  to public
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 커피 기록만 생성할 수 있음"
  on public.coffee_logs
  for insert
  to public
  with check ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 커피 기록만 수정할 수 있음"
  on public.coffee_logs
  for update
  to public
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 커피 기록만 삭제할 수 있음"
  on public.coffee_logs
  for delete
  to public
  using ((select auth.uid() as uid) = user_id);

-- community_posts
drop policy if exists "사용자는 게시글을 생성할 수 있음" on public.community_posts;
drop policy if exists "사용자는 자신의 게시글만 수정할 수 있음" on public.community_posts;
drop policy if exists "사용자는 자신의 게시글만 삭제할 수 있음" on public.community_posts;
drop policy if exists "인증된 사용자는 모든 게시글을 조회할 수 있음" on public.community_posts;

create policy "사용자는 게시글을 생성할 수 있음"
  on public.community_posts
  for insert
  to authenticated
  with check ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 게시글만 수정할 수 있음"
  on public.community_posts
  for update
  to authenticated
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 게시글만 삭제할 수 있음"
  on public.community_posts
  for delete
  to authenticated
  using ((select auth.uid() as uid) = user_id);

create policy "인증된 사용자는 모든 게시글을 조회할 수 있음"
  on public.community_posts
  for select
  to authenticated
  using (true);

-- community_comments
drop policy if exists "사용자는 댓글을 생성할 수 있음" on public.community_comments;
drop policy if exists "사용자는 자신의 댓글만 수정할 수 있음" on public.community_comments;
drop policy if exists "사용자는 자신의 댓글만 삭제할 수 있음" on public.community_comments;
drop policy if exists "인증된 사용자는 모든 댓글을 조회할 수 있음" on public.community_comments;
drop policy if exists "users_soft_delete_own_comments" on public.community_comments;

create policy "사용자는 댓글을 생성할 수 있음"
  on public.community_comments
  for insert
  to authenticated
  with check ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 댓글만 수정할 수 있음"
  on public.community_comments
  for update
  to authenticated
  using ((select auth.uid() as uid) = user_id);

create policy "사용자는 자신의 댓글만 삭제할 수 있음"
  on public.community_comments
  for delete
  to authenticated
  using ((select auth.uid() as uid) = user_id);

create policy "인증된 사용자는 모든 댓글을 조회할 수 있음"
  on public.community_comments
  for select
  to authenticated
  using ((select auth.uid() as uid) is not null);

create policy "users_soft_delete_own_comments"
  on public.community_comments
  for update
  to authenticated
  using (
    user_id = auth.uid()
    and is_deleted_content = false
  )
  with check (
    user_id = auth.uid()
    and is_deleted_content = true
    and content = '[deleted_comment]'
  );

-- profiles
drop policy if exists "profiles_select_authenticated" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;

create policy "profiles_select_authenticated"
  on public.profiles
  for select
  to authenticated
  using (true);

create policy "profiles_insert_own"
  on public.profiles
  for insert
  to authenticated
  with check (id = auth.uid());

create policy "profiles_update_own"
  on public.profiles
  for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- terms
drop policy if exists "authenticated_read_terms_catalog" on public.terms_catalog;
drop policy if exists "authenticated_read_terms_contents" on public.terms_contents;
drop policy if exists "users_read_own_terms_consents" on public.user_terms_consents;
drop policy if exists "users_insert_own_terms_consents" on public.user_terms_consents;
drop policy if exists "users_update_own_terms_consents" on public.user_terms_consents;

create policy "authenticated_read_terms_catalog"
  on public.terms_catalog
  for select
  to authenticated
  using (true);

create policy "authenticated_read_terms_contents"
  on public.terms_contents
  for select
  to authenticated
  using (true);

create policy "users_read_own_terms_consents"
  on public.user_terms_consents
  for select
  to authenticated
  using (auth.uid() = user_id);

create policy "users_insert_own_terms_consents"
  on public.user_terms_consents
  for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "users_update_own_terms_consents"
  on public.user_terms_consents
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- service inquiries
drop policy if exists "users_read_own_service_inquiries" on public.service_inquiries;
drop policy if exists "users_create_own_service_inquiries" on public.service_inquiries;
drop policy if exists "guests_create_service_inquiries" on public.service_inquiries;

create policy "users_read_own_service_inquiries"
  on public.service_inquiries
  for select
  to authenticated
  using ((select auth.uid() as uid) = user_id);

create policy "users_create_own_service_inquiries"
  on public.service_inquiries
  for insert
  to authenticated
  with check (
    (select auth.uid() as uid) = user_id
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

-- ===== 함수 =====
create or replace function public.update_updated_at_column()
returns trigger
set search_path = public
language plpgsql
as $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

create or replace function public.update_updated_at()
returns trigger
set search_path = public
language plpgsql
as $$
BEGIN
    NEW.updated_at = now();

    -- 상태가 resolved나 closed로 변경되면 resolved_at 설정 (service_inquiries용)
    IF TG_TABLE_NAME = 'service_inquiries' AND
       NEW.status IN ('resolved', 'closed') AND
       OLD.status NOT IN ('resolved', 'closed') THEN
        NEW.resolved_at = now();
    END IF;

    RETURN NEW;
END;
$$;

create or replace function public.update_coffee_beans_updated_at_column()
returns trigger
set search_path = public
language plpgsql
as $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

create or replace function public.update_coffee_logs_updated_at_column()
returns trigger
set search_path = public
language plpgsql
as $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$;

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

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

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
  v_nickname text;
begin
  v_email := coalesce(new.email, '');

  v_nickname := nullif(
    trim(
      coalesce(
        new.raw_user_meta_data->>'nickname',
        new.raw_user_meta_data->>'name',
        new.raw_user_meta_data->>'full_name',
        split_part(v_email, '@', 1),
        ''
      )
    ),
    ''
  );

  if v_nickname is null then
    v_nickname := 'user_' || left(new.id::text, 8);
  end if;

  insert into public.profiles (id, nickname, email)
  values (new.id, v_nickname, v_email)
  on conflict (id) do update
  set nickname = excluded.nickname,
      email = excluded.email,
      updated_at = timezone('utc', now());

  return new;
end;
$$;

create or replace function public.is_admin(user_uuid uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
BEGIN
    -- 특정 이메일을 관리자로 간주 (향후 별도 관리자 테이블로 확장 가능)
    RETURN EXISTS (
        SELECT 1 FROM auth.users
        WHERE id = user_uuid
        AND email IN ('admin@coffeenote.com', 'support@coffeenote.com')
    );
END;
$$;

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

-- ===== 함수 실행 권한 =====
revoke all on function public.is_admin(uuid) from public, anon, authenticated, service_role;
grant execute on function public.is_admin(uuid) to service_role;
revoke all on function public.log_withdraw_storage_cleanup_failure(text, text, text) from public;
revoke all on function public.withdraw_my_account() from public;

grant execute on function public.community_hourly_write_limits(uuid) to anon, authenticated, service_role;
grant execute on function public.enforce_community_comment_hourly_limit() to anon, authenticated, service_role;
grant execute on function public.enforce_community_post_hourly_limit() to anon, authenticated, service_role;
grant execute on function public.handle_new_user() to anon, authenticated, service_role;
grant execute on function public.handle_updated_at() to anon, authenticated, service_role;
grant execute on function public.log_withdraw_storage_cleanup_failure(text, text, text) to anon, authenticated, service_role;
grant execute on function public.set_service_inquiry_customer_type() to anon, authenticated, service_role;
grant execute on function public.update_coffee_beans_updated_at_column() to anon, authenticated, service_role;
grant execute on function public.update_coffee_logs_updated_at_column() to anon, authenticated, service_role;
grant execute on function public.update_service_inquiries_updated_at_column() to anon, authenticated, service_role;
grant execute on function public.update_updated_at() to anon, authenticated, service_role;
grant execute on function public.update_updated_at_column() to anon, authenticated, service_role;
grant execute on function public.withdraw_my_account() to anon, authenticated, service_role;

-- ===== 트리거 =====
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();

create trigger coffee_beans_updated_at
before update on public.coffee_beans
for each row
execute function public.update_updated_at_column();

create trigger coffee_logs_updated_at
before update on public.coffee_logs
for each row
execute function public.update_updated_at_column();

create trigger community_posts_hourly_limit_trigger
before insert on public.community_posts
for each row
execute function public.enforce_community_post_hourly_limit();

create trigger community_comments_hourly_limit_trigger
before insert on public.community_comments
for each row
execute function public.enforce_community_comment_hourly_limit();

create trigger community_posts_updated_at
before update on public.community_posts
for each row
execute function public.update_updated_at_column();

create trigger on_community_posts_update
before update on public.community_posts
for each row
execute function public.handle_updated_at();

create trigger update_community_comments_updated_at
before update on public.community_comments
for each row
execute function public.update_updated_at_column();

create trigger on_community_comments_update
before update on public.community_comments
for each row
execute function public.handle_updated_at();

create trigger profiles_updated_at
before update on public.profiles
for each row
execute function public.update_updated_at_column();

create trigger service_inquiries_set_customer_type
before insert or update of user_id, customer_type on public.service_inquiries
for each row
execute function public.set_service_inquiry_customer_type();

create trigger service_inquiries_updated_at
before update on public.service_inquiries
for each row
execute function public.update_service_inquiries_updated_at_column();

-- ===== 뷰 =====
create view public.profile_public
with (security_invoker = true)
as
select id, nickname
from public.profiles;

create view public.community_posts_with_comment_count
with (security_invoker = true)
as
select
  cp.id,
  cp.user_id,
  cp.title,
  cp.content,
  cp.created_at,
  cp.updated_at,
  pp.nickname as author_nickname,
  coalesce(cc.comment_count, 0::bigint) as comment_count
from public.community_posts cp
left join public.profile_public pp
  on cp.user_id = pp.id
left join (
  select post_id, count(*) as comment_count
  from public.community_comments
  group by post_id
) cc
  on cp.id = cc.post_id;

-- ===== 권한 =====
-- prod relacl 기준으로 맞춤
revoke all on table public.profiles from anon;
revoke all on table public.profiles from authenticated;
grant select, insert, update on table public.profiles to authenticated;
grant all privileges on table public.profiles to service_role;

grant all privileges on table public.coffee_beans to anon, authenticated, service_role;
grant all privileges on table public.coffee_logs to anon, authenticated, service_role;
grant all privileges on table public.community_posts to anon, authenticated, service_role;
grant all privileges on table public.community_comments to anon, authenticated, service_role;
grant all privileges on table public.service_inquiries to anon, authenticated, service_role;
grant all privileges on table public.terms_catalog to anon, authenticated, service_role;
grant all privileges on table public.terms_contents to anon, authenticated, service_role;
grant all privileges on table public.user_terms_consents to anon, authenticated, service_role;

revoke all on table public.withdraw_storage_cleanup_failures from anon, authenticated;
grant all privileges on table public.withdraw_storage_cleanup_failures to service_role;

grant usage, select, update on sequence public.withdraw_storage_cleanup_failures_id_seq
  to anon, authenticated, service_role;

grant all privileges on table public.profile_public to anon, authenticated, service_role;
grant all privileges on table public.community_posts_with_comment_count to anon, authenticated, service_role;

-- ===== 약관 시드 데이터 =====
insert into public.terms_catalog (code, is_required, is_active, current_version, sort_order)
values
  ('test_policy', false, true, 1, 0),
  ('service_terms', true, true, 1, 10),
  ('privacy_policy', true, true, 1, 20)
on conflict (code) do update
set is_required = excluded.is_required,
    is_active = excluded.is_active,
    current_version = excluded.current_version,
    sort_order = excluded.sort_order,
    updated_at = now();

insert into public.terms_contents (term_code, version, locale, title, content)
values
  (
    'service_terms',
    1,
    'ko',
    '서비스 이용약관',
    '본 약관은 커피로그 서비스 이용에 필요한 기본 조건을 안내합니다.\n\n1. 목적\n- 커피 기록, 원두 기록, 커뮤니티 기능을 안전하게 제공하기 위한 기준을 정합니다.\n\n2. 이용자 책임\n- 이용자는 법령 및 본 약관을 준수해야 하며, 타인의 권리를 침해하는 게시물 등록이 금지됩니다.\n\n3. 계정 및 보안\n- 계정은 본인만 사용해야 하며, 부정 사용이 의심되면 즉시 서비스 운영자에게 알려야 합니다.\n\n4. 게시물 운영\n- 커뮤니티 운영 정책 및 관련 법령 위반 게시물은 노출 제한 또는 삭제될 수 있습니다.\n\n5. 서비스 변경\n- 기능 개선을 위해 서비스 일부가 변경될 수 있으며, 중요한 변경은 사전에 고지합니다.'
  ),
  (
    'service_terms',
    1,
    'en',
    'Terms of Service',
    'These terms define the baseline rules for using Coffee Log.\n\n1. Purpose\n- We provide coffee logs, bean logs, and community features under safe operation standards.\n\n2. User Responsibility\n- Users must follow applicable laws and these terms, and must not post content that infringes others rights.\n\n3. Account Security\n- Accounts are for personal use only. If unauthorized access is suspected, users must report it promptly.\n\n4. Community Moderation\n- Content violating policy or law may be restricted or removed.\n\n5. Service Changes\n- Features may change for improvement, and major changes will be announced in advance.'
  ),
  (
    'service_terms',
    1,
    'ja',
    'サービス利用規約',
    '本規約はコーヒーログの利用に必要な基本条件を定めます。\n\n1. 目的\n- コーヒー記録、豆記録、コミュニティ機能を安全に提供するための基準を示します。\n\n2. 利用者の責任\n- 利用者は法令および本規約を遵守し、他者の権利を侵害する投稿をしてはなりません。\n\n3. アカウント保護\n- アカウントは本人のみが利用し、不正利用の疑いがある場合は速やかに連絡してください。\n\n4. 投稿管理\n- 規約または法令に違反する投稿は制限または削除されることがあります。\n\n5. サービス変更\n- 機能改善のためサービス内容が変更される場合があり、重要な変更は事前に告知します。'
  ),
  (
    'privacy_policy',
    1,
    'ko',
    '개인정보 처리 동의',
    '커피로그는 서비스 제공을 위해 최소한의 개인정보를 처리합니다.\n\n1. 수집 항목\n- 로그인 계정 식별값, 이메일, 프로필 닉네임/이미지\n- 이용자가 직접 입력한 커피 기록, 원두 기록, 커뮤니티 게시물\n\n2. 이용 목적\n- 회원 식별, 기록 저장/동기화, 커뮤니티 운영, 서비스 품질 개선\n\n3. 보관 및 삭제\n- 회원 탈퇴 시 정책에 따라 개인정보를 삭제 또는 비식별 처리합니다.\n\n4. 제3자 제공\n- 법령상 의무가 있는 경우를 제외하고 동의 없이 제3자에게 제공하지 않습니다.\n\n5. 이용자 권리\n- 이용자는 개인정보 열람, 정정, 삭제 요청을 할 수 있습니다.'
  ),
  (
    'privacy_policy',
    1,
    'en',
    'Privacy Policy Consent',
    'Coffee Log processes only the minimum personal data required to operate the service.\n\n1. Data Collected\n- Account identifier, email, and profile nickname/avatar\n- Coffee logs, bean logs, and community content entered by users\n\n2. Purpose of Use\n- User identification, data storage/sync, community operation, and service quality improvement\n\n3. Retention and Deletion\n- Upon account withdrawal, personal data is deleted or de-identified under policy.\n\n4. Third-Party Sharing\n- Data is not shared with third parties without consent except where legally required.\n\n5. User Rights\n- Users may request access, correction, or deletion of their personal data.'
  ),
  (
    'privacy_policy',
    1,
    'ja',
    '個人情報取扱い同意',
    'コーヒーログはサービス提供に必要な最小限の個人情報を取り扱います。\n\n1. 取得項目\n- ログイン識別子、メールアドレス、プロフィール情報\n- 利用者が入力したコーヒー記録、豆記録、コミュニティ投稿\n\n2. 利用目的\n- 会員識別、データ保存・同期、コミュニティ運営、品質改善\n\n3. 保管と削除\n- 退会時には方針に従って個人情報を削除または匿名化します。\n\n4. 第三者提供\n- 法令上必要な場合を除き、同意なく第三者提供しません。\n\n5. 利用者の権利\n- 利用者は個人情報の閲覧、訂正、削除を要求できます。'
  ),
  (
    'test_policy',
    1,
    'ko',
    '테스트 선택 약관',
    '테스트 선택 약관'
  )
on conflict (term_code, version, locale) do update
set title = excluded.title,
    content = excluded.content,
    updated_at = now();

-- prod와 동일한 본문 포맷 정렬:
-- 대부분은 실제 개행 문자로 저장, privacy_policy/en의 "Purpose of Use" 구간은
-- 현재 prod 데이터와 동일하게 백슬래시+n 한 번을 유지
update public.terms_contents
   set content = replace(content, '\\n', E'\n'),
       updated_at = now()
 where position('\\n' in content) > 0;

update public.terms_contents
   set content = replace(
         content,
         E'2. Purpose of Use\n- ',
         '2. Purpose of Use\\n- '
       ),
       updated_at = now()
 where term_code = 'privacy_policy'
   and version = 1
   and locale = 'en';

commit;

-- =====================================================================
-- 2) storage buckets
-- =====================================================================

-- 개발 프로젝트(csfsencsdhfmhgaezhno) 전용
-- 목적: prod와 동일한 storage 버킷 생성/동기화
-- 실행 권장 Role: postgres

begin;

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values
  (
    'avatars',
    'avatars',
    true,
    1048576,
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
  ),
  (
    'beans',
    'beans',
    false,
    1048576,
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
  ),
  (
    'community',
    'community',
    true,
    1048576,
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
  ),
  (
    'logs',
    'logs',
    false,
    1048576,
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
  )
on conflict (id) do update
set
  name = excluded.name,
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

commit;

-- =====================================================================
-- 3) storage.objects policies
-- =====================================================================

-- 개발 프로젝트(csfsencsdhfmhgaezhno) 전용
-- 목적: prod와 동일한 storage.objects 정책 적용
-- 주의: storage.objects owner 권한이 필요하며,
--       권한이 없으면 `ERROR: must be owner of table objects`가 발생할 수 있음

begin;

drop policy if exists "public_read_media_buckets" on storage.objects;
drop policy if exists "authenticated_read_private_media_buckets" on storage.objects;
drop policy if exists "authenticated_upload_media_buckets" on storage.objects;
drop policy if exists "authenticated_update_media_buckets" on storage.objects;
drop policy if exists "authenticated_delete_media_buckets" on storage.objects;
drop policy if exists "avatars_public_read" on storage.objects;
drop policy if exists "avatars_auth_insert_own_folder" on storage.objects;
drop policy if exists "avatars_auth_update_own_folder" on storage.objects;
drop policy if exists "avatars_auth_delete_own_folder" on storage.objects;

create policy "public_read_media_buckets"
on storage.objects
for select
to public
using (bucket_id in ('avatars', 'community'));

create policy "authenticated_read_private_media_buckets"
on storage.objects
for select
to authenticated
using (
  bucket_id in ('beans', 'logs')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "authenticated_upload_media_buckets"
on storage.objects
for insert
to authenticated
with check (
  bucket_id in ('beans', 'logs', 'avatars', 'community')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "authenticated_update_media_buckets"
on storage.objects
for update
to authenticated
using (
  bucket_id in ('beans', 'logs', 'avatars', 'community')
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id in ('beans', 'logs', 'avatars', 'community')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "authenticated_delete_media_buckets"
on storage.objects
for delete
to authenticated
using (
  bucket_id in ('beans', 'logs', 'avatars', 'community')
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- prod에 존재하는 avatars 전용 정책도 동일하게 추가
create policy "avatars_public_read"
on storage.objects
for select
to public
using (bucket_id = 'avatars');

create policy "avatars_auth_insert_own_folder"
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "avatars_auth_update_own_folder"
on storage.objects
for update
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "avatars_auth_delete_own_folder"
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

commit;

-- =====================================================================
-- 4) verify
-- =====================================================================

-- dev 부트스트랩 확인용

select table_name
from information_schema.tables
where table_schema='public'
order by table_name;

select schemaname, tablename, policyname, cmd
from pg_policies
where schemaname in ('public', 'storage')
order by schemaname, tablename, policyname;

select
  c.relname as view_name,
  c.reloptions
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind = 'v'
  and c.relname in ('profile_public', 'community_posts_with_comment_count')
order by c.relname;

select id, public, file_size_limit, allowed_mime_types
from storage.buckets
where id in ('avatars', 'beans', 'community', 'logs')
order by id;

select
  event_object_schema as table_schema,
  event_object_table as table_name,
  trigger_name,
  action_timing,
  event_manipulation
from information_schema.triggers
where event_object_schema in ('public', 'auth')
order by event_object_schema, event_object_table, trigger_name;
