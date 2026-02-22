begin;

create table if not exists public.terms_catalog (
  code text primary key,
  is_required boolean not null,
  is_active boolean not null default true,
  current_version integer not null check (current_version > 0),
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.terms_contents (
  term_code text not null references public.terms_catalog(code) on delete cascade,
  version integer not null check (version > 0),
  locale text not null,
  title text not null,
  content text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (term_code, version, locale),
  constraint terms_contents_locale_check check (locale in ('ko', 'en', 'ja'))
);

create table if not exists public.user_terms_consents (
  user_id uuid not null,
  term_code text not null references public.terms_catalog(code) on delete cascade,
  version integer not null check (version > 0),
  agreed boolean not null,
  agreed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, term_code, version)
);

create index if not exists terms_catalog_is_active_required_idx
  on public.terms_catalog (is_active, is_required, sort_order);

create index if not exists terms_contents_lookup_idx
  on public.terms_contents (term_code, locale, version);

create index if not exists user_terms_consents_user_id_idx
  on public.user_terms_consents (user_id);

alter table public.terms_catalog enable row level security;
alter table public.terms_contents enable row level security;
alter table public.user_terms_consents enable row level security;

drop policy if exists "authenticated_read_terms_catalog" on public.terms_catalog;
create policy "authenticated_read_terms_catalog"
  on public.terms_catalog
  for select
  to authenticated
  using (true);

drop policy if exists "authenticated_read_terms_contents" on public.terms_contents;
create policy "authenticated_read_terms_contents"
  on public.terms_contents
  for select
  to authenticated
  using (true);

drop policy if exists "users_read_own_terms_consents" on public.user_terms_consents;
create policy "users_read_own_terms_consents"
  on public.user_terms_consents
  for select
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "users_insert_own_terms_consents" on public.user_terms_consents;
create policy "users_insert_own_terms_consents"
  on public.user_terms_consents
  for insert
  to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "users_update_own_terms_consents" on public.user_terms_consents;
create policy "users_update_own_terms_consents"
  on public.user_terms_consents
  for update
  to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

insert into public.terms_catalog (code, is_required, is_active, current_version, sort_order)
values
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
  )
on conflict (term_code, version, locale) do update
set title = excluded.title,
    content = excluded.content,
    updated_at = now();

commit;
