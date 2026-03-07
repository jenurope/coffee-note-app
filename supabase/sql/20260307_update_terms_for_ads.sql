begin;

insert into public.terms_catalog (code, is_required, is_active, current_version, sort_order)
values
  ('test_policy', false, false, 1, 0),
  ('service_terms', true, true, 2, 10),
  ('privacy_policy', true, true, 2, 20)
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
    2,
    'ko',
    '서비스 이용약관',
    '본 약관은 커피로그 서비스 이용에 필요한 기본 조건을 안내합니다.\n\n1. 서비스 제공 범위\n- 커피 기록, 원두 기록, 커뮤니티, 문의 및 관련 부가 기능을 제공합니다.\n\n2. 계정 및 이용자 책임\n- 계정은 본인만 사용해야 하며, 이용자는 법령, 본 약관, 커뮤니티 운영 기준을 준수해야 합니다.\n- 타인의 권리를 침해하거나 서비스 운영을 방해하는 행위는 금지됩니다.\n\n3. 게시물 및 커뮤니티 운영\n- 게시글, 댓글, 이미지 등 이용자가 등록한 콘텐츠는 서비스 화면에 공개될 수 있습니다.\n- 운영자는 법령 또는 정책 위반 게시물에 대해 노출 제한, 삭제, 이용 제한 조치를 할 수 있습니다.\n\n4. 외부 서비스 및 광고\n- 서비스는 Google, Supabase 등 외부 서비스를 이용할 수 있으며, Android 앱에는 광고가 표시될 수 있습니다.\n- 광고는 개인화 또는 비개인화 형태로 제공될 수 있으며, 관련 개인정보 처리는 개인정보 처리 동의 및 개인정보처리방침을 따릅니다.\n\n5. 서비스 변경 및 중단\n- 운영자는 기능 개선, 점검, 장애 대응, 정책 변경을 위해 서비스 일부를 변경하거나 중단할 수 있으며, 중요한 변경은 사전에 안내합니다.\n\n6. 탈퇴 및 이용 제한\n- 이용자는 언제든지 회원탈퇴를 요청할 수 있습니다.\n- 약관 또는 법령 위반 시 서비스 이용이 제한되거나 계정이 처리될 수 있습니다.'
  ),
  (
    'service_terms',
    2,
    'en',
    'Terms of Service',
    'These terms explain the baseline rules for using Coffee Log.\n\n1. Scope of Service\n- We provide coffee logs, bean logs, community, inquiry, and related service features.\n\n2. Account and User Responsibility\n- Accounts are for personal use only, and users must comply with applicable laws, these terms, and community rules.\n- Users must not infringe the rights of others or interfere with service operations.\n\n3. Community and Content Moderation\n- Posts, comments, and images submitted by users may be displayed within the service.\n- We may restrict, remove, or take action on content that violates law or policy.\n\n4. Third-Party Services and Ads\n- The service may use external services such as Google and Supabase, and ads may be shown in the Android app.\n- Ads may be personalized or non-personalized, and related data processing is governed by the privacy consent and privacy policy.\n\n5. Service Changes and Suspension\n- We may change or suspend part of the service for improvement, maintenance, incident response, or policy changes, and material changes will be announced in advance.\n\n6. Withdrawal and Restrictions\n- Users may request account deletion at any time.\n- Service use may be restricted if these terms or applicable laws are violated.'
  ),
  (
    'service_terms',
    2,
    'ja',
    'サービス利用規約',
    '本規約はコーヒーログの利用に必要な基本条件を定めます。\n\n1. サービス提供範囲\n- コーヒー記録、豆記録、コミュニティ、お問い合わせおよび関連機能を提供します。\n\n2. アカウントおよび利用者の責任\n- アカウントは本人のみが利用し、利用者は法令、本規約、コミュニティ運営基準を遵守しなければなりません。\n- 他者の権利侵害やサービス運営を妨げる行為は禁止されます。\n\n3. 投稿およびコミュニティ運営\n- 投稿、コメント、画像など利用者が登録したコンテンツはサービス内に表示される場合があります。\n- 運営者は法令またはポリシーに違反するコンテンツについて表示制限、削除、利用制限を行うことがあります。\n\n4. 外部サービスおよび広告\n- 本サービスはGoogle、Supabaseなどの外部サービスを利用することがあり、Androidアプリでは広告が表示される場合があります。\n- 広告はパーソナライズドまたは非パーソナライズドの形で提供されることがあり、関連する個人情報処理は個人情報取扱い同意およびプライバシーポリシーに従います。\n\n5. サービス変更および中断\n- 運営者は機能改善、保守、障害対応、ポリシー変更のためにサービスの全部または一部を変更または中断することがあり、重要な変更は事前に案内します。\n\n6. 退会および利用制限\n- 利用者はいつでも退会を申請できます。\n- 本規約または法令に違反した場合、サービス利用が制限されることがあります。'
  ),
  (
    'privacy_policy',
    2,
    'ko',
    '개인정보 처리 동의',
    '커피로그는 서비스 제공 및 운영을 위해 아래와 같이 개인정보를 처리하는 것에 대한 동의를 받습니다.\n\n1. 수집 항목\n- 로그인 계정 식별값, 이메일, 닉네임, 프로필 이미지\n- 이용자가 입력한 커피 기록, 원두 기록, 커뮤니티 게시물 및 댓글, 문의 내용\n- 기기 및 앱 정보, 접속 로그, 오류 로그, 이용 통계, Android 광고 식별자 및 광고 상호작용 정보\n\n2. 이용 목적\n- 회원 식별, 로그인, 프로필 및 기록 관리, 커뮤니티 및 문의 기능 제공\n- 서비스 운영, 품질 개선, 오류 분석, 보안 대응\n- Android 앱 광고 제공, 광고 성과 측정, 개인화 또는 비개인화 광고 처리, 광고 동의 관리\n\n3. 외부 서비스 이용 및 국외 처리\n- 서비스는 Supabase, Google Sign-In, Firebase Analytics/Crashlytics, Google AdMob 및 Google User Messaging Platform을 이용할 수 있습니다.\n- 이 과정에서 개인정보가 해외 서버로 전송되어 처리될 수 있습니다.\n\n4. 보관 및 삭제\n- 개인정보는 회원 탈퇴 또는 처리 목적 달성 시 삭제하거나 관련 정책에 따라 비식별 처리합니다.\n- 법령상 보존 의무가 있는 경우 해당 기간 동안 별도 보관합니다.\n\n5. 이용자 권리\n- 이용자는 개인정보 열람, 정정, 삭제, 처리정지, 동의 철회 및 회원탈퇴를 요청할 수 있습니다.\n- 회원탈퇴 경로는 프로필 > 회원탈퇴이며, 상세 내용은 개인정보처리방침을 따릅니다.'
  ),
  (
    'privacy_policy',
    2,
    'en',
    'Privacy Policy Consent',
    'Coffee Log requests consent to process personal data as described below for service operation.\n\n1. Data Collected\n- Login account identifier, email, nickname, and profile image\n- Coffee logs, bean logs, community posts and comments, and inquiry content entered by users\n- Device and app information, access logs, error logs, usage analytics, Android advertising identifiers, and ad interaction data\n\n2. Purpose of Use\n- User identification, login, profile and record management, and community and inquiry features\n- Service operation, quality improvement, error analysis, and security response\n- Android ad delivery, ad measurement, personalized or non-personalized ad processing, and consent management\n\n3. Third-Party Services and International Processing\n- The service may use Supabase, Google Sign-In, Firebase Analytics and Crashlytics, Google AdMob, and Google User Messaging Platform.\n- Personal data may be transferred to and processed on overseas servers in connection with these services.\n\n4. Retention and Deletion\n- Personal data is deleted or de-identified when account deletion is completed or the processing purpose has been achieved.\n- Where retention is required by law, the data is stored separately for the required period.\n\n5. User Rights\n- Users may request access, correction, deletion, restriction of processing, withdrawal of consent, and account deletion.\n- The in-app account deletion path is Profile > Delete Account. Detailed handling is governed by the privacy policy.'
  ),
  (
    'privacy_policy',
    2,
    'ja',
    '個人情報取扱い同意',
    'コーヒーログはサービス提供および運営のため、以下のとおり個人情報を処理することについて同意を取得します。\n\n1. 取得項目\n- ログイン識別子、メールアドレス、ニックネーム、プロフィール画像\n- 利用者が入力したコーヒー記録、豆記録、コミュニティ投稿・コメント、お問い合わせ内容\n- 端末およびアプリ情報、接続ログ、エラーログ、利用統計、Android広告識別子および広告操作情報\n\n2. 利用目的\n- 会員識別、ログイン、プロフィールおよび記録管理、コミュニティおよびお問い合わせ機能の提供\n- サービス運営、品質改善、障害分析、セキュリティ対応\n- Androidアプリにおける広告配信、広告効果測定、パーソナライズドまたは非パーソナライズド広告処理、同意管理\n\n3. 外部サービス利用および国外処理\n- 本サービスはSupabase、Google Sign-In、Firebase Analytics/Crashlytics、Google AdMob、Google User Messaging Platformを利用する場合があります。\n- これに伴い、個人情報が海外サーバーへ転送され処理されることがあります。\n\n4. 保管および削除\n- 個人情報は退会または処理目的達成時に削除または方針に従って非識別化されます。\n- 法令上保管義務がある場合は、必要期間別途保管します。\n\n5. 利用者の権利\n- 利用者は個人情報の閲覧、訂正、削除、処理停止、同意撤回、退会を請求できます。\n- アプリ内の退会経路はプロフィール > 退会するであり、詳細はプライバシーポリシーに従います。'
  )
on conflict (term_code, version, locale) do update
set title = excluded.title,
    content = excluded.content,
    updated_at = now();

update public.terms_contents
   set content = replace(content, '\\n', E'\n'),
       updated_at = now()
 where position('\\n' in content) > 0
   and term_code in ('service_terms', 'privacy_policy')
   and version = 2;

commit;
