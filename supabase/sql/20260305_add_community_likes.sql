create table if not exists public.community_post_likes (
  post_id uuid not null,
  user_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id),
  constraint community_post_likes_post_id_fkey
    foreign key (post_id)
    references public.community_posts(id)
    on delete cascade,
  constraint community_post_likes_user_id_fkey
    foreign key (user_id)
    references public.profiles(id)
    on delete cascade
);

create table if not exists public.community_comment_likes (
  comment_id uuid not null,
  user_id uuid not null,
  created_at timestamptz not null default now(),
  primary key (comment_id, user_id),
  constraint community_comment_likes_comment_id_fkey
    foreign key (comment_id)
    references public.community_comments(id)
    on delete cascade,
  constraint community_comment_likes_user_id_fkey
    foreign key (user_id)
    references public.profiles(id)
    on delete cascade
);

create index if not exists idx_community_post_likes_post_id
  on public.community_post_likes(post_id);
create index if not exists idx_community_post_likes_user_id
  on public.community_post_likes(user_id);

create index if not exists idx_community_comment_likes_comment_id
  on public.community_comment_likes(comment_id);
create index if not exists idx_community_comment_likes_user_id
  on public.community_comment_likes(user_id);

alter table public.community_post_likes enable row level security;
alter table public.community_comment_likes enable row level security;

drop policy if exists "인증 사용자는 게시글 좋아요를 조회할 수 있음"
  on public.community_post_likes;
drop policy if exists "사용자는 게시글 좋아요를 생성할 수 있음"
  on public.community_post_likes;
drop policy if exists "사용자는 자신의 게시글 좋아요만 취소할 수 있음"
  on public.community_post_likes;

create policy "인증 사용자는 게시글 좋아요를 조회할 수 있음"
  on public.community_post_likes
  for select
  to authenticated
  using (true);

create policy "사용자는 게시글 좋아요를 생성할 수 있음"
  on public.community_post_likes
  for insert
  to authenticated
  with check (
    auth.uid() = user_id
    and exists (
      select 1
      from public.community_posts cp
      where cp.id = post_id
        and cp.user_id <> auth.uid()
        and cp.is_deleted_content = false
        and cp.is_withdrawn_content = false
    )
  );

create policy "사용자는 자신의 게시글 좋아요만 취소할 수 있음"
  on public.community_post_likes
  for delete
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "인증 사용자는 댓글 좋아요를 조회할 수 있음"
  on public.community_comment_likes;
drop policy if exists "사용자는 댓글 좋아요를 생성할 수 있음"
  on public.community_comment_likes;
drop policy if exists "사용자는 자신의 댓글 좋아요만 취소할 수 있음"
  on public.community_comment_likes;

create policy "인증 사용자는 댓글 좋아요를 조회할 수 있음"
  on public.community_comment_likes
  for select
  to authenticated
  using (true);

create policy "사용자는 댓글 좋아요를 생성할 수 있음"
  on public.community_comment_likes
  for insert
  to authenticated
  with check (
    auth.uid() = user_id
    and exists (
      select 1
      from public.community_comments cc
      where cc.id = comment_id
        and cc.user_id <> auth.uid()
        and cc.is_deleted_content = false
        and cc.is_withdrawn_content = false
    )
  );

create policy "사용자는 자신의 댓글 좋아요만 취소할 수 있음"
  on public.community_comment_likes
  for delete
  to authenticated
  using (auth.uid() = user_id);

grant all privileges on table public.community_post_likes
  to anon, authenticated, service_role;
grant all privileges on table public.community_comment_likes
  to anon, authenticated, service_role;
