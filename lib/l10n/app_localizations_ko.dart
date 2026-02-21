// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '커피로그';

  @override
  String get appInitFailedTitle => '앱 초기화에 실패했습니다.';

  @override
  String get appExit => '앱 종료';

  @override
  String get appStartUnavailable => '앱을 시작할 수 없습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get pageNotFound => '페이지를 찾을 수 없습니다';

  @override
  String get backToHome => '홈으로 돌아가기';

  @override
  String get dashboard => '대시보드';

  @override
  String get beanRecords => '원두 기록';

  @override
  String get coffeeRecords => '커피 기록';

  @override
  String get community => '커뮤니티';

  @override
  String get profile => '프로필';

  @override
  String get login => '로그인';

  @override
  String get loginNow => '로그인';

  @override
  String get logout => '로그아웃';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get edit => '수정';

  @override
  String get update => '수정';

  @override
  String get register => '등록';

  @override
  String get apply => '적용하기';

  @override
  String get reset => '초기화';

  @override
  String get retry => '다시 시도';

  @override
  String get viewMore => '더보기';

  @override
  String get filter => '필터';

  @override
  String get sort => '정렬';

  @override
  String get minRating => '최소 평점';

  @override
  String get searchDefaultHint => '검색...';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String errorOccurredWithMessage(String message) {
    return '오류가 발생했습니다\n$message';
  }

  @override
  String get requiredLogin => '로그인이 필요합니다.';

  @override
  String get guestMode => '게스트 모드';

  @override
  String get guestBanner => '게스트 모드입니다. 로그인하면 모든 기능을 사용할 수 있습니다.';

  @override
  String get orLabel => '또는';

  @override
  String get loginWithGoogle => 'Google로 로그인';

  @override
  String get browseAsGuest => '게스트로 둘러보기';

  @override
  String get loginTagline => '당신의 커피 여정을 기록하세요';

  @override
  String get loginFailedGeneric => '로그인 중 오류가 발생했습니다.';

  @override
  String get notificationsPreparing => '알림 기능은 준비 중입니다.';

  @override
  String helloUser(String name) {
    return '안녕하세요, $name님! ☕';
  }

  @override
  String get defaultCoffeeLover => '커피러버';

  @override
  String get dashboardSubtitle => '오늘도 향긋한 커피 한 잔 어떠세요?';

  @override
  String countBeans(int count) {
    return '$count개';
  }

  @override
  String countLogs(int count) {
    return '$count개';
  }

  @override
  String get recordBean => '원두 기록하기';

  @override
  String get recordCoffee => '커피 기록하기';

  @override
  String get recentBeanRecords => '최근 원두 기록';

  @override
  String get recentCoffeeRecords => '최근 커피 기록';

  @override
  String get noBeanRecordsYet => '아직 원두 기록이 없습니다';

  @override
  String get noCoffeeRecordsYet => '아직 커피 기록이 없습니다';

  @override
  String get firstBeanRecord => '첫 원두 기록하기';

  @override
  String get firstCoffeeRecord => '첫 커피 기록하기';

  @override
  String get beansScreenTitle => '원두 기록';

  @override
  String get beansSearchHint => '원두 이름, 로스터리 검색...';

  @override
  String get beansEmptyTitle => '등록된 원두가 없습니다';

  @override
  String get beansEmptySubtitleAuth => '첫 원두를 기록해보세요!';

  @override
  String get beansEmptySubtitleGuest => '로그인하면 원두를 기록할 수 있습니다.';

  @override
  String get beansRecordButton => '원두 기록하기';

  @override
  String get sortNewest => '최신순';

  @override
  String get sortByRating => '평점순';

  @override
  String get sortByName => '이름순';

  @override
  String get roastLevel => '로스팅 레벨';

  @override
  String ratingAtLeast(double rating) {
    return '$rating점 이상';
  }

  @override
  String get beanFormNewTitle => '새 원두 기록';

  @override
  String get beanFormEditTitle => '원두 수정';

  @override
  String get beanPhoto => '원두 사진';

  @override
  String get beanNameLabel => '원두 이름 *';

  @override
  String get beanNameHint => '예: 에티오피아 예가체프';

  @override
  String get beanNameRequired => '원두 이름을 입력해주세요';

  @override
  String get roasteryLabel => '로스터리 *';

  @override
  String get roasteryHint => '예: 커피리브레';

  @override
  String get roasteryRequired => '로스터리를 입력해주세요';

  @override
  String get purchaseDate => '구매일';

  @override
  String get rating => '평점';

  @override
  String get price => '가격';

  @override
  String get priceHint => '원';

  @override
  String get purchaseLocation => '구매처';

  @override
  String get purchaseLocationHint => '예: 공식 홈페이지';

  @override
  String get tastingNotes => '테이스팅 노트';

  @override
  String get tastingNotesHint => '이 원두의 맛을 설명해주세요...';

  @override
  String get saveAsNew => '등록하기';

  @override
  String get saveAsEdit => '수정하기';

  @override
  String get beanCreated => '원두가 등록되었습니다.';

  @override
  String get beanUpdated => '원두가 수정되었습니다.';

  @override
  String get beanSaveFailed => '원두 저장 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get beanDeleteTitle => '원두 삭제';

  @override
  String get beanDeleteConfirm => '이 원두를 삭제하시겠습니까? 관련된 추출 기록도 함께 삭제됩니다.';

  @override
  String get beanDeleted => '원두가 삭제되었습니다.';

  @override
  String get beanDeleteFailed => '원두 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get beanInfoPurchaseDate => '구매일';

  @override
  String get beanInfoPrice => '가격';

  @override
  String get beanInfoPurchaseLocation => '구매처';

  @override
  String get beanDetailsSection => '원두 상세';

  @override
  String varietyLabel(String value) {
    return '품종: $value';
  }

  @override
  String processLabel(String value) {
    return '가공: $value';
  }

  @override
  String get brewHistory => '추출 기록';

  @override
  String recordsCount(int count) {
    return '$count건';
  }

  @override
  String get brewDefaultTitle => '추출';

  @override
  String get logsScreenTitle => '커피 기록';

  @override
  String get logsSearchHint => '커피, 카페 검색...';

  @override
  String get logsEmptyTitle => '등록된 커피 기록이 없습니다';

  @override
  String get logsEmptySubtitleAuth => '오늘 마신 커피를 기록해보세요!';

  @override
  String get logsEmptySubtitleGuest => '로그인하면 커피를 기록할 수 있습니다.';

  @override
  String get logsRecordButton => '커피 기록하기';

  @override
  String get logFormNewTitle => '새 커피 기록';

  @override
  String get logFormEditTitle => '기록 수정';

  @override
  String get coffeePhoto => '커피 사진';

  @override
  String get coffeeType => '커피 종류';

  @override
  String get coffeeName => '커피 이름';

  @override
  String get coffeeNameHint => '예: 시그니처 라떼';

  @override
  String get cafeName => '카페 이름 *';

  @override
  String get cafeNameHint => '예: 블루보틀 성수점';

  @override
  String get cafeNameRequired => '카페 이름을 입력해주세요';

  @override
  String get visitDate => '방문일';

  @override
  String get memo => '메모';

  @override
  String get memoHint => '커피에 대한 감상을 적어주세요...';

  @override
  String get logCreated => '기록이 등록되었습니다.';

  @override
  String get logUpdated => '기록이 수정되었습니다.';

  @override
  String get logSaveFailed => '기록 저장 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get logDeleteTitle => '기록 삭제';

  @override
  String get logDeleteConfirm => '이 커피 기록을 삭제하시겠습니까?';

  @override
  String get logDeleted => '기록이 삭제되었습니다.';

  @override
  String get logDeleteFailed => '기록 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get communityScreenTitle => '커뮤니티';

  @override
  String get communityGuestSubtitle => '로그인하면 커뮤니티 게시글을 보고 작성할 수 있습니다.';

  @override
  String get communityWelcomeSubtitle => '다른 커피 애호가들과 이야기를 나눠보세요';

  @override
  String get postSearchHint => '게시글 검색...';

  @override
  String get postsEmptyTitle => '게시글이 없습니다';

  @override
  String get postsEmptySubtitle => '첫 번째 게시글을 작성해보세요!';

  @override
  String get writePost => '글 작성하기';

  @override
  String get postFormNewTitle => '새 게시글';

  @override
  String get postFormEditTitle => '게시글 수정';

  @override
  String get postTitle => '제목';

  @override
  String get postTitleHint => '제목을 입력하세요';

  @override
  String get postTitleRequired => '제목을 입력해주세요';

  @override
  String get postTitleMinLength => '제목은 2자 이상이어야 합니다';

  @override
  String get postTitleMaxLength => '제목은 50자 이하여야 합니다';

  @override
  String postTitleCount(int count) {
    return '제목 $count/50';
  }

  @override
  String get postContent => '내용';

  @override
  String get postContentHint => '커피에 대한 이야기를 나눠보세요...';

  @override
  String get postContentRequired => '내용을 입력해주세요';

  @override
  String get postContentMinLength => '내용은 2자 이상이어야 합니다';

  @override
  String get postContentMaxLength => '내용은 500자 이하여야 합니다';

  @override
  String postContentCount(int count) {
    return '내용 $count/500';
  }

  @override
  String get postImageInsert => '이미지 삽입';

  @override
  String get postImageLimitReached => '이미지는 최대 3장까지 첨부할 수 있습니다.';

  @override
  String postImageCount(int count) {
    return '이미지 $count/3';
  }

  @override
  String get postPreview => '미리보기';

  @override
  String get postImageUploadPreparing => '이미지 업로드 중입니다...';

  @override
  String get postCreated => '게시글이 등록되었습니다.';

  @override
  String get postUpdated => '게시글이 수정되었습니다.';

  @override
  String get postSaveFailed => '게시글 저장 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get postScreenTitle => '게시글';

  @override
  String get commentCreated => '댓글이 등록되었습니다.';

  @override
  String get commentHint => '댓글을 입력하세요...';

  @override
  String commentsCount(int count) {
    return '댓글 $count';
  }

  @override
  String get commentNone => '아직 댓글이 없습니다.\n첫 번째 댓글을 남겨보세요!';

  @override
  String get commentDeleteFailed => '댓글 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get commentCreateFailed => '댓글 등록 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get postDeleteTitle => '게시글 삭제';

  @override
  String get postDeleteConfirm => '이 게시글을 삭제하시겠습니까? 댓글도 함께 삭제됩니다.';

  @override
  String get postDeleted => '게시글이 삭제되었습니다.';

  @override
  String get postDeleteFailed => '게시글 삭제 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get profileScreenTitle => '프로필';

  @override
  String get guestProfileSubtitle => '로그인하면 더 많은 기능을 사용할 수 있습니다';

  @override
  String get settingsPreparing => '설정 기능은 준비 중입니다.';

  @override
  String get myPosts => '내 게시글';

  @override
  String get myComments => '내 댓글';

  @override
  String get contactReport => '문의/제보하기';

  @override
  String get contactReportPreparing => '문의/제보 기능은 준비 중입니다.';

  @override
  String get preparing => '준비 중입니다.';

  @override
  String get appInfo => '앱 정보';

  @override
  String versionLabel(String version) {
    return '버전 $version';
  }

  @override
  String get versionChecking => '버전 확인 중...';

  @override
  String get logoutConfirmTitle => '로그아웃';

  @override
  String get logoutConfirmContent => '로그아웃 하시겠습니까?';

  @override
  String get profileEditTitle => '프로필 수정';

  @override
  String get profileEditPhotoAction => '프로필 사진 변경';

  @override
  String get profileEditNicknameLabel => '닉네임';

  @override
  String get profileEditNicknameHint => '닉네임을 입력하세요';

  @override
  String get profileEditNicknameRule => '닉네임은 2~20자이며, 공백만 입력할 수 없습니다.';

  @override
  String get profileEditNicknameRequired => '닉네임을 입력해주세요.';

  @override
  String get profileEditNicknameLength => '닉네임은 2~20자여야 합니다.';

  @override
  String get profileEditNicknameDuplicate => '이미 사용 중인 닉네임입니다.';

  @override
  String get profileEditSaveSuccess => '프로필이 저장되었습니다.';

  @override
  String get profileEditSaveFailed => '프로필 저장 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get save => '저장';

  @override
  String get userDefault => '사용자';

  @override
  String get photoSelectTitle => '사진 선택';

  @override
  String get gallery => '갤러리';

  @override
  String get camera => '카메라';

  @override
  String get photoDelete => '삭제';

  @override
  String get photoDeleteMenu => '사진 삭제';

  @override
  String get photoChange => '사진 변경';

  @override
  String get photoAdd => '사진 추가';

  @override
  String get pickFromGallery => '갤러리에서 선택';

  @override
  String get takeFromCamera => '카메라로 촬영';

  @override
  String get errRequestFailed => '요청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errNetwork => '네트워크 연결을 확인해주세요.';

  @override
  String get errCanceled => '작업이 취소되었습니다.';

  @override
  String get errAuthExpired => '인증이 만료되었습니다. 다시 로그인해주세요.';

  @override
  String get errInvalidCredentials => '로그인 정보를 확인해주세요.';

  @override
  String get errUserNotFound => '계정을 찾을 수 없습니다.';

  @override
  String get errAlreadyRegistered => '이미 가입된 계정입니다.';

  @override
  String get errAccountInvalid => '계정 정보가 유효하지 않습니다. 다시 로그인 후 시도해주세요.';

  @override
  String get errAlreadyExists => '이미 등록된 데이터입니다.';

  @override
  String get errInvalidInput => '입력값을 다시 확인해주세요.';

  @override
  String get errPermissionDenied => '이 작업을 수행할 권한이 없습니다.';

  @override
  String get errNotFound => '요청한 데이터를 찾을 수 없습니다.';

  @override
  String get errReauthRequired => '요청을 처리할 수 없습니다. 다시 로그인 후 시도해주세요.';

  @override
  String get errGoogleLoginCanceled => 'Google 로그인이 취소되었습니다.';

  @override
  String get errGoogleTokenUnavailable => 'Google 인증 토큰을 가져올 수 없습니다.';

  @override
  String get errLoginFailed => '로그인 중 오류가 발생했습니다. 다시 시도해주세요.';

  @override
  String get errServiceNotInitialized => '필수 서비스가 초기화되지 않았습니다.';

  @override
  String get errLoadBeans => '원두 목록을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errLoadBeanDetail => '원두 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errLoadLogs => '기록 목록을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errLoadLogDetail => '기록 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errLoadPosts => '게시글 목록을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errLoadPostDetail => '게시글을 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errLoadDashboard => '대시보드 정보를 불러오지 못했습니다. 잠시 후 다시 시도해주세요.';

  @override
  String get errBeanNotFound => '원두를 찾을 수 없습니다.';

  @override
  String get errSampleBeanNotFound => '샘플 원두를 찾을 수 없습니다.';

  @override
  String get errLogNotFound => '기록을 찾을 수 없습니다.';

  @override
  String get errSampleLogNotFound => '샘플 기록을 찾을 수 없습니다.';

  @override
  String get errPostNotFound => '게시글을 찾을 수 없습니다.';

  @override
  String get coffeeTypeEspresso => '에스프레소';

  @override
  String get coffeeTypeAmericano => '아메리카노';

  @override
  String get coffeeTypeLatte => '라떼';

  @override
  String get coffeeTypeCappuccino => '카푸치노';

  @override
  String get coffeeTypeMocha => '모카';

  @override
  String get coffeeTypeMacchiato => '마끼아또';

  @override
  String get coffeeTypeFlatWhite => '플랫화이트';

  @override
  String get coffeeTypeColdBrew => '콜드브루';

  @override
  String get coffeeTypeAffogato => '아포가토';

  @override
  String get coffeeTypeOther => '기타';

  @override
  String get roastLight => '라이트';

  @override
  String get roastMediumLight => '미디엄 라이트';

  @override
  String get roastMedium => '미디엄';

  @override
  String get roastMediumDark => '미디엄 다크';

  @override
  String get roastDark => '다크';

  @override
  String get brewMethodEspresso => '에스프레소';

  @override
  String get brewMethodPourOver => '핸드드립';

  @override
  String get brewMethodFrenchPress => '프렌치프레스';

  @override
  String get brewMethodMokaPot => '모카포트';

  @override
  String get brewMethodAeroPress => '에어로프레스';

  @override
  String get brewMethodColdBrew => '콜드브루';

  @override
  String get brewMethodSiphon => '사이폰';

  @override
  String get brewMethodTurkish => '터키쉬';

  @override
  String get brewMethodOther => '기타';

  @override
  String get grindExtraFine => '극세';

  @override
  String get grindFine => '세';

  @override
  String get grindMediumFine => '중세';

  @override
  String get grindMedium => '중';

  @override
  String get grindMediumCoarse => '중굵';

  @override
  String get grindCoarse => '굵';

  @override
  String get grindExtraCoarse => '극굵';

  @override
  String get guestNickname => '게스트';

  @override
  String get sampleRoasteryA => '샘플 로스터리';

  @override
  String get sampleRoasteryB => '샘플 커피랩';

  @override
  String get sampleStoreOnline => '온라인 스토어';

  @override
  String get sampleStoreOffline => '성수 오프라인 매장';

  @override
  String get sampleStoreSubscription => '정기 구독';

  @override
  String get sampleCafe => '샘플 카페';

  @override
  String get sampleBeanName1 => '예가체프 G1';

  @override
  String get sampleBeanName2 => '콜롬비아 우일라';

  @override
  String get sampleBeanName3 => '케냐 AA';

  @override
  String get sampleBeanNote1 => '꽃향, 자스민, 복숭아';

  @override
  String get sampleBeanNote2 => '카라멜, 오렌지, 밀크초콜릿';

  @override
  String get sampleBeanNote3 => '블랙커런트, 자몽, 브라운슈가';

  @override
  String get sampleOriginEthiopia => '에티오피아';

  @override
  String get sampleOriginColombia => '콜롬비아';

  @override
  String get sampleOriginKenya => '케냐';

  @override
  String get sampleProcessWashed => '워시드';

  @override
  String get sampleProcessHoney => '허니';

  @override
  String get sampleFood1 => '레몬 파운드 케이크';

  @override
  String get sampleBrewNote1 => '클린컵이 좋고 단맛이 길게 남음.';

  @override
  String get sampleCoffeeName1 => '싱글 오리진 아메리카노';

  @override
  String get sampleCoffeeName2 => '오트 라떼';

  @override
  String get sampleCoffeeName3 => '콜드브루 블렌드';

  @override
  String get sampleLogNote1 => '산미가 선명하고 끝맛이 깨끗했다.';

  @override
  String get sampleLogNote2 => '바디감은 좋았지만 후반에 단맛이 살짝 과함.';

  @override
  String get sampleLogNote3 => '초콜릿과 견과류 뉘앙스가 안정적이었다.';
}
