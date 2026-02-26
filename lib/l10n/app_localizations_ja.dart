// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'コーヒーログ';

  @override
  String get appInitFailedTitle => 'アプリの初期化に失敗しました。';

  @override
  String get appExit => 'アプリを終了';

  @override
  String get appStartUnavailable => 'アプリを起動できません。しばらくしてから再試行してください。';

  @override
  String get pageNotFound => 'ページが見つかりません';

  @override
  String get backToHome => 'ホームへ戻る';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get beanRecords => '豆の記録';

  @override
  String get coffeeRecords => 'コーヒー記録';

  @override
  String get community => 'コミュニティ';

  @override
  String get profile => 'プロフィール';

  @override
  String get login => 'ログイン';

  @override
  String get loginNow => 'ログイン';

  @override
  String get logout => 'ログアウト';

  @override
  String get cancel => 'キャンセル';

  @override
  String get leave => '終了';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get update => '更新';

  @override
  String get register => '登録';

  @override
  String get apply => '適用';

  @override
  String get reset => 'リセット';

  @override
  String get retry => '再試行';

  @override
  String get viewMore => 'もっと見る';

  @override
  String get showAll => 'すべて表示';

  @override
  String get filter => 'フィルター';

  @override
  String get sort => '並び替え';

  @override
  String get minRating => '最低評価';

  @override
  String get searchDefaultHint => '検索...';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String errorOccurredWithMessage(String message) {
    return 'エラーが発生しました\n$message';
  }

  @override
  String get requiredLogin => 'ログインが必要です。';

  @override
  String get guestMode => 'ゲストモード';

  @override
  String get guestBanner => 'ゲストモードです。ログインするとすべての機能を利用できます。';

  @override
  String get orLabel => 'または';

  @override
  String get loginWithGoogle => 'Googleでログイン';

  @override
  String get browseAsGuest => 'ゲストとして利用';

  @override
  String get loginTagline => 'あなたのコーヒー体験を記録しましょう';

  @override
  String get termsConsentTitle => '規約同意';

  @override
  String get termsConsentSubtitle => 'サービス利用のため、以下の規約内容を確認して同意してください。';

  @override
  String get termsRequiredHint => '必須規約にすべて同意すると続行できます。';

  @override
  String get termsRequiredLabel => '必須';

  @override
  String get termsOptionalLabel => '任意';

  @override
  String get termsAgreeAndContinue => '同意して続行';

  @override
  String get termsDeclineAndLogout => '同意せずに終了';

  @override
  String get termsEmpty => '表示できる規約がありません。しばらくしてから再試行してください。';

  @override
  String get loginFailedGeneric => 'ログイン中にエラーが発生しました。';

  @override
  String get notificationsPreparing => '通知機能は準備中です。';

  @override
  String helloUser(String name) {
    return 'こんにちは、$nameさん！ ☕';
  }

  @override
  String get defaultCoffeeLover => 'コーヒーラバー';

  @override
  String get dashboardSubtitle => '今日も香り高い一杯はいかがですか？';

  @override
  String countBeans(int count) {
    return '$count件';
  }

  @override
  String countLogs(int count) {
    return '$count件';
  }

  @override
  String get recordBean => '豆を記録';

  @override
  String get recordCoffee => 'コーヒーを記録';

  @override
  String get recentBeanRecords => '最近の豆記録';

  @override
  String get recentCoffeeRecords => '最近のコーヒー記録';

  @override
  String get noBeanRecordsYet => 'まだ豆の記録がありません';

  @override
  String get noCoffeeRecordsYet => 'まだコーヒー記録がありません';

  @override
  String get firstBeanRecord => '最初の豆を記録';

  @override
  String get firstCoffeeRecord => '最初のコーヒーを記録';

  @override
  String get beansScreenTitle => '豆の記録';

  @override
  String get beansSearchHint => '豆名・ロースタリーを検索...';

  @override
  String get beansEmptyTitle => '登録された豆がありません';

  @override
  String get beansEmptySubtitleAuth => '最初の豆を記録してみましょう！';

  @override
  String get beansEmptySubtitleGuest => 'ログインすると豆を記録できます。';

  @override
  String get beansRecordButton => '豆を記録';

  @override
  String get sortNewest => '新しい順';

  @override
  String get sortByRating => '評価順';

  @override
  String get sortByName => '名前順';

  @override
  String get roastLevel => '焙煎レベル';

  @override
  String ratingAtLeast(double rating) {
    return '$rating以上';
  }

  @override
  String get beanFormNewTitle => '新しい豆記録';

  @override
  String get beanFormEditTitle => '豆を編集';

  @override
  String get beanPhoto => '豆の写真';

  @override
  String get beanNameLabel => '豆の名前 *';

  @override
  String get beanNameHint => '例: エチオピア イルガチェフェ';

  @override
  String get beanNameRequired => '豆の名前を入力してください';

  @override
  String get roasteryLabel => 'ロースタリー *';

  @override
  String get roasteryHint => '例: Coffee Libre';

  @override
  String get roasteryRequired => 'ロースタリーを入力してください';

  @override
  String get purchaseDate => '購入日';

  @override
  String get rating => '評価';

  @override
  String get price => '価格';

  @override
  String get priceHint => 'ウォン';

  @override
  String get purchaseLocation => '購入先';

  @override
  String get purchaseLocationHint => '例: 公式サイト';

  @override
  String get tastingNotes => 'テイスティングノート';

  @override
  String get tastingNotesHint => 'この豆の味を説明してください...';

  @override
  String get saveAsNew => '登録';

  @override
  String get saveAsEdit => '更新';

  @override
  String get formLeaveConfirmCreate => '作成中の内容が失われます。終了しますか？';

  @override
  String get formLeaveConfirmEdit => '編集した内容が失われます。終了しますか？';

  @override
  String get beanCreated => '豆が登録されました。';

  @override
  String get beanUpdated => '豆が更新されました。';

  @override
  String get beanSaveFailed => '豆の保存中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get beanDeleteTitle => '豆を削除';

  @override
  String get beanDeleteConfirm => 'この豆を削除しますか？関連する抽出記録も削除されます。';

  @override
  String get beanDeleted => '豆が削除されました。';

  @override
  String get beanDeleteFailed => '豆の削除中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get beanInfoPurchaseDate => '購入日';

  @override
  String get beanInfoPrice => '価格';

  @override
  String get beanInfoPurchaseLocation => '購入先';

  @override
  String get beanDetailsSection => '豆の詳細';

  @override
  String varietyLabel(String value) {
    return '品種: $value';
  }

  @override
  String processLabel(String value) {
    return '精製: $value';
  }

  @override
  String get brewHistory => '抽出記録';

  @override
  String recordsCount(int count) {
    return '$count件';
  }

  @override
  String get brewDefaultTitle => '抽出';

  @override
  String get logsScreenTitle => 'コーヒー記録';

  @override
  String get logsSearchHint => 'コーヒー・カフェを検索...';

  @override
  String get logsEmptyTitle => '登録されたコーヒー記録がありません';

  @override
  String get logsEmptySubtitleAuth => '今日飲んだコーヒーを記録しましょう！';

  @override
  String get logsEmptySubtitleGuest => 'ログインするとコーヒーを記録できます。';

  @override
  String get logsRecordButton => 'コーヒーを記録';

  @override
  String get listLoadingMore => '追加項目を読み込み中...';

  @override
  String get logFormNewTitle => '新しいコーヒー記録';

  @override
  String get logFormEditTitle => '記録を編集';

  @override
  String get coffeePhoto => 'コーヒー写真';

  @override
  String get coffeeType => 'コーヒー種類';

  @override
  String get coffeeName => 'コーヒー名';

  @override
  String get coffeeNameHint => '例: シグネチャーラテ';

  @override
  String get cafeName => 'カフェ名 *';

  @override
  String get cafeNameHint => '例: Blue Bottle Seongsu';

  @override
  String get cafeNameRequired => 'カフェ名を入力してください';

  @override
  String get visitDate => '訪問日';

  @override
  String get memo => 'メモ';

  @override
  String get memoHint => 'このコーヒーの感想を書いてください...';

  @override
  String get logCreated => '記録が登録されました。';

  @override
  String get logUpdated => '記録が更新されました。';

  @override
  String get logSaveFailed => '記録の保存中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get logDeleteTitle => '記録を削除';

  @override
  String get logDeleteConfirm => 'このコーヒー記録を削除しますか？';

  @override
  String get logDeleted => '記録が削除されました。';

  @override
  String get logDeleteFailed => '記録の削除中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get communityScreenTitle => 'コミュニティ';

  @override
  String get communityGuestSubtitle => 'ログインすると投稿の閲覧と作成ができます。';

  @override
  String get communityWelcomeSubtitle => '他のコーヒー愛好家と話しましょう';

  @override
  String get postSearchHint => '投稿を検索...';

  @override
  String get postsEmptyTitle => '投稿がありません';

  @override
  String get postsEmptySubtitle => '最初の投稿を書いてみましょう！';

  @override
  String get writePost => '投稿を書く';

  @override
  String get postFormNewTitle => '新しい投稿';

  @override
  String get postFormEditTitle => '投稿を編集';

  @override
  String get postTitle => 'タイトル';

  @override
  String get postTitleHint => 'タイトルを入力してください';

  @override
  String get postTitleRequired => 'タイトルを入力してください';

  @override
  String get postTitleMinLength => 'タイトルは2文字以上で入力してください';

  @override
  String get postTitleMaxLength => 'タイトルは50文字以内で入力してください';

  @override
  String postTitleCount(int count) {
    return 'タイトル $count/50';
  }

  @override
  String get postContent => '内容';

  @override
  String get postContentHint => 'コーヒーについて話してみましょう...';

  @override
  String get postContentRequired => '内容を入力してください';

  @override
  String get postContentMinLength => '内容は2文字以上で入力してください';

  @override
  String get postContentMaxLength => '内容は500文字以内で入力してください';

  @override
  String postContentCount(int count) {
    return '内容 $count/500';
  }

  @override
  String get postImageInsert => '画像を挿入';

  @override
  String get postImageLimitReached => '画像は最大3枚まで添付できます。';

  @override
  String postImageCount(int count) {
    return '画像 $count/3';
  }

  @override
  String get postPreview => 'プレビュー';

  @override
  String get postImageUploadPreparing => '画像をアップロード中です...';

  @override
  String get postCreated => '投稿が登録されました。';

  @override
  String get postUpdated => '投稿が更新されました。';

  @override
  String get postSaveFailed => '投稿の保存中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get postScreenTitle => '投稿';

  @override
  String get commentDetailTitle => 'コメント詳細';

  @override
  String get commentCreated => 'コメントが登録されました。';

  @override
  String get commentHint => 'コメントを入力してください...';

  @override
  String commentsCount(int count) {
    return 'コメント $count';
  }

  @override
  String get commentNone => 'まだコメントがありません。\n最初のコメントを残してみましょう！';

  @override
  String get commentDeleteFailed => 'コメント削除中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get commentCreateFailed => 'コメント登録中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get replyAction => '返信';

  @override
  String get replyHint => '返信を入力してください...';

  @override
  String get replyCancel => '返信をキャンセル';

  @override
  String get reportAction => '通報';

  @override
  String get reportPostTitle => '投稿を通報';

  @override
  String get reportCommentTitle => 'コメントを通報';

  @override
  String get reportReasonHint => '通報理由を入力してください。';

  @override
  String get reportReasonRequired => '通報理由を入力してください。';

  @override
  String get reportReasonTooLong => '通報理由は500文字以内で入力してください。';

  @override
  String get reportSubmitAction => '通報する';

  @override
  String get reportSubmitSuccess => '通報を受け付けました。';

  @override
  String get reportSubmitFailed => '通報の送信中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get reportDuplicate => 'この対象はすでに通報済みです。';

  @override
  String get deletedCommentMessage => '削除されたコメントです。';

  @override
  String get postDeleteTitle => '投稿を削除';

  @override
  String get postDeleteConfirm => 'この投稿を削除しますか？コメントも一緒に削除されます。';

  @override
  String get postDeleted => '投稿が削除されました。';

  @override
  String get postDeleteFailed => '投稿削除中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get profileScreenTitle => 'プロフィール';

  @override
  String get guestProfileSubtitle => 'ログインすると、より多くの機能が使えます。';

  @override
  String get settingsPreparing => '設定機能は準備中です。';

  @override
  String get myPosts => '自分の投稿';

  @override
  String get myComments => '自分のコメント';

  @override
  String get contactReport => 'お問い合わせ/報告';

  @override
  String get contactReportPreparing => 'お問い合わせ/報告機能は準備中です。';

  @override
  String get inquiryGuestEntryAction => 'お問い合わせ';

  @override
  String get inquiryFormTitleGuest => 'サービスお問い合わせ';

  @override
  String get inquiryFormTitleUser => 'お問い合わせ作成';

  @override
  String get inquiryListTitle => 'お問い合わせ履歴';

  @override
  String get inquiryTypeLabel => 'お問い合わせ種別';

  @override
  String get inquiryTypeGeneral => '一般お問い合わせ';

  @override
  String get inquiryTypeBug => '不具合報告';

  @override
  String get inquiryTypeFeature => '機能要望';

  @override
  String get inquiryTypeAccount => 'アカウント';

  @override
  String get inquiryTypeTechnical => '技術サポート';

  @override
  String get inquiryTitleLabel => 'タイトル';

  @override
  String get inquiryTitleHint => 'お問い合わせタイトルを入力してください';

  @override
  String get inquiryTitleRequired => 'タイトルを入力してください。';

  @override
  String get inquiryTitleLength => 'タイトルは2文字以上で入力してください。';

  @override
  String get inquiryContentLabel => '内容';

  @override
  String get inquiryContentHint => 'お問い合わせ内容を詳しく入力してください';

  @override
  String get inquiryContentRequired => '内容を入力してください。';

  @override
  String get inquiryContentLength => '内容は5文字以上で入力してください。';

  @override
  String get inquiryEmailLabel => '返信先メール';

  @override
  String get inquiryEmailHint => 'example@email.com';

  @override
  String get inquiryEmailRequired => 'メールアドレスを入力してください。';

  @override
  String get inquiryEmailInvalid => '正しいメールアドレス形式を入力してください。';

  @override
  String get inquiryGuestConsentLabel => '返信のためにメールアドレスを収集することに同意します。';

  @override
  String get inquiryGuestConsentRequired => '個人情報収集への同意が必要です。';

  @override
  String get inquirySubmitAction => 'お問い合わせ送信';

  @override
  String get inquirySubmitSuccess => 'お問い合わせを登録しました。';

  @override
  String get inquirySubmitFailed => 'お問い合わせ登録中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get inquiryLoadFailed => 'お問い合わせ履歴を読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get inquiryNewAction => 'お問い合わせ作成';

  @override
  String get inquiryEmptyTitle => '登録されたお問い合わせはありません。';

  @override
  String get inquiryEmptySubtitle => 'ご質問・ご提案・ご報告をお寄せください。';

  @override
  String get inquiryListLoginRequired => 'お問い合わせ履歴はログイン後に確認できます。';

  @override
  String get inquiryAnswerLabel => '運営チーム回答';

  @override
  String get inquiryAnswerPending => 'まだ回答は登録されていません。';

  @override
  String get inquiryStatusPending => '受付';

  @override
  String get inquiryStatusInProgress => '対応中';

  @override
  String get inquiryStatusResolved => '解決';

  @override
  String get inquiryStatusClosed => '終了';

  @override
  String get preparing => '準備中です。';

  @override
  String get appInfo => 'アプリ情報';

  @override
  String versionLabel(String version) {
    return 'バージョン $version';
  }

  @override
  String get versionChecking => 'バージョン確認中...';

  @override
  String get logoutConfirmTitle => 'ログアウト';

  @override
  String get logoutConfirmContent => 'ログアウトしますか？';

  @override
  String get withdrawAccount => '退会する';

  @override
  String get withdrawWarningTitle => '退会のご案内';

  @override
  String get withdrawWarningBodyStrong =>
      '退会すると、コーヒー/豆/投稿/コメントの原文データは即時に削除され、復元できません。\nコミュニティには退会案内メッセージのみが残る場合があります。';

  @override
  String get withdrawFinalConfirmTitle => '本当に退会しますか？';

  @override
  String get withdrawFinalConfirmBody => '退会後は元に戻せません。続行しますか？';

  @override
  String get withdrawCompleted => '退会が完了しました。';

  @override
  String get withdrawFailed => '退会処理中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get profileEditTitle => 'プロフィール編集';

  @override
  String get profileEditPhotoAction => 'プロフィール写真を変更';

  @override
  String get profileEditNicknameLabel => 'ニックネーム';

  @override
  String get profileEditNicknameHint => 'ニックネームを入力してください';

  @override
  String get profileEditNicknameRule => 'ニックネームは2〜20文字で、空白のみは使用できません。';

  @override
  String get profileEditNicknameRequired => 'ニックネームを入力してください。';

  @override
  String get profileEditNicknameLength => 'ニックネームは2〜20文字で入力してください。';

  @override
  String get profileEditNicknameDuplicate => 'このニックネームは既に使用されています。';

  @override
  String get profileEditSaveSuccess => 'プロフィールを保存しました。';

  @override
  String get profileEditSaveFailed => 'プロフィール保存中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get save => '保存';

  @override
  String get userDefault => 'ユーザー';

  @override
  String get photoSelectTitle => '写真を選択';

  @override
  String get gallery => 'ギャラリー';

  @override
  String get camera => 'カメラ';

  @override
  String get photoDelete => '削除';

  @override
  String get photoDeleteMenu => '写真を削除';

  @override
  String get photoChange => '写真を変更';

  @override
  String get photoAdd => '写真を追加';

  @override
  String get pickFromGallery => 'ギャラリーから選択';

  @override
  String get takeFromCamera => 'カメラで撮影';

  @override
  String get errRequestFailed => 'リクエストを処理できませんでした。しばらくしてから再試行してください。';

  @override
  String get errPostHourlyLimitExceeded =>
      '時間あたりの投稿作成上限を超えました。しばらくしてから再試行してください。';

  @override
  String get errCommentHourlyLimitExceeded =>
      '時間あたりのコメント作成上限を超えました。しばらくしてから再試行してください。';

  @override
  String get errNetwork => 'ネットワーク接続を確認してください。';

  @override
  String get errCanceled => '操作がキャンセルされました。';

  @override
  String get errAuthExpired => '認証の有効期限が切れました。再度ログインしてください。';

  @override
  String get errInvalidCredentials => 'ログイン情報を確認してください。';

  @override
  String get errUserNotFound => 'アカウントが見つかりません。';

  @override
  String get errAlreadyRegistered => 'すでに登録済みのアカウントです。';

  @override
  String get errAccountInvalid => 'アカウント情報が無効です。再度ログインしてください。';

  @override
  String get errAlreadyExists => 'すでに登録されたデータです。';

  @override
  String get errInvalidInput => '入力内容を確認してください。';

  @override
  String get errPermissionDenied => 'この操作を実行する権限がありません。';

  @override
  String get errCommunityPostHourlyLimit =>
      '1時間あたりの投稿上限に達しました。しばらくしてから再試行してください。';

  @override
  String get errCommunityCommentHourlyLimit =>
      '1時間あたりのコメント上限に達しました。しばらくしてから再試行してください。';

  @override
  String get errNotFound => '要求したデータが見つかりません。';

  @override
  String get errReauthRequired => 'リクエストを処理できません。再度ログインしてください。';

  @override
  String get errGoogleLoginCanceled => 'Googleログインがキャンセルされました。';

  @override
  String get errGoogleTokenUnavailable => 'Google認証トークンを取得できません。';

  @override
  String get errLoginFailed => 'ログイン中にエラーが発生しました。再試行してください。';

  @override
  String get errTermsLoadFailed => '規約情報を読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errTermsConsentFailed => '規約同意の処理中にエラーが発生しました。しばらくしてから再試行してください。';

  @override
  String get errTermsRequiredNotAgreed => '必須規約に同意すると続行できます。';

  @override
  String get errServiceNotInitialized => '必須サービスが初期化されていません。';

  @override
  String get errLoadBeans => '豆リストを読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errLoadBeanDetail => '豆情報を読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errLoadLogs => '記録リストを読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errLoadLogDetail => '記録情報を読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errLoadPosts => '投稿リストを読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errLoadPostDetail => '投稿を読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errLoadDashboard => 'ダッシュボード情報を読み込めませんでした。しばらくしてから再試行してください。';

  @override
  String get errBeanNotFound => '豆が見つかりません。';

  @override
  String get errSampleBeanNotFound => 'サンプル豆が見つかりません。';

  @override
  String get errLogNotFound => '記録が見つかりません。';

  @override
  String get errSampleLogNotFound => 'サンプル記録が見つかりません。';

  @override
  String get errPostNotFound => '投稿が見つかりません。';

  @override
  String get coffeeTypeEspresso => 'エスプレッソ';

  @override
  String get coffeeTypeAmericano => 'アメリカーノ';

  @override
  String get coffeeTypeLatte => 'ラテ';

  @override
  String get coffeeTypeCappuccino => 'カプチーノ';

  @override
  String get coffeeTypeMocha => 'モカ';

  @override
  String get coffeeTypeMacchiato => 'マキアート';

  @override
  String get coffeeTypeFlatWhite => 'フラットホワイト';

  @override
  String get coffeeTypeColdBrew => 'コールドブリュー';

  @override
  String get coffeeTypeAffogato => 'アフォガート';

  @override
  String get coffeeTypeOther => 'その他';

  @override
  String get roastLight => 'ライト';

  @override
  String get roastMediumLight => 'ミディアムライト';

  @override
  String get roastMedium => 'ミディアム';

  @override
  String get roastMediumDark => 'ミディアムダーク';

  @override
  String get roastDark => 'ダーク';

  @override
  String get brewMethodEspresso => 'エスプレッソ';

  @override
  String get brewMethodPourOver => 'ハンドドリップ';

  @override
  String get brewMethodFrenchPress => 'フレンチプレス';

  @override
  String get brewMethodMokaPot => 'モカポット';

  @override
  String get brewMethodAeroPress => 'エアロプレス';

  @override
  String get brewMethodColdBrew => 'コールドブリュー';

  @override
  String get brewMethodSiphon => 'サイフォン';

  @override
  String get brewMethodTurkish => 'トルコ式';

  @override
  String get brewMethodOther => 'その他';

  @override
  String get grindExtraFine => '極細';

  @override
  String get grindFine => '細挽き';

  @override
  String get grindMediumFine => '中細挽き';

  @override
  String get grindMedium => '中挽き';

  @override
  String get grindMediumCoarse => '中粗挽き';

  @override
  String get grindCoarse => '粗挽き';

  @override
  String get grindExtraCoarse => '極粗挽き';

  @override
  String get withdrawnUser => '退会したユーザー';

  @override
  String get withdrawnPostMessage => '退会したユーザーの投稿です。';

  @override
  String get withdrawnCommentMessage => '退会したユーザーのコメントです。';

  @override
  String get guestNickname => 'ゲスト';

  @override
  String get sampleRoasteryA => 'サンプルロースタリー';

  @override
  String get sampleRoasteryB => 'サンプルコーヒーラボ';

  @override
  String get sampleStoreOnline => 'オンラインストア';

  @override
  String get sampleStoreOffline => '聖水オフライン店舗';

  @override
  String get sampleStoreSubscription => '定期購読';

  @override
  String get sampleCafe => 'サンプルカフェ';

  @override
  String get sampleBeanName1 => 'イルガチェフェ G1';

  @override
  String get sampleBeanName2 => 'コロンビア ウイラ';

  @override
  String get sampleBeanName3 => 'ケニア AA';

  @override
  String get sampleBeanNote1 => 'フローラル、ジャスミン、桃';

  @override
  String get sampleBeanNote2 => 'キャラメル、オレンジ、ミルクチョコレート';

  @override
  String get sampleBeanNote3 => 'カシス、グレープフルーツ、ブラウンシュガー';

  @override
  String get sampleOriginEthiopia => 'エチオピア';

  @override
  String get sampleOriginColombia => 'コロンビア';

  @override
  String get sampleOriginKenya => 'ケニア';

  @override
  String get sampleProcessWashed => 'ウォッシュド';

  @override
  String get sampleProcessHoney => 'ハニー';

  @override
  String get sampleFood1 => 'レモンパウンドケーキ';

  @override
  String get sampleBrewNote1 => 'クリーンカップで甘さの余韻が長く続く。';

  @override
  String get sampleCoffeeName1 => 'シングルオリジン アメリカーノ';

  @override
  String get sampleCoffeeName2 => 'オーツラテ';

  @override
  String get sampleCoffeeName3 => 'コールドブリューブレンド';

  @override
  String get sampleLogNote1 => '明るい酸味とクリーンな後味。';

  @override
  String get sampleLogNote2 => 'ボディは良いが、後半に少し甘さが強い。';

  @override
  String get sampleLogNote3 => 'チョコレートとナッツのニュアンスが安定していた。';
}
