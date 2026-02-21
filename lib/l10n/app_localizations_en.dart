// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coffee Log';

  @override
  String get appInitFailedTitle => 'App initialization failed.';

  @override
  String get appExit => 'Exit App';

  @override
  String get appStartUnavailable =>
      'Unable to start the app. Please try again later.';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get beanRecords => 'Bean Records';

  @override
  String get coffeeRecords => 'Coffee Records';

  @override
  String get community => 'Community';

  @override
  String get profile => 'Profile';

  @override
  String get login => 'Login';

  @override
  String get loginNow => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get register => 'Register';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get retry => 'Retry';

  @override
  String get viewMore => 'View More';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get minRating => 'Minimum Rating';

  @override
  String get searchDefaultHint => 'Search...';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String errorOccurredWithMessage(String message) {
    return 'An error occurred\n$message';
  }

  @override
  String get requiredLogin => 'Login is required.';

  @override
  String get guestMode => 'Guest Mode';

  @override
  String get guestBanner =>
      'You are in guest mode. Log in to use all features.';

  @override
  String get orLabel => 'Or';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get browseAsGuest => 'Continue as Guest';

  @override
  String get loginTagline => 'Record your coffee journey';

  @override
  String get loginFailedGeneric => 'An error occurred during login.';

  @override
  String get notificationsPreparing =>
      'Notification feature is in preparation.';

  @override
  String helloUser(String name) {
    return 'Hello, $name! ☕';
  }

  @override
  String get defaultCoffeeLover => 'Coffee Lover';

  @override
  String get dashboardSubtitle => 'How about a fragrant cup of coffee today?';

  @override
  String countBeans(int count) {
    return '$count beans';
  }

  @override
  String countLogs(int count) {
    return '$count logs';
  }

  @override
  String get recordBean => 'Record Bean';

  @override
  String get recordCoffee => 'Record Coffee';

  @override
  String get recentBeanRecords => 'Recent Bean Records';

  @override
  String get recentCoffeeRecords => 'Recent Coffee Records';

  @override
  String get noBeanRecordsYet => 'No bean records yet';

  @override
  String get noCoffeeRecordsYet => 'No coffee records yet';

  @override
  String get firstBeanRecord => 'Record your first bean';

  @override
  String get firstCoffeeRecord => 'Record your first coffee';

  @override
  String get beansScreenTitle => 'Bean Records';

  @override
  String get beansSearchHint => 'Search bean name, roastery...';

  @override
  String get beansEmptyTitle => 'No beans registered';

  @override
  String get beansEmptySubtitleAuth => 'Record your first bean!';

  @override
  String get beansEmptySubtitleGuest => 'Log in to record beans.';

  @override
  String get beansRecordButton => 'Record Bean';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortByRating => 'Highest Rating';

  @override
  String get sortByName => 'Name';

  @override
  String get roastLevel => 'Roast Level';

  @override
  String ratingAtLeast(double rating) {
    return '$rating+';
  }

  @override
  String get beanFormNewTitle => 'New Bean Record';

  @override
  String get beanFormEditTitle => 'Edit Bean';

  @override
  String get beanPhoto => 'Bean Photo';

  @override
  String get beanNameLabel => 'Bean Name *';

  @override
  String get beanNameHint => 'e.g. Ethiopia Yirgacheffe';

  @override
  String get beanNameRequired => 'Please enter bean name';

  @override
  String get roasteryLabel => 'Roastery *';

  @override
  String get roasteryHint => 'e.g. Coffee Libre';

  @override
  String get roasteryRequired => 'Please enter roastery';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get rating => 'Rating';

  @override
  String get price => 'Price';

  @override
  String get priceHint => 'KRW';

  @override
  String get purchaseLocation => 'Purchase Location';

  @override
  String get purchaseLocationHint => 'e.g. Official website';

  @override
  String get tastingNotes => 'Tasting Notes';

  @override
  String get tastingNotesHint => 'Describe the taste of this bean...';

  @override
  String get saveAsNew => 'Save';

  @override
  String get saveAsEdit => 'Update';

  @override
  String get beanCreated => 'Bean has been registered.';

  @override
  String get beanUpdated => 'Bean has been updated.';

  @override
  String get beanSaveFailed =>
      'An error occurred while saving bean. Please try again later.';

  @override
  String get beanDeleteTitle => 'Delete Bean';

  @override
  String get beanDeleteConfirm =>
      'Delete this bean? Related brew records will also be deleted.';

  @override
  String get beanDeleted => 'Bean has been deleted.';

  @override
  String get beanDeleteFailed =>
      'An error occurred while deleting bean. Please try again later.';

  @override
  String get beanInfoPurchaseDate => 'Purchase Date';

  @override
  String get beanInfoPrice => 'Price';

  @override
  String get beanInfoPurchaseLocation => 'Purchase Location';

  @override
  String get beanDetailsSection => 'Bean Details';

  @override
  String varietyLabel(String value) {
    return 'Variety: $value';
  }

  @override
  String processLabel(String value) {
    return 'Process: $value';
  }

  @override
  String get brewHistory => 'Brew Records';

  @override
  String recordsCount(int count) {
    return '$count records';
  }

  @override
  String get brewDefaultTitle => 'Brew';

  @override
  String get logsScreenTitle => 'Coffee Records';

  @override
  String get logsSearchHint => 'Search coffee, cafe...';

  @override
  String get logsEmptyTitle => 'No coffee records registered';

  @override
  String get logsEmptySubtitleAuth => 'Record the coffee you drank today!';

  @override
  String get logsEmptySubtitleGuest => 'Log in to record coffee.';

  @override
  String get logsRecordButton => 'Record Coffee';

  @override
  String get logFormNewTitle => 'New Coffee Record';

  @override
  String get logFormEditTitle => 'Edit Record';

  @override
  String get coffeePhoto => 'Coffee Photo';

  @override
  String get coffeeType => 'Coffee Type';

  @override
  String get coffeeName => 'Coffee Name';

  @override
  String get coffeeNameHint => 'e.g. Signature Latte';

  @override
  String get cafeName => 'Cafe Name *';

  @override
  String get cafeNameHint => 'e.g. Blue Bottle Seongsu';

  @override
  String get cafeNameRequired => 'Please enter cafe name';

  @override
  String get visitDate => 'Visit Date';

  @override
  String get memo => 'Memo';

  @override
  String get memoHint => 'Write your impressions about this coffee...';

  @override
  String get logCreated => 'Record has been registered.';

  @override
  String get logUpdated => 'Record has been updated.';

  @override
  String get logSaveFailed =>
      'An error occurred while saving record. Please try again later.';

  @override
  String get logDeleteTitle => 'Delete Record';

  @override
  String get logDeleteConfirm => 'Delete this coffee record?';

  @override
  String get logDeleted => 'Record has been deleted.';

  @override
  String get logDeleteFailed =>
      'An error occurred while deleting record. Please try again later.';

  @override
  String get communityScreenTitle => 'Community';

  @override
  String get communityGuestSubtitle =>
      'Log in to view and write community posts.';

  @override
  String get communityWelcomeSubtitle => 'Talk with other coffee lovers';

  @override
  String get postSearchHint => 'Search posts...';

  @override
  String get postsEmptyTitle => 'No posts';

  @override
  String get postsEmptySubtitle => 'Write the first post!';

  @override
  String get writePost => 'Write Post';

  @override
  String get postFormNewTitle => 'New Post';

  @override
  String get postFormEditTitle => 'Edit Post';

  @override
  String get postTitle => 'Title';

  @override
  String get postTitleHint => 'Enter title';

  @override
  String get postTitleRequired => 'Please enter title';

  @override
  String get postTitleMinLength => 'Title must be at least 2 characters';

  @override
  String get postContent => 'Content';

  @override
  String get postContentHint => 'Share your story about coffee...';

  @override
  String get postContentRequired => 'Please enter content';

  @override
  String get postContentMinLength => 'Content must be at least 10 characters';

  @override
  String get postImageInsert => 'Insert Image';

  @override
  String get postImageLimitReached => 'You can attach up to 3 images.';

  @override
  String postImageCount(int count) {
    return 'Images $count/3';
  }

  @override
  String get postPreview => 'Preview';

  @override
  String get postImageUploadPreparing => 'Uploading images...';

  @override
  String get postCreated => 'Post has been registered.';

  @override
  String get postUpdated => 'Post has been updated.';

  @override
  String get postSaveFailed =>
      'An error occurred while saving post. Please try again later.';

  @override
  String get postScreenTitle => 'Post';

  @override
  String get commentCreated => 'Comment has been registered.';

  @override
  String get commentHint => 'Enter a comment...';

  @override
  String commentsCount(int count) {
    return 'Comments $count';
  }

  @override
  String get commentNone => 'No comments yet.\nLeave the first comment!';

  @override
  String get commentDeleteFailed =>
      'An error occurred while deleting comment. Please try again later.';

  @override
  String get commentCreateFailed =>
      'An error occurred while saving comment. Please try again later.';

  @override
  String get postDeleteTitle => 'Delete Post';

  @override
  String get postDeleteConfirm =>
      'Delete this post? Comments will also be deleted.';

  @override
  String get postDeleted => 'Post has been deleted.';

  @override
  String get postDeleteFailed =>
      'An error occurred while deleting post. Please try again later.';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get guestProfileSubtitle => 'Log in to use more features.';

  @override
  String get settingsPreparing => 'Settings feature is in preparation.';

  @override
  String get myPosts => 'My Posts';

  @override
  String get myComments => 'My Comments';

  @override
  String get contactReport => 'Contact/Report';

  @override
  String get contactReportPreparing =>
      'Contact/Report feature is in preparation.';

  @override
  String get preparing => 'In preparation.';

  @override
  String get appInfo => 'App Info';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get versionChecking => 'Checking version...';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmContent => 'Do you want to logout?';

  @override
  String get profileEditTitle => 'Edit Profile';

  @override
  String get profileEditPhotoAction => 'Change Profile Photo';

  @override
  String get profileEditNicknameLabel => 'Nickname';

  @override
  String get profileEditNicknameHint => 'Enter a nickname';

  @override
  String get profileEditNicknameRule =>
      'Nickname must be 2-20 characters and cannot be blank.';

  @override
  String get profileEditNicknameRequired => 'Please enter a nickname.';

  @override
  String get profileEditNicknameLength => 'Nickname must be 2-20 characters.';

  @override
  String get profileEditNicknameDuplicate => 'This nickname is already in use.';

  @override
  String get profileEditSaveSuccess => 'Profile has been saved.';

  @override
  String get profileEditSaveFailed =>
      'An error occurred while saving profile. Please try again later.';

  @override
  String get save => 'Save';

  @override
  String get userDefault => 'User';

  @override
  String get photoSelectTitle => 'Select Photo';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get photoDelete => 'Delete';

  @override
  String get photoDeleteMenu => 'Delete Photo';

  @override
  String get photoChange => 'Change Photo';

  @override
  String get photoAdd => 'Add Photo';

  @override
  String get pickFromGallery => 'Choose from Gallery';

  @override
  String get takeFromCamera => 'Take with Camera';

  @override
  String get errRequestFailed =>
      'Unable to process request. Please try again later.';

  @override
  String get errNetwork => 'Please check your network connection.';

  @override
  String get errCanceled => 'Operation has been canceled.';

  @override
  String get errAuthExpired =>
      'Authentication has expired. Please log in again.';

  @override
  String get errInvalidCredentials => 'Please check your login credentials.';

  @override
  String get errUserNotFound => 'Account not found.';

  @override
  String get errAlreadyRegistered => 'Account already registered.';

  @override
  String get errAccountInvalid => 'Account is not valid. Please log in again.';

  @override
  String get errAlreadyExists => 'Data already exists.';

  @override
  String get errInvalidInput => 'Please check your input.';

  @override
  String get errPermissionDenied =>
      'You do not have permission for this action.';

  @override
  String get errNotFound => 'Requested data was not found.';

  @override
  String get errReauthRequired =>
      'Unable to process request. Please log in again.';

  @override
  String get errGoogleLoginCanceled => 'Google sign-in was canceled.';

  @override
  String get errGoogleTokenUnavailable =>
      'Unable to retrieve Google auth token.';

  @override
  String get errLoginFailed =>
      'An error occurred during login. Please try again.';

  @override
  String get errServiceNotInitialized => 'Required service is not initialized.';

  @override
  String get errLoadBeans =>
      'Unable to load bean list. Please try again later.';

  @override
  String get errLoadBeanDetail =>
      'Unable to load bean details. Please try again later.';

  @override
  String get errLoadLogs =>
      'Unable to load record list. Please try again later.';

  @override
  String get errLoadLogDetail =>
      'Unable to load record details. Please try again later.';

  @override
  String get errLoadPosts =>
      'Unable to load post list. Please try again later.';

  @override
  String get errLoadPostDetail =>
      'Unable to load post. Please try again later.';

  @override
  String get errLoadDashboard =>
      'Unable to load dashboard. Please try again later.';

  @override
  String get errBeanNotFound => 'Bean not found.';

  @override
  String get errSampleBeanNotFound => 'Sample bean not found.';

  @override
  String get errLogNotFound => 'Record not found.';

  @override
  String get errSampleLogNotFound => 'Sample record not found.';

  @override
  String get errPostNotFound => 'Post not found.';

  @override
  String get coffeeTypeEspresso => 'Espresso';

  @override
  String get coffeeTypeAmericano => 'Americano';

  @override
  String get coffeeTypeLatte => 'Latte';

  @override
  String get coffeeTypeCappuccino => 'Cappuccino';

  @override
  String get coffeeTypeMocha => 'Mocha';

  @override
  String get coffeeTypeMacchiato => 'Macchiato';

  @override
  String get coffeeTypeFlatWhite => 'Flat White';

  @override
  String get coffeeTypeColdBrew => 'Cold Brew';

  @override
  String get coffeeTypeAffogato => 'Affogato';

  @override
  String get coffeeTypeOther => 'Other';

  @override
  String get roastLight => 'Light';

  @override
  String get roastMediumLight => 'Medium Light';

  @override
  String get roastMedium => 'Medium';

  @override
  String get roastMediumDark => 'Medium Dark';

  @override
  String get roastDark => 'Dark';

  @override
  String get brewMethodEspresso => 'Espresso';

  @override
  String get brewMethodPourOver => 'Pour Over';

  @override
  String get brewMethodFrenchPress => 'French Press';

  @override
  String get brewMethodMokaPot => 'Moka Pot';

  @override
  String get brewMethodAeroPress => 'AeroPress';

  @override
  String get brewMethodColdBrew => 'Cold Brew';

  @override
  String get brewMethodSiphon => 'Siphon';

  @override
  String get brewMethodTurkish => 'Turkish';

  @override
  String get brewMethodOther => 'Other';

  @override
  String get grindExtraFine => 'Extra Fine';

  @override
  String get grindFine => 'Fine';

  @override
  String get grindMediumFine => 'Medium Fine';

  @override
  String get grindMedium => 'Medium';

  @override
  String get grindMediumCoarse => 'Medium Coarse';

  @override
  String get grindCoarse => 'Coarse';

  @override
  String get grindExtraCoarse => 'Extra Coarse';

  @override
  String get guestNickname => 'Guest';

  @override
  String get sampleRoasteryA => 'Sample Roastery';

  @override
  String get sampleRoasteryB => 'Sample Coffee Lab';

  @override
  String get sampleStoreOnline => 'Online Store';

  @override
  String get sampleStoreOffline => 'Seongsu Offline Store';

  @override
  String get sampleStoreSubscription => 'Subscription';

  @override
  String get sampleCafe => 'Sample Cafe';

  @override
  String get sampleBeanName1 => 'Yirgacheffe G1';

  @override
  String get sampleBeanName2 => 'Colombia Huila';

  @override
  String get sampleBeanName3 => 'Kenya AA';

  @override
  String get sampleBeanNote1 => 'Floral, jasmine, peach';

  @override
  String get sampleBeanNote2 => 'Caramel, orange, milk chocolate';

  @override
  String get sampleBeanNote3 => 'Blackcurrant, grapefruit, brown sugar';

  @override
  String get sampleOriginEthiopia => 'Ethiopia';

  @override
  String get sampleOriginColombia => 'Colombia';

  @override
  String get sampleOriginKenya => 'Kenya';

  @override
  String get sampleProcessWashed => 'Washed';

  @override
  String get sampleProcessHoney => 'Honey';

  @override
  String get sampleFood1 => 'Lemon pound cake';

  @override
  String get sampleBrewNote1 => 'Clean cup with a long sweet finish.';

  @override
  String get sampleCoffeeName1 => 'Single Origin Americano';

  @override
  String get sampleCoffeeName2 => 'Oat Latte';

  @override
  String get sampleCoffeeName3 => 'Cold Brew Blend';

  @override
  String get sampleLogNote1 => 'Bright acidity and a clean finish.';

  @override
  String get sampleLogNote2 => 'Good body but slightly too sweet at the end.';

  @override
  String get sampleLogNote3 => 'Stable chocolate and nutty nuances.';
}
