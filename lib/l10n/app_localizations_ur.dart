// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'السلام علیکم،';

  @override
  String get nextPrayer => 'اگلی نماز';

  @override
  String get unableToLoadPrayerTimes => 'نماز کے اوقات لوڈ نہیں ہو سکے';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get continueListening => 'سننا جاری رکھیں';

  @override
  String get dailyAyah => 'آج کی آیت';

  @override
  String get popularReciters => 'مشہور قاری';

  @override
  String get viewAll => 'سب دیکھیں';

  @override
  String get quranTitle => 'قرآن';

  @override
  String get allSurahs => 'تمام سورتیں';

  @override
  String get juz => 'پارہ';

  @override
  String get makkah => 'مکی';

  @override
  String get madinah => 'مدنی';

  @override
  String get bookmarksFilter => 'بک مارکس';

  @override
  String get searchHint => 'سورت، پارہ یا لفظ تلاش کریں...';

  @override
  String get lastRead => 'آخری پڑھائی';

  @override
  String ayahLabel(int n) {
    return 'آیت $n';
  }

  @override
  String percentCompleted(String pct) {
    return '$pct% مکمل';
  }

  @override
  String pagesRange(int start, int end) {
    return 'صفحات $start–$end';
  }

  @override
  String pagesRangeLabel(int start, int end) {
    return 'صفحات $start–$end';
  }

  @override
  String get nowPlaying => 'ابھی چل رہا ہے';

  @override
  String get removeDownload => 'ڈاؤنلوڈ ہٹائیں';

  @override
  String deleteOfflineCopy(String surahName) {
    return '$surahName کی آف لائن کاپی حذف کریں؟';
  }

  @override
  String get cancel => 'منسوخ';

  @override
  String get delete => 'حذف کریں';

  @override
  String get queue => 'قطار';

  @override
  String get noSurahsInQueue => 'قطار میں کوئی سورت نہیں';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'سورت $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'ڈاؤنلوڈز';

  @override
  String get manageOfflineLibrary => 'اپنی آف لائن قرآنی لائبریری منظم کریں';

  @override
  String get offlineMode => 'آف لائن موڈ';

  @override
  String get storageUsage => 'اسٹوریج استعمال';

  @override
  String surahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سورتیں',
      one: 'سورت',
    );
    return '$_temp0';
  }

  @override
  String get clearAll => 'سب صاف کریں';

  @override
  String get downloadedByReciter => 'قاری کے مطابق ڈاؤنلوڈ';

  @override
  String get clearAllDownloads => 'تمام ڈاؤنلوڈز صاف کریں';

  @override
  String get clearAllDownloadsConfirm =>
      'اس سے اس ڈیوائس سے تمام ڈاؤنلوڈ شدہ سورتیں ہٹ جائیں گی۔ یہ واپس نہیں ہو سکتا۔';

  @override
  String get clearAllButton => 'سب صاف کریں';

  @override
  String get noDownloadsYet => 'ابھی کوئی ڈاؤنلوڈ نہیں';

  @override
  String get noDownloadsSubtitle =>
      'آف لائن سننے کے لیے پلیئر میں ڈاؤنلوڈ آئیکن دبائیں۔';

  @override
  String get bookmarksTitle => 'بک مارکس';

  @override
  String get myBookmarks => 'میرے بک مارکس';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محفوظ آیات',
      one: '$count محفوظ آیت',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'آخری پڑھائی';

  @override
  String get noSurahOpenedYet => 'ابھی کوئی سورت نہیں کھولی';

  @override
  String get openSurahFromQuranTab => 'قرآن ٹیب سے سورت کھولیں';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'آیت $ayah • صفحات $start–$end';
  }

  @override
  String get continueReading => 'پڑھنا جاری رکھیں';

  @override
  String get noBookmarksYet => 'ابھی کوئی بک مارک نہیں';

  @override
  String get noBookmarksSubtitle =>
      'اپنی پسندیدہ آیات محفوظ کریں اور اپنا روحانی خزانہ بنائیں۔';

  @override
  String get exploreQuran => 'قرآن دریافت کریں';

  @override
  String get recitersTitle => 'قاری';

  @override
  String get featuredReciters => 'نمایاں قاری';

  @override
  String get searchRecitersHint => 'نام یا انداز سے تلاش کریں...';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get appearance => 'ظاہری شکل';

  @override
  String get theme => 'تھیم';

  @override
  String get language => 'زبان';

  @override
  String get notifications => 'اطلاعات';

  @override
  String get prayerTimesReminders => 'نماز کے اوقات اور یاد دہانیاں';

  @override
  String get prayerTimesSubtitle => 'نماز کے اوقات کی اطلاع پائیں';

  @override
  String get dailyReflectionReminder => 'روزانہ غور و فکر کی یاد دہانی';

  @override
  String get dailyReflectionSubtitle => 'روزانہ آیت کے لیے نرم یاد دہانی';

  @override
  String get offline => 'آف لائن';

  @override
  String get offlineModeTitle => 'آف لائن موڈ';

  @override
  String get offlineModeSubtitle => 'صرف ڈاؤنلوڈ شدہ سورتیں چلائیں';

  @override
  String get dataPrivacy => 'ڈیٹا اور رازداری';

  @override
  String get clearAllData => 'تمام ڈیٹا صاف کریں';

  @override
  String get clearAllDataSubtitle => 'ایپ کو ابتدائی حالت میں لائیں';

  @override
  String get about => 'بارے میں';

  @override
  String get supportApp => 'اس ایپ کی مدد کریں';

  @override
  String get supportAppSubtitle => 'صدقہ جاریہ — فائدہ ہو تو عطیہ دیں';

  @override
  String get version => 'ورژن';

  @override
  String get lightMode => 'روشن موڈ';

  @override
  String get darkMode => 'تاریک موڈ';

  @override
  String get systemDefault => 'سسٹم ڈیفالٹ';

  @override
  String get chooseLanguage => 'زبان منتخب کریں';

  @override
  String get chooseTheme => 'تھیم منتخب کریں';

  @override
  String get light => 'روشن';

  @override
  String get dark => 'تاریک';

  @override
  String get clearAllDataTitle => 'تمام ڈیٹا صاف کریں';

  @override
  String get clearAllDataConfirm =>
      'اس سے تمام بک مارکس، ڈاؤنلوڈز، اعداد و شمار اور ترتیبات حذف ہو جائیں گی۔ یہ واپس نہیں ہو سکتا۔';

  @override
  String get clearAllDataButton => 'سب صاف کریں';

  @override
  String get done => 'ہو گیا';

  @override
  String get allDataCleared => 'تمام ڈیٹا صاف ہو گیا۔ ایپ دوبارہ شروع کریں۔';

  @override
  String get dailyReflectionLabel => 'روزانہ غور و فکر';

  @override
  String get listen => 'سنیں';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get share => 'شیئر کریں';

  @override
  String get previousReflections => 'پچھلے غور و فکر';

  @override
  String get viewAllButton => 'سب دیکھیں';

  @override
  String get addReflection => 'غور و فکر شامل کریں';

  @override
  String get myReflection => 'میرا غور و فکر';

  @override
  String get reflectionHint => 'یہ آیت آپ کے دن سے کیسے جڑتی ہے؟';

  @override
  String get clear => 'صاف کریں';

  @override
  String get saveNote => 'نوٹ محفوظ کریں';

  @override
  String get saved => 'محفوظ';

  @override
  String get reflectionCleared => 'آپ کا غور و فکر صاف ہو گیا۔';

  @override
  String get reflectionSaved => 'آپ کا غور و فکر محفوظ ہو گیا۔';

  @override
  String get selectAyah => 'آیت منتخب کریں';

  @override
  String get selectAyahDefault => 'آیت منتخب کریں';

  @override
  String get yourReflection => 'آپ کا غور و فکر';

  @override
  String get saveReflection => 'غور و فکر محفوظ کریں';

  @override
  String get selectAyahSheet => 'آیت منتخب کریں';

  @override
  String get empty => 'خالی';

  @override
  String get pleaseWriteReflection => 'پہلے اپنا غور و فکر لکھیں۔';

  @override
  String get reflectionHasSaved => 'آپ کا غور و فکر محفوظ ہو گیا۔';

  @override
  String get allReflections => 'تمام غور و فکر';

  @override
  String get yourReflections => 'آپ کے غور و فکر';

  @override
  String get noMoreReflections => 'ابھی کوئی غور و فکر نہیں';

  @override
  String get noMoreReflectionsSubtitle =>
      'کسی بھی آیت پر اپنے خیالات محفوظ کرنے کے لیے \"غور و فکر شامل کریں\" دبائیں۔';

  @override
  String get addFirstReflection => 'اپنا پہلا غور و فکر شامل کریں';

  @override
  String get onboardingSkip => 'چھوڑیں';

  @override
  String get onboardingNext => 'اگلا';

  @override
  String get onboardingGetStarted => 'شروع کریں';

  @override
  String get onboardingBack => 'واپس';

  @override
  String get onboardingSlide1Title => 'قرآن کی تلاوت دریافت کریں';

  @override
  String get onboardingSlide1Body =>
      'اپنی روح کے لیے بنائے گئے مقام میں دنیا کی خوبصورت ترین آوازوں کے ذریعے کلامِ الٰہی کا تجربہ کریں۔';

  @override
  String get onboardingSlide2Title => 'کہیں بھی سنیں';

  @override
  String get onboardingSlide2Body =>
      'اپنی پسندیدہ تلاوتیں ڈاؤن لوڈ کریں اور آف لائن سنیں، دور دراز مقامات پر بھی۔';

  @override
  String get onboardingSlide3Title => 'سیکھیں اور غور کریں';

  @override
  String get onboardingSlide3Body =>
      'لفظ بہ لفظ تفسیر اور اپنے روحانی سفر کے لیے منظم بک مارکس کے ساتھ الٰہی حکمت میں گہرائی تک اتریں۔';
}
