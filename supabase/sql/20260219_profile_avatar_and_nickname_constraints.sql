begin;

alter table public.profiles
  add column if not exists avatar_url text;

update public.profiles
set nickname = btrim(nickname)
where nickname is not null
  and nickname <> btrim(nickname);

do $$
begin
  if exists (
    select 1
    from public.profiles
    where nickname is null
       or btrim(nickname) = ''
       or char_length(btrim(nickname)) < 2
       or char_length(btrim(nickname)) > 20
  ) then
    raise exception
      'profiles.nickname contains invalid values (must be 2-20 chars and not blank)';
  end if;

  if exists (
    select lower(btrim(nickname))
    from public.profiles
    group by lower(btrim(nickname))
    having count(*) > 1
  ) then
    raise exception
      'profiles.nickname contains duplicates (case-insensitive, trimmed)';
  end if;
end
$$;

alter table public.profiles
  drop constraint if exists profiles_nickname_format_check,
  add constraint profiles_nickname_format_check
  check (
    nickname is not null
    and btrim(nickname) <> ''
    and char_length(btrim(nickname)) between 2 and 20
  );

create unique index if not exists profiles_nickname_unique_normalized_idx
  on public.profiles ((lower(btrim(nickname))));

commit;
