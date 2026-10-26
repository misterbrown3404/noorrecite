import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
    Locale('id'),
    Locale('ms'),
    Locale('ru'),
    Locale('tr'),
    Locale('ur'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'QariVerse'**
  String get appTitle;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum,'**
  String get greeting;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'NEXT PRAYER'**
  String get nextPrayer;

  /// No description provided for @unableToLoadPrayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Unable to load prayer times'**
  String get unableToLoadPrayerTimes;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @continueListening.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE LISTENING'**
  String get continueListening;

  /// No description provided for @dailyAyah.
  ///
  /// In en, this message translates to:
  /// **'DAILY AYAH'**
  String get dailyAyah;

  /// No description provided for @popularReciters.
  ///
  /// In en, this message translates to:
  /// **'Popular Reciters'**
  String get popularReciters;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL'**
  String get viewAll;

  /// No description provided for @quranTitle.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get quranTitle;

  /// No description provided for @allSurahs.
  ///
  /// In en, this message translates to:
  /// **'All Surahs'**
  String get allSurahs;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @makkah.
  ///
  /// In en, this message translates to:
  /// **'Makkah'**
  String get makkah;

  /// No description provided for @madinah.
  ///
  /// In en, this message translates to:
  /// **'Madinah'**
  String get madinah;

  /// No description provided for @bookmarksFilter.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksFilter;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Surah, Juz, or Keyword...'**
  String get searchHint;

  /// No description provided for @lastRead.
  ///
  /// In en, this message translates to:
  /// **'LAST READ'**
  String get lastRead;

  /// No description provided for @ayahLabel.
  ///
  /// In en, this message translates to:
  /// **'Ayah {n}'**
  String ayahLabel(int n);

  /// No description provided for @percentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{pct}% Completed'**
  String percentCompleted(String pct);

  /// No description provided for @pagesRange.
  ///
  /// In en, this message translates to:
  /// **'Pages {start}–{end}'**
  String pagesRange(int start, int end);

  /// No description provided for @pagesRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'PAGES {start}–{end}'**
  String pagesRangeLabel(int start, int end);

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying;

  /// No description provided for @removeDownload.
  ///
  /// In en, this message translates to:
  /// **'Remove download'**
  String get removeDownload;

  /// No description provided for @deleteOfflineCopy.
  ///
  /// In en, this message translates to:
  /// **'Delete the offline copy of {surahName}?'**
  String deleteOfflineCopy(String surahName);

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

  /// No description provided for @queue.
  ///
  /// In en, this message translates to:
  /// **'QUEUE'**
  String get queue;

  /// No description provided for @noSurahsInQueue.
  ///
  /// In en, this message translates to:
  /// **'No surahs in queue'**
  String get noSurahsInQueue;

  /// No description provided for @surahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Surah {surahName} · {reciterName}'**
  String surahSubtitle(String surahName, String reciterName);

  /// No description provided for @downloadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// No description provided for @manageOfflineLibrary.
  ///
  /// In en, this message translates to:
  /// **'Manage your offline Quranic library'**
  String get manageOfflineLibrary;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE MODE'**
  String get offlineMode;

  /// No description provided for @storageUsage.
  ///
  /// In en, this message translates to:
  /// **'STORAGE USAGE'**
  String get storageUsage;

  /// No description provided for @surahCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{surah} other{surahs}}'**
  String surahCount(int count);

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'CLEAR ALL'**
  String get clearAll;

  /// No description provided for @downloadedByReciter.
  ///
  /// In en, this message translates to:
  /// **'DOWNLOADED BY RECITER'**
  String get downloadedByReciter;

  /// No description provided for @clearAllDownloads.
  ///
  /// In en, this message translates to:
  /// **'Clear all downloads'**
  String get clearAllDownloads;

  /// No description provided for @clearAllDownloadsConfirm.
  ///
  /// In en, this message translates to:
  /// **'This removes every downloaded surah from this device. This cannot be undone.'**
  String get clearAllDownloadsConfirm;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAllButton;

  /// No description provided for @noDownloadsYet.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get noDownloadsYet;

  /// No description provided for @noDownloadsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the download icon on the player to save a surah for offline listening.'**
  String get noDownloadsSubtitle;

  /// No description provided for @bookmarksTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarksTitle;

  /// No description provided for @myBookmarks.
  ///
  /// In en, this message translates to:
  /// **'My Bookmarks'**
  String get myBookmarks;

  /// No description provided for @savedAyahs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} Saved Ayah} other{{count} Saved Ayahs}}'**
  String savedAyahs(int count);

  /// No description provided for @lastReadBadge.
  ///
  /// In en, this message translates to:
  /// **'Last Read'**
  String get lastReadBadge;

  /// No description provided for @noSurahOpenedYet.
  ///
  /// In en, this message translates to:
  /// **'No surah opened yet'**
  String get noSurahOpenedYet;

  /// No description provided for @openSurahFromQuranTab.
  ///
  /// In en, this message translates to:
  /// **'Open a surah from the Quran tab'**
  String get openSurahFromQuranTab;

  /// No description provided for @ayahAndPages.
  ///
  /// In en, this message translates to:
  /// **'Ayah {ayah} • Pages {start}–{end}'**
  String ayahAndPages(int ayah, int start, int end);

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @noBookmarksYet.
  ///
  /// In en, this message translates to:
  /// **'No Bookmarks Yet'**
  String get noBookmarksYet;

  /// No description provided for @noBookmarksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start saving your favorite Ayahs to build your personal spiritual treasury.'**
  String get noBookmarksSubtitle;

  /// No description provided for @exploreQuran.
  ///
  /// In en, this message translates to:
  /// **'Explore Quran'**
  String get exploreQuran;

  /// No description provided for @recitersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reciters'**
  String get recitersTitle;

  /// No description provided for @featuredReciters.
  ///
  /// In en, this message translates to:
  /// **'Featured Reciters'**
  String get featuredReciters;

  /// No description provided for @searchRecitersHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or style...'**
  String get searchRecitersHint;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get notifications;

  /// No description provided for @prayerTimesReminders.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times & Reminders'**
  String get prayerTimesReminders;

  /// No description provided for @prayerTimesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified for prayer times'**
  String get prayerTimesSubtitle;

  /// No description provided for @dailyReflectionReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reflection Reminder'**
  String get dailyReflectionReminder;

  /// No description provided for @dailyReflectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get a gentle nudge for your daily ayah'**
  String get dailyReflectionSubtitle;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get offline;

  /// No description provided for @offlineModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineModeTitle;

  /// No description provided for @offlineModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play only downloaded surahs'**
  String get offlineModeSubtitle;

  /// No description provided for @dataPrivacy.
  ///
  /// In en, this message translates to:
  /// **'DATA & PRIVACY'**
  String get dataPrivacy;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllData;

  /// No description provided for @clearAllDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reset app to fresh state'**
  String get clearAllDataSubtitle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @supportApp.
  ///
  /// In en, this message translates to:
  /// **'Support This App'**
  String get supportApp;

  /// No description provided for @supportAppSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Free sadaqah — donate if you benefit'**
  String get supportAppSubtitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @clearAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All Data'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will delete all bookmarks, downloads, statistics, and settings. This cannot be undone.'**
  String get clearAllDataConfirm;

  /// No description provided for @clearAllDataButton.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllDataButton;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @allDataCleared.
  ///
  /// In en, this message translates to:
  /// **'All data cleared. Restart the app.'**
  String get allDataCleared;

  /// No description provided for @dailyReflectionLabel.
  ///
  /// In en, this message translates to:
  /// **'DAILY REFLECTION'**
  String get dailyReflectionLabel;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @previousReflections.
  ///
  /// In en, this message translates to:
  /// **'Previous Reflections'**
  String get previousReflections;

  /// No description provided for @viewAllButton.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAllButton;

  /// No description provided for @addReflection.
  ///
  /// In en, this message translates to:
  /// **'Add Reflection'**
  String get addReflection;

  /// No description provided for @myReflection.
  ///
  /// In en, this message translates to:
  /// **'MY REFLECTION'**
  String get myReflection;

  /// No description provided for @reflectionHint.
  ///
  /// In en, this message translates to:
  /// **'How does this Ayah resonate with your day?'**
  String get reflectionHint;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @saveNote.
  ///
  /// In en, this message translates to:
  /// **'Save Note'**
  String get saveNote;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @reflectionCleared.
  ///
  /// In en, this message translates to:
  /// **'Your reflection was cleared.'**
  String get reflectionCleared;

  /// No description provided for @reflectionSaved.
  ///
  /// In en, this message translates to:
  /// **'Your reflection was saved.'**
  String get reflectionSaved;

  /// No description provided for @selectAyah.
  ///
  /// In en, this message translates to:
  /// **'SELECT AYAH'**
  String get selectAyah;

  /// No description provided for @selectAyahDefault.
  ///
  /// In en, this message translates to:
  /// **'Select an Ayah'**
  String get selectAyahDefault;

  /// No description provided for @yourReflection.
  ///
  /// In en, this message translates to:
  /// **'YOUR REFLECTION'**
  String get yourReflection;

  /// No description provided for @saveReflection.
  ///
  /// In en, this message translates to:
  /// **'Save Reflection'**
  String get saveReflection;

  /// No description provided for @selectAyahSheet.
  ///
  /// In en, this message translates to:
  /// **'Select Ayah'**
  String get selectAyahSheet;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @pleaseWriteReflection.
  ///
  /// In en, this message translates to:
  /// **'Please write your reflection first.'**
  String get pleaseWriteReflection;

  /// No description provided for @reflectionHasSaved.
  ///
  /// In en, this message translates to:
  /// **'Your reflection has been saved.'**
  String get reflectionHasSaved;

  /// No description provided for @allReflections.
  ///
  /// In en, this message translates to:
  /// **'ALL REFLECTIONS'**
  String get allReflections;

  /// No description provided for @yourReflections.
  ///
  /// In en, this message translates to:
  /// **'Your Reflections'**
  String get yourReflections;

  /// No description provided for @noMoreReflections.
  ///
  /// In en, this message translates to:
  /// **'No more reflections yet'**
  String get noMoreReflections;

  /// No description provided for @noMoreReflectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add Reflection\" to save your thoughts on any ayah.'**
  String get noMoreReflectionsSubtitle;

  /// No description provided for @addFirstReflection.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Reflection'**
  String get addFirstReflection;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Make room for Quran'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Read at your pace. Save the verses you want to return to.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Find your favorite voice'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Listen to your favorite reciters and download surahs for offline moments.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Bring faith into your day'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Keep close to prayer times, daily ayahs, and morning and evening Azkar.'**
  String get onboardingSlide3Body;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'fr',
    'id',
    'ms',
    'ru',
    'tr',
    'ur',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ms':
      return AppLocalizationsMs();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
