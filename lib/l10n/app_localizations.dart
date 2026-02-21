import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee Log'**
  String get appTitle;

  /// No description provided for @appInitFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'App initialization failed.'**
  String get appInitFailedTitle;

  /// No description provided for @appExit.
  ///
  /// In en, this message translates to:
  /// **'Exit App'**
  String get appExit;

  /// No description provided for @appStartUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to start the app. Please try again later.'**
  String get appStartUnavailable;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @beanRecords.
  ///
  /// In en, this message translates to:
  /// **'Bean Records'**
  String get beanRecords;

  /// No description provided for @coffeeRecords.
  ///
  /// In en, this message translates to:
  /// **'Coffee Records'**
  String get coffeeRecords;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginNow.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginNow;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @minRating.
  ///
  /// In en, this message translates to:
  /// **'Minimum Rating'**
  String get minRating;

  /// No description provided for @searchDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchDefaultHint;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @errorOccurredWithMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred\n{message}'**
  String errorOccurredWithMessage(String message);

  /// No description provided for @requiredLogin.
  ///
  /// In en, this message translates to:
  /// **'Login is required.'**
  String get requiredLogin;

  /// No description provided for @guestMode.
  ///
  /// In en, this message translates to:
  /// **'Guest Mode'**
  String get guestMode;

  /// No description provided for @guestBanner.
  ///
  /// In en, this message translates to:
  /// **'You are in guest mode. Log in to use all features.'**
  String get guestBanner;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get orLabel;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

  /// No description provided for @browseAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get browseAsGuest;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Record your coffee journey'**
  String get loginTagline;

  /// No description provided for @loginFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login.'**
  String get loginFailedGeneric;

  /// No description provided for @notificationsPreparing.
  ///
  /// In en, this message translates to:
  /// **'Notification feature is in preparation.'**
  String get notificationsPreparing;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}! ☕'**
  String helloUser(String name);

  /// No description provided for @defaultCoffeeLover.
  ///
  /// In en, this message translates to:
  /// **'Coffee Lover'**
  String get defaultCoffeeLover;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How about a fragrant cup of coffee today?'**
  String get dashboardSubtitle;

  /// No description provided for @countBeans.
  ///
  /// In en, this message translates to:
  /// **'{count} beans'**
  String countBeans(int count);

  /// No description provided for @countLogs.
  ///
  /// In en, this message translates to:
  /// **'{count} logs'**
  String countLogs(int count);

  /// No description provided for @recordBean.
  ///
  /// In en, this message translates to:
  /// **'Record Bean'**
  String get recordBean;

  /// No description provided for @recordCoffee.
  ///
  /// In en, this message translates to:
  /// **'Record Coffee'**
  String get recordCoffee;

  /// No description provided for @recentBeanRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent Bean Records'**
  String get recentBeanRecords;

  /// No description provided for @recentCoffeeRecords.
  ///
  /// In en, this message translates to:
  /// **'Recent Coffee Records'**
  String get recentCoffeeRecords;

  /// No description provided for @noBeanRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No bean records yet'**
  String get noBeanRecordsYet;

  /// No description provided for @noCoffeeRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No coffee records yet'**
  String get noCoffeeRecordsYet;

  /// No description provided for @firstBeanRecord.
  ///
  /// In en, this message translates to:
  /// **'Record your first bean'**
  String get firstBeanRecord;

  /// No description provided for @firstCoffeeRecord.
  ///
  /// In en, this message translates to:
  /// **'Record your first coffee'**
  String get firstCoffeeRecord;

  /// No description provided for @beansScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Bean Records'**
  String get beansScreenTitle;

  /// No description provided for @beansSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search bean name, roastery...'**
  String get beansSearchHint;

  /// No description provided for @beansEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No beans registered'**
  String get beansEmptyTitle;

  /// No description provided for @beansEmptySubtitleAuth.
  ///
  /// In en, this message translates to:
  /// **'Record your first bean!'**
  String get beansEmptySubtitleAuth;

  /// No description provided for @beansEmptySubtitleGuest.
  ///
  /// In en, this message translates to:
  /// **'Log in to record beans.'**
  String get beansEmptySubtitleGuest;

  /// No description provided for @beansRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Record Bean'**
  String get beansRecordButton;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortByRating.
  ///
  /// In en, this message translates to:
  /// **'Highest Rating'**
  String get sortByRating;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @roastLevel.
  ///
  /// In en, this message translates to:
  /// **'Roast Level'**
  String get roastLevel;

  /// No description provided for @ratingAtLeast.
  ///
  /// In en, this message translates to:
  /// **'{rating}+'**
  String ratingAtLeast(double rating);

  /// No description provided for @beanFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Bean Record'**
  String get beanFormNewTitle;

  /// No description provided for @beanFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Bean'**
  String get beanFormEditTitle;

  /// No description provided for @beanPhoto.
  ///
  /// In en, this message translates to:
  /// **'Bean Photo'**
  String get beanPhoto;

  /// No description provided for @beanNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Bean Name *'**
  String get beanNameLabel;

  /// No description provided for @beanNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ethiopia Yirgacheffe'**
  String get beanNameHint;

  /// No description provided for @beanNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter bean name'**
  String get beanNameRequired;

  /// No description provided for @roasteryLabel.
  ///
  /// In en, this message translates to:
  /// **'Roastery *'**
  String get roasteryLabel;

  /// No description provided for @roasteryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Coffee Libre'**
  String get roasteryHint;

  /// No description provided for @roasteryRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter roastery'**
  String get roasteryRequired;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @priceHint.
  ///
  /// In en, this message translates to:
  /// **'KRW'**
  String get priceHint;

  /// No description provided for @purchaseLocation.
  ///
  /// In en, this message translates to:
  /// **'Purchase Location'**
  String get purchaseLocation;

  /// No description provided for @purchaseLocationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Official website'**
  String get purchaseLocationHint;

  /// No description provided for @tastingNotes.
  ///
  /// In en, this message translates to:
  /// **'Tasting Notes'**
  String get tastingNotes;

  /// No description provided for @tastingNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the taste of this bean...'**
  String get tastingNotesHint;

  /// No description provided for @saveAsNew.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveAsNew;

  /// No description provided for @saveAsEdit.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get saveAsEdit;

  /// No description provided for @beanCreated.
  ///
  /// In en, this message translates to:
  /// **'Bean has been registered.'**
  String get beanCreated;

  /// No description provided for @beanUpdated.
  ///
  /// In en, this message translates to:
  /// **'Bean has been updated.'**
  String get beanUpdated;

  /// No description provided for @beanSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving bean. Please try again later.'**
  String get beanSaveFailed;

  /// No description provided for @beanDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Bean'**
  String get beanDeleteTitle;

  /// No description provided for @beanDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this bean? Related brew records will also be deleted.'**
  String get beanDeleteConfirm;

  /// No description provided for @beanDeleted.
  ///
  /// In en, this message translates to:
  /// **'Bean has been deleted.'**
  String get beanDeleted;

  /// No description provided for @beanDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting bean. Please try again later.'**
  String get beanDeleteFailed;

  /// No description provided for @beanInfoPurchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get beanInfoPurchaseDate;

  /// No description provided for @beanInfoPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get beanInfoPrice;

  /// No description provided for @beanInfoPurchaseLocation.
  ///
  /// In en, this message translates to:
  /// **'Purchase Location'**
  String get beanInfoPurchaseLocation;

  /// No description provided for @beanDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Bean Details'**
  String get beanDetailsSection;

  /// No description provided for @varietyLabel.
  ///
  /// In en, this message translates to:
  /// **'Variety: {value}'**
  String varietyLabel(String value);

  /// No description provided for @processLabel.
  ///
  /// In en, this message translates to:
  /// **'Process: {value}'**
  String processLabel(String value);

  /// No description provided for @brewHistory.
  ///
  /// In en, this message translates to:
  /// **'Brew Records'**
  String get brewHistory;

  /// No description provided for @recordsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String recordsCount(int count);

  /// No description provided for @brewDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Brew'**
  String get brewDefaultTitle;

  /// No description provided for @logsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee Records'**
  String get logsScreenTitle;

  /// No description provided for @logsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search coffee, cafe...'**
  String get logsSearchHint;

  /// No description provided for @logsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No coffee records registered'**
  String get logsEmptyTitle;

  /// No description provided for @logsEmptySubtitleAuth.
  ///
  /// In en, this message translates to:
  /// **'Record the coffee you drank today!'**
  String get logsEmptySubtitleAuth;

  /// No description provided for @logsEmptySubtitleGuest.
  ///
  /// In en, this message translates to:
  /// **'Log in to record coffee.'**
  String get logsEmptySubtitleGuest;

  /// No description provided for @logsRecordButton.
  ///
  /// In en, this message translates to:
  /// **'Record Coffee'**
  String get logsRecordButton;

  /// No description provided for @listLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more items...'**
  String get listLoadingMore;

  /// No description provided for @logFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Coffee Record'**
  String get logFormNewTitle;

  /// No description provided for @logFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Record'**
  String get logFormEditTitle;

  /// No description provided for @coffeePhoto.
  ///
  /// In en, this message translates to:
  /// **'Coffee Photo'**
  String get coffeePhoto;

  /// No description provided for @coffeeType.
  ///
  /// In en, this message translates to:
  /// **'Coffee Type'**
  String get coffeeType;

  /// No description provided for @coffeeName.
  ///
  /// In en, this message translates to:
  /// **'Coffee Name'**
  String get coffeeName;

  /// No description provided for @coffeeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Signature Latte'**
  String get coffeeNameHint;

  /// No description provided for @cafeName.
  ///
  /// In en, this message translates to:
  /// **'Cafe Name *'**
  String get cafeName;

  /// No description provided for @cafeNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Blue Bottle Seongsu'**
  String get cafeNameHint;

  /// No description provided for @cafeNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter cafe name'**
  String get cafeNameRequired;

  /// No description provided for @visitDate.
  ///
  /// In en, this message translates to:
  /// **'Visit Date'**
  String get visitDate;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @memoHint.
  ///
  /// In en, this message translates to:
  /// **'Write your impressions about this coffee...'**
  String get memoHint;

  /// No description provided for @logCreated.
  ///
  /// In en, this message translates to:
  /// **'Record has been registered.'**
  String get logCreated;

  /// No description provided for @logUpdated.
  ///
  /// In en, this message translates to:
  /// **'Record has been updated.'**
  String get logUpdated;

  /// No description provided for @logSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving record. Please try again later.'**
  String get logSaveFailed;

  /// No description provided for @logDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record'**
  String get logDeleteTitle;

  /// No description provided for @logDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this coffee record?'**
  String get logDeleteConfirm;

  /// No description provided for @logDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record has been deleted.'**
  String get logDeleted;

  /// No description provided for @logDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting record. Please try again later.'**
  String get logDeleteFailed;

  /// No description provided for @communityScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityScreenTitle;

  /// No description provided for @communityGuestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to view and write community posts.'**
  String get communityGuestSubtitle;

  /// No description provided for @communityWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Talk with other coffee lovers'**
  String get communityWelcomeSubtitle;

  /// No description provided for @postSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search posts...'**
  String get postSearchHint;

  /// No description provided for @postsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No posts'**
  String get postsEmptyTitle;

  /// No description provided for @postsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Write the first post!'**
  String get postsEmptySubtitle;

  /// No description provided for @writePost.
  ///
  /// In en, this message translates to:
  /// **'Write Post'**
  String get writePost;

  /// No description provided for @postFormNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Post'**
  String get postFormNewTitle;

  /// No description provided for @postFormEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get postFormEditTitle;

  /// No description provided for @postTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get postTitle;

  /// No description provided for @postTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get postTitleHint;

  /// No description provided for @postTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter title'**
  String get postTitleRequired;

  /// No description provided for @postTitleMinLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 2 characters'**
  String get postTitleMinLength;

  /// No description provided for @postTitleMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Title must be 50 characters or fewer'**
  String get postTitleMaxLength;

  /// No description provided for @postTitleCount.
  ///
  /// In en, this message translates to:
  /// **'Title {count}/50'**
  String postTitleCount(int count);

  /// No description provided for @postContent.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get postContent;

  /// No description provided for @postContentHint.
  ///
  /// In en, this message translates to:
  /// **'Share your story about coffee...'**
  String get postContentHint;

  /// No description provided for @postContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter content'**
  String get postContentRequired;

  /// No description provided for @postContentMinLength.
  ///
  /// In en, this message translates to:
  /// **'Content must be at least 2 characters'**
  String get postContentMinLength;

  /// No description provided for @postContentMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Content must be 500 characters or fewer'**
  String get postContentMaxLength;

  /// No description provided for @postContentCount.
  ///
  /// In en, this message translates to:
  /// **'Content {count}/500'**
  String postContentCount(int count);

  /// No description provided for @postImageInsert.
  ///
  /// In en, this message translates to:
  /// **'Insert Image'**
  String get postImageInsert;

  /// No description provided for @postImageLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can attach up to 3 images.'**
  String get postImageLimitReached;

  /// No description provided for @postImageCount.
  ///
  /// In en, this message translates to:
  /// **'Images {count}/3'**
  String postImageCount(int count);

  /// No description provided for @postPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get postPreview;

  /// No description provided for @postImageUploadPreparing.
  ///
  /// In en, this message translates to:
  /// **'Uploading images...'**
  String get postImageUploadPreparing;

  /// No description provided for @postCreated.
  ///
  /// In en, this message translates to:
  /// **'Post has been registered.'**
  String get postCreated;

  /// No description provided for @postUpdated.
  ///
  /// In en, this message translates to:
  /// **'Post has been updated.'**
  String get postUpdated;

  /// No description provided for @postSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving post. Please try again later.'**
  String get postSaveFailed;

  /// No description provided for @postScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postScreenTitle;

  /// No description provided for @commentCreated.
  ///
  /// In en, this message translates to:
  /// **'Comment has been registered.'**
  String get commentCreated;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a comment...'**
  String get commentHint;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'Comments {count}'**
  String commentsCount(int count);

  /// No description provided for @commentNone.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.\nLeave the first comment!'**
  String get commentNone;

  /// No description provided for @commentDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting comment. Please try again later.'**
  String get commentDeleteFailed;

  /// No description provided for @commentCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving comment. Please try again later.'**
  String get commentCreateFailed;

  /// No description provided for @postDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get postDeleteTitle;

  /// No description provided for @postDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this post? Comments will also be deleted.'**
  String get postDeleteConfirm;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post has been deleted.'**
  String get postDeleted;

  /// No description provided for @postDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting post. Please try again later.'**
  String get postDeleteFailed;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// No description provided for @guestProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to use more features.'**
  String get guestProfileSubtitle;

  /// No description provided for @settingsPreparing.
  ///
  /// In en, this message translates to:
  /// **'Settings feature is in preparation.'**
  String get settingsPreparing;

  /// No description provided for @myPosts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get myPosts;

  /// No description provided for @myComments.
  ///
  /// In en, this message translates to:
  /// **'My Comments'**
  String get myComments;

  /// No description provided for @contactReport.
  ///
  /// In en, this message translates to:
  /// **'Contact/Report'**
  String get contactReport;

  /// No description provided for @contactReportPreparing.
  ///
  /// In en, this message translates to:
  /// **'Contact/Report feature is in preparation.'**
  String get contactReportPreparing;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'In preparation.'**
  String get preparing;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get appInfo;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @versionChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking version...'**
  String get versionChecking;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout?'**
  String get logoutConfirmContent;

  /// No description provided for @withdrawAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get withdrawAccount;

  /// No description provided for @withdrawWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Notice'**
  String get withdrawWarningTitle;

  /// No description provided for @withdrawWarningBodyStrong.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account immediately removes the original content of your coffee, bean, post, and comment data, and this cannot be recovered.\nOnly system notice messages may remain in the community.'**
  String get withdrawWarningBodyStrong;

  /// No description provided for @withdrawFinalConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get withdrawFinalConfirmTitle;

  /// No description provided for @withdrawFinalConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Do you want to continue?'**
  String get withdrawFinalConfirmBody;

  /// No description provided for @withdrawCompleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get withdrawCompleted;

  /// No description provided for @withdrawFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting your account. Please try again later.'**
  String get withdrawFailed;

  /// No description provided for @profileEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditTitle;

  /// No description provided for @profileEditPhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get profileEditPhotoAction;

  /// No description provided for @profileEditNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profileEditNicknameLabel;

  /// No description provided for @profileEditNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a nickname'**
  String get profileEditNicknameHint;

  /// No description provided for @profileEditNicknameRule.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 2-20 characters and cannot be blank.'**
  String get profileEditNicknameRule;

  /// No description provided for @profileEditNicknameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a nickname.'**
  String get profileEditNicknameRequired;

  /// No description provided for @profileEditNicknameLength.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 2-20 characters.'**
  String get profileEditNicknameLength;

  /// No description provided for @profileEditNicknameDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This nickname is already in use.'**
  String get profileEditNicknameDuplicate;

  /// No description provided for @profileEditSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile has been saved.'**
  String get profileEditSaveSuccess;

  /// No description provided for @profileEditSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving profile. Please try again later.'**
  String get profileEditSaveFailed;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @userDefault.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userDefault;

  /// No description provided for @photoSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get photoSelectTitle;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @photoDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get photoDelete;

  /// No description provided for @photoDeleteMenu.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get photoDeleteMenu;

  /// No description provided for @photoChange.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get photoChange;

  /// No description provided for @photoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get photoAdd;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get pickFromGallery;

  /// No description provided for @takeFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take with Camera'**
  String get takeFromCamera;

  /// No description provided for @errRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to process request. Please try again later.'**
  String get errRequestFailed;

  /// No description provided for @errPostHourlyLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded the hourly post creation limit. Please try again later.'**
  String get errPostHourlyLimitExceeded;

  /// No description provided for @errCommentHourlyLimitExceeded.
  ///
  /// In en, this message translates to:
  /// **'You have exceeded the hourly comment creation limit. Please try again later.'**
  String get errCommentHourlyLimitExceeded;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'Please check your network connection.'**
  String get errNetwork;

  /// No description provided for @errCanceled.
  ///
  /// In en, this message translates to:
  /// **'Operation has been canceled.'**
  String get errCanceled;

  /// No description provided for @errAuthExpired.
  ///
  /// In en, this message translates to:
  /// **'Authentication has expired. Please log in again.'**
  String get errAuthExpired;

  /// No description provided for @errInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Please check your login credentials.'**
  String get errInvalidCredentials;

  /// No description provided for @errUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found.'**
  String get errUserNotFound;

  /// No description provided for @errAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Account already registered.'**
  String get errAlreadyRegistered;

  /// No description provided for @errAccountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Account is not valid. Please log in again.'**
  String get errAccountInvalid;

  /// No description provided for @errAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Data already exists.'**
  String get errAlreadyExists;

  /// No description provided for @errInvalidInput.
  ///
  /// In en, this message translates to:
  /// **'Please check your input.'**
  String get errInvalidInput;

  /// No description provided for @errPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission for this action.'**
  String get errPermissionDenied;

  /// No description provided for @errCommunityPostHourlyLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached the hourly post limit. Please try again later.'**
  String get errCommunityPostHourlyLimit;

  /// No description provided for @errCommunityCommentHourlyLimit.
  ///
  /// In en, this message translates to:
  /// **'You have reached the hourly comment limit. Please try again later.'**
  String get errCommunityCommentHourlyLimit;

  /// No description provided for @errNotFound.
  ///
  /// In en, this message translates to:
  /// **'Requested data was not found.'**
  String get errNotFound;

  /// No description provided for @errReauthRequired.
  ///
  /// In en, this message translates to:
  /// **'Unable to process request. Please log in again.'**
  String get errReauthRequired;

  /// No description provided for @errGoogleLoginCanceled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was canceled.'**
  String get errGoogleLoginCanceled;

  /// No description provided for @errGoogleTokenUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve Google auth token.'**
  String get errGoogleTokenUnavailable;

  /// No description provided for @errLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during login. Please try again.'**
  String get errLoginFailed;

  /// No description provided for @errServiceNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Required service is not initialized.'**
  String get errServiceNotInitialized;

  /// No description provided for @errLoadBeans.
  ///
  /// In en, this message translates to:
  /// **'Unable to load bean list. Please try again later.'**
  String get errLoadBeans;

  /// No description provided for @errLoadBeanDetail.
  ///
  /// In en, this message translates to:
  /// **'Unable to load bean details. Please try again later.'**
  String get errLoadBeanDetail;

  /// No description provided for @errLoadLogs.
  ///
  /// In en, this message translates to:
  /// **'Unable to load record list. Please try again later.'**
  String get errLoadLogs;

  /// No description provided for @errLoadLogDetail.
  ///
  /// In en, this message translates to:
  /// **'Unable to load record details. Please try again later.'**
  String get errLoadLogDetail;

  /// No description provided for @errLoadPosts.
  ///
  /// In en, this message translates to:
  /// **'Unable to load post list. Please try again later.'**
  String get errLoadPosts;

  /// No description provided for @errLoadPostDetail.
  ///
  /// In en, this message translates to:
  /// **'Unable to load post. Please try again later.'**
  String get errLoadPostDetail;

  /// No description provided for @errLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Unable to load dashboard. Please try again later.'**
  String get errLoadDashboard;

  /// No description provided for @errBeanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Bean not found.'**
  String get errBeanNotFound;

  /// No description provided for @errSampleBeanNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sample bean not found.'**
  String get errSampleBeanNotFound;

  /// No description provided for @errLogNotFound.
  ///
  /// In en, this message translates to:
  /// **'Record not found.'**
  String get errLogNotFound;

  /// No description provided for @errSampleLogNotFound.
  ///
  /// In en, this message translates to:
  /// **'Sample record not found.'**
  String get errSampleLogNotFound;

  /// No description provided for @errPostNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found.'**
  String get errPostNotFound;

  /// No description provided for @coffeeTypeEspresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get coffeeTypeEspresso;

  /// No description provided for @coffeeTypeAmericano.
  ///
  /// In en, this message translates to:
  /// **'Americano'**
  String get coffeeTypeAmericano;

  /// No description provided for @coffeeTypeLatte.
  ///
  /// In en, this message translates to:
  /// **'Latte'**
  String get coffeeTypeLatte;

  /// No description provided for @coffeeTypeCappuccino.
  ///
  /// In en, this message translates to:
  /// **'Cappuccino'**
  String get coffeeTypeCappuccino;

  /// No description provided for @coffeeTypeMocha.
  ///
  /// In en, this message translates to:
  /// **'Mocha'**
  String get coffeeTypeMocha;

  /// No description provided for @coffeeTypeMacchiato.
  ///
  /// In en, this message translates to:
  /// **'Macchiato'**
  String get coffeeTypeMacchiato;

  /// No description provided for @coffeeTypeFlatWhite.
  ///
  /// In en, this message translates to:
  /// **'Flat White'**
  String get coffeeTypeFlatWhite;

  /// No description provided for @coffeeTypeColdBrew.
  ///
  /// In en, this message translates to:
  /// **'Cold Brew'**
  String get coffeeTypeColdBrew;

  /// No description provided for @coffeeTypeAffogato.
  ///
  /// In en, this message translates to:
  /// **'Affogato'**
  String get coffeeTypeAffogato;

  /// No description provided for @coffeeTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get coffeeTypeOther;

  /// No description provided for @roastLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get roastLight;

  /// No description provided for @roastMediumLight.
  ///
  /// In en, this message translates to:
  /// **'Medium Light'**
  String get roastMediumLight;

  /// No description provided for @roastMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get roastMedium;

  /// No description provided for @roastMediumDark.
  ///
  /// In en, this message translates to:
  /// **'Medium Dark'**
  String get roastMediumDark;

  /// No description provided for @roastDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get roastDark;

  /// No description provided for @brewMethodEspresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get brewMethodEspresso;

  /// No description provided for @brewMethodPourOver.
  ///
  /// In en, this message translates to:
  /// **'Pour Over'**
  String get brewMethodPourOver;

  /// No description provided for @brewMethodFrenchPress.
  ///
  /// In en, this message translates to:
  /// **'French Press'**
  String get brewMethodFrenchPress;

  /// No description provided for @brewMethodMokaPot.
  ///
  /// In en, this message translates to:
  /// **'Moka Pot'**
  String get brewMethodMokaPot;

  /// No description provided for @brewMethodAeroPress.
  ///
  /// In en, this message translates to:
  /// **'AeroPress'**
  String get brewMethodAeroPress;

  /// No description provided for @brewMethodColdBrew.
  ///
  /// In en, this message translates to:
  /// **'Cold Brew'**
  String get brewMethodColdBrew;

  /// No description provided for @brewMethodSiphon.
  ///
  /// In en, this message translates to:
  /// **'Siphon'**
  String get brewMethodSiphon;

  /// No description provided for @brewMethodTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get brewMethodTurkish;

  /// No description provided for @brewMethodOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get brewMethodOther;

  /// No description provided for @grindExtraFine.
  ///
  /// In en, this message translates to:
  /// **'Extra Fine'**
  String get grindExtraFine;

  /// No description provided for @grindFine.
  ///
  /// In en, this message translates to:
  /// **'Fine'**
  String get grindFine;

  /// No description provided for @grindMediumFine.
  ///
  /// In en, this message translates to:
  /// **'Medium Fine'**
  String get grindMediumFine;

  /// No description provided for @grindMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get grindMedium;

  /// No description provided for @grindMediumCoarse.
  ///
  /// In en, this message translates to:
  /// **'Medium Coarse'**
  String get grindMediumCoarse;

  /// No description provided for @grindCoarse.
  ///
  /// In en, this message translates to:
  /// **'Coarse'**
  String get grindCoarse;

  /// No description provided for @grindExtraCoarse.
  ///
  /// In en, this message translates to:
  /// **'Extra Coarse'**
  String get grindExtraCoarse;

  /// No description provided for @withdrawnUser.
  ///
  /// In en, this message translates to:
  /// **'Deleted User'**
  String get withdrawnUser;

  /// No description provided for @withdrawnPostMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a post from a deleted user.'**
  String get withdrawnPostMessage;

  /// No description provided for @withdrawnCommentMessage.
  ///
  /// In en, this message translates to:
  /// **'This is a comment from a deleted user.'**
  String get withdrawnCommentMessage;

  /// No description provided for @guestNickname.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestNickname;

  /// No description provided for @sampleRoasteryA.
  ///
  /// In en, this message translates to:
  /// **'Sample Roastery'**
  String get sampleRoasteryA;

  /// No description provided for @sampleRoasteryB.
  ///
  /// In en, this message translates to:
  /// **'Sample Coffee Lab'**
  String get sampleRoasteryB;

  /// No description provided for @sampleStoreOnline.
  ///
  /// In en, this message translates to:
  /// **'Online Store'**
  String get sampleStoreOnline;

  /// No description provided for @sampleStoreOffline.
  ///
  /// In en, this message translates to:
  /// **'Seongsu Offline Store'**
  String get sampleStoreOffline;

  /// No description provided for @sampleStoreSubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get sampleStoreSubscription;

  /// No description provided for @sampleCafe.
  ///
  /// In en, this message translates to:
  /// **'Sample Cafe'**
  String get sampleCafe;

  /// No description provided for @sampleBeanName1.
  ///
  /// In en, this message translates to:
  /// **'Yirgacheffe G1'**
  String get sampleBeanName1;

  /// No description provided for @sampleBeanName2.
  ///
  /// In en, this message translates to:
  /// **'Colombia Huila'**
  String get sampleBeanName2;

  /// No description provided for @sampleBeanName3.
  ///
  /// In en, this message translates to:
  /// **'Kenya AA'**
  String get sampleBeanName3;

  /// No description provided for @sampleBeanNote1.
  ///
  /// In en, this message translates to:
  /// **'Floral, jasmine, peach'**
  String get sampleBeanNote1;

  /// No description provided for @sampleBeanNote2.
  ///
  /// In en, this message translates to:
  /// **'Caramel, orange, milk chocolate'**
  String get sampleBeanNote2;

  /// No description provided for @sampleBeanNote3.
  ///
  /// In en, this message translates to:
  /// **'Blackcurrant, grapefruit, brown sugar'**
  String get sampleBeanNote3;

  /// No description provided for @sampleOriginEthiopia.
  ///
  /// In en, this message translates to:
  /// **'Ethiopia'**
  String get sampleOriginEthiopia;

  /// No description provided for @sampleOriginColombia.
  ///
  /// In en, this message translates to:
  /// **'Colombia'**
  String get sampleOriginColombia;

  /// No description provided for @sampleOriginKenya.
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get sampleOriginKenya;

  /// No description provided for @sampleProcessWashed.
  ///
  /// In en, this message translates to:
  /// **'Washed'**
  String get sampleProcessWashed;

  /// No description provided for @sampleProcessHoney.
  ///
  /// In en, this message translates to:
  /// **'Honey'**
  String get sampleProcessHoney;

  /// No description provided for @sampleFood1.
  ///
  /// In en, this message translates to:
  /// **'Lemon pound cake'**
  String get sampleFood1;

  /// No description provided for @sampleBrewNote1.
  ///
  /// In en, this message translates to:
  /// **'Clean cup with a long sweet finish.'**
  String get sampleBrewNote1;

  /// No description provided for @sampleCoffeeName1.
  ///
  /// In en, this message translates to:
  /// **'Single Origin Americano'**
  String get sampleCoffeeName1;

  /// No description provided for @sampleCoffeeName2.
  ///
  /// In en, this message translates to:
  /// **'Oat Latte'**
  String get sampleCoffeeName2;

  /// No description provided for @sampleCoffeeName3.
  ///
  /// In en, this message translates to:
  /// **'Cold Brew Blend'**
  String get sampleCoffeeName3;

  /// No description provided for @sampleLogNote1.
  ///
  /// In en, this message translates to:
  /// **'Bright acidity and a clean finish.'**
  String get sampleLogNote1;

  /// No description provided for @sampleLogNote2.
  ///
  /// In en, this message translates to:
  /// **'Good body but slightly too sweet at the end.'**
  String get sampleLogNote2;

  /// No description provided for @sampleLogNote3.
  ///
  /// In en, this message translates to:
  /// **'Stable chocolate and nutty nuances.'**
  String get sampleLogNote3;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
