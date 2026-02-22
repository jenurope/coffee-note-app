begin;

alter table public.community_comments
  add column if not exists is_deleted_content boolean not null default false;

drop policy if exists "users_soft_delete_own_comments"
  on public.community_comments;

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

commit;
