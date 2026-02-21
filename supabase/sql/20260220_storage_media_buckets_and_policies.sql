begin;

-- 앱 업로드 경로는 "<user_id>/<timestamp>.<ext>" 형식을 사용합니다.
-- 버킷/정책을 환경 간 동일하게 유지하기 위해 idempotent하게 적용합니다.
insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values
  (
    'beans',
    'beans',
    false,
    1048576,
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
  ),
  (
    'logs',
    'logs',
    false,
    1048576,
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
  ),
  (
    'avatars',
    'avatars',
    true,
    1048576,
    array['image/jpeg', 'image/png', 'image/webp', 'image/gif']::text[]
  )
on conflict (id) do update
set
  name = excluded.name,
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

-- storage.objects는 Supabase 관리 테이블이며,
-- RLS 설정 변경(alter table ... enable row level security)은
-- 소유자 권한이 필요하므로 여기서는 수행하지 않습니다.

drop policy if exists "public_read_media_buckets" on storage.objects;
drop policy if exists "authenticated_read_private_media_buckets" on storage.objects;
drop policy if exists "authenticated_upload_media_buckets" on storage.objects;
drop policy if exists "authenticated_update_media_buckets" on storage.objects;
drop policy if exists "authenticated_delete_media_buckets" on storage.objects;

create policy "public_read_media_buckets"
on storage.objects
for select
to public
using (bucket_id in ('avatars'));

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
  bucket_id in ('beans', 'logs', 'avatars')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "authenticated_update_media_buckets"
on storage.objects
for update
to authenticated
using (
  bucket_id in ('beans', 'logs', 'avatars')
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id in ('beans', 'logs', 'avatars')
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "authenticated_delete_media_buckets"
on storage.objects
for delete
to authenticated
using (
  bucket_id in ('beans', 'logs', 'avatars')
  and (storage.foldername(name))[1] = auth.uid()::text
);

commit;
