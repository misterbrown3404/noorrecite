// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'Assalamu Alaikum,';

  @override
  String get nextPrayer => 'NEXT PRAYER';

  @override
  String get unableToLoadPrayerTimes => 'Unable to load prayer times';

  @override
  String get retry => 'Retry';

  @override
  String get continueListening => 'CONTINUE LISTENING';

  @override
  String get dailyAyah => 'DAILY AYAH';

  @override
  String get popularReciters => 'Popular Reciters';

  @override
  String get viewAll => 'VIEW ALL';

  @override
  String get quranTitle => 'Quran';

  @override
  String get allSurahs => 'All Surahs';

  @override
  String get juz => 'Juz';

  @override
  String get makkah => 'Makkah';

  @override
  String get madinah => 'Madinah';

  @override
  String get bookmarksFilter => 'Bookmarks';

  @override
  String get searchHint => 'Search Surah, Juz, or Keyword...';

  @override
  String get lastRead => 'LAST READ';

  @override
  String ayahLabel(int n) {
    return 'Ayah $n';
  }

  @override
  String percentCompleted(String pct) {
    return '$pct% Completed';
  }

  @override
  String pagesRange(int start, int end) {
    return 'Pages $start–$end';
  }

  @override
  String pagesRangeLabel(int start, int end) {
    return 'PAGES $start–$end';
  }

  @override
  String get nowPlaying => 'Now Playing';

  @override
  String get removeDownload => 'Remove download';

  @override
  String deleteOfflineCopy(String surahName) {
    return 'Delete the offline copy of $surahName?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get queue => 'QUEUE';

  @override
  String get noSurahsInQueue => 'No surahs in queue';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'Surah $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get manageOfflineLibrary => 'Manage your offline Quranic library';

  @override
  String get offlineMode => 'OFFLINE MODE';

  @override
  String get storageUsage => 'STORAGE USAGE';

  @override
  String surahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'surahs',
      one: 'surah',
    );
    return '$_temp0';
  }

  @override
  String get clearAll => 'CLEAR ALL';

  @override
  String get downloadedByReciter => 'DOWNLOADED BY RECITER';

  @override
  String get clearAllDownloads => 'Clear all downloads';

  @override
  String get clearAllDownloadsConfirm =>
      'This removes every downloaded surah from this device. This cannot be undone.';

  @override
  String get clearAllButton => 'Clear all';

  @override
  String get noDownloadsYet => 'No downloads yet';

  @override
  String get noDownloadsSubtitle =>
      'Tap the download icon on the player to save a surah for offline listening.';

  @override
  String get bookmarksTitle => 'Bookmarks';

  @override
  String get myBookmarks => 'My Bookmarks';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Saved Ayahs',
      one: '$count Saved Ayah',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'Last Read';

  @override
  String get noSurahOpenedYet => 'No surah opened yet';

  @override
  String get openSurahFromQuranTab => 'Open a surah from the Quran tab';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'Ayah $ayah • Pages $start–$end';
  }

  @override
  String get continueReading => 'Continue Reading';

  @override
  String get noBookmarksYet => 'No Bookmarks Yet';

  @override
  String get noBookmarksSubtitle =>
      'Start saving your favorite Ayahs to build your personal spiritual treasury.';

  @override
  String get exploreQuran => 'Explore Quran';

  @override
  String get recitersTitle => 'Reciters';

  @override
  String get featuredReciters => 'Featured Reciters';

  @override
  String get searchRecitersHint => 'Search by name or style...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get notifications => 'NOTIFICATIONS';

  @override
  String get prayerTimesReminders => 'Prayer Times & Reminders';

  @override
  String get prayerTimesSubtitle => 'Get notified for prayer times';

  @override
  String get dailyReflectionReminder => 'Daily Reflection Reminder';

  @override
  String get dailyReflectionSubtitle =>
      'Get a gentle nudge for your daily ayah';

  @override
  String get offline => 'OFFLINE';

  @override
  String get offlineModeTitle => 'Offline Mode';

  @override
  String get offlineModeSubtitle => 'Play only downloaded surahs';

  @override
  String get dataPrivacy => 'DATA & PRIVACY';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearAllDataSubtitle => 'Reset app to fresh state';

  @override
  String get about => 'ABOUT';

  @override
  String get supportApp => 'Support This App';

  @override
  String get supportAppSubtitle => 'Free sadaqah — donate if you benefit';

  @override
  String get version => 'Version';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get clearAllDataTitle => 'Clear All Data';

  @override
  String get clearAllDataConfirm =>
      'This will delete all bookmarks, downloads, statistics, and settings. This cannot be undone.';

  @override
  String get clearAllDataButton => 'Clear All';

  @override
  String get done => 'Done';

  @override
  String get allDataCleared => 'All data cleared. Restart the app.';

  @override
  String get dailyReflectionLabel => 'DAILY REFLECTION';

  @override
  String get listen => 'Listen';

  @override
  String get save => 'Save';

  @override
  String get share => 'Share';

  @override
  String get previousReflections => 'Previous Reflections';

  @override
  String get viewAllButton => 'View All';

  @override
  String get addReflection => 'Add Reflection';

  @override
  String get myReflection => 'MY REFLECTION';

  @override
  String get reflectionHint => 'How does this Ayah resonate with your day?';

  @override
  String get clear => 'Clear';

  @override
  String get saveNote => 'Save Note';

  @override
  String get saved => 'Saved';

  @override
  String get reflectionCleared => 'Your reflection was cleared.';

  @override
  String get reflectionSaved => 'Your reflection was saved.';

  @override
  String get selectAyah => 'SELECT AYAH';

  @override
  String get selectAyahDefault => 'Select an Ayah';

  @override
  String get yourReflection => 'YOUR REFLECTION';

  @override
  String get saveReflection => 'Save Reflection';

  @override
  String get selectAyahSheet => 'Select Ayah';

  @override
  String get empty => 'Empty';

  @override
  String get pleaseWriteReflection => 'Please write your reflection first.';

  @override
  String get reflectionHasSaved => 'Your reflection has been saved.';

  @override
  String get allReflections => 'ALL REFLECTIONS';

  @override
  String get yourReflections => 'Your Reflections';

  @override
  String get noMoreReflections => 'No more reflections yet';

  @override
  String get noMoreReflectionsSubtitle =>
      'Tap \"Add Reflection\" to save your thoughts on any ayah.';

  @override
  String get addFirstReflection => 'Add Your First Reflection';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'GET STARTED';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingSlide1Title => 'Make room for Quran';

  @override
  String get onboardingSlide1Body =>
      'Read at your pace. Save the verses you want to return to.';

  @override
  String get onboardingSlide2Title => 'Find your favorite voice';

  @override
  String get onboardingSlide2Body =>
      'Listen to your favorite reciters and download surahs for offline moments.';

  @override
  String get onboardingSlide3Title => 'Bring faith into your day';

  @override
  String get onboardingSlide3Body =>
      'Keep close to prayer times, daily ayahs, and morning and evening Azkar.';
}
