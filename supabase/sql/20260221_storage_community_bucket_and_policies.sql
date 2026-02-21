begin;

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'community',
  'community',
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

drop policy if exists "public_read_media_buckets" on storage.objects;
drop policy if exists "authenticated_upload_media_buckets" on storage.objects;
drop policy if exists "authenticated_update_media_buckets" on storage.objects;
drop policy if exists "authenticated_delete_media_buckets" on storage.objects;

create policy "public_read_media_buckets"
on storage.objects
for select
to public
using (bucket_id in ('beans', 'logs', 'avatars', 'community'));

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

commit;
