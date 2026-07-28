// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'السلام عليكم،';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String get unableToLoadPrayerTimes => 'تعذّر تحميل أوقات الصلاة';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get continueListening => 'متابعة الاستماع';

  @override
  String get dailyAyah => 'آية اليوم';

  @override
  String get popularReciters => 'القراء المميزون';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get quranTitle => 'القرآن';

  @override
  String get allSurahs => 'جميع السور';

  @override
  String get juz => 'الجزء';

  @override
  String get makkah => 'مكية';

  @override
  String get madinah => 'مدنية';

  @override
  String get bookmarksFilter => 'المفضلة';

  @override
  String get searchHint => 'ابحث عن سورة أو جزء أو كلمة...';

  @override
  String get lastRead => 'آخر قراءة';

  @override
  String ayahLabel(int n) {
    return 'الآية $n';
  }

  @override
  String percentCompleted(String pct) {
    return '$pct% مكتمل';
  }

  @override
  String pagesRange(int start, int end) {
    return 'الصفحات $start–$end';
  }

  @override
  String pagesRangeLabel(int start, int end) {
    return 'الصفحات $start–$end';
  }

  @override
  String get nowPlaying => 'يُشغَّل الآن';

  @override
  String get removeDownload => 'حذف التنزيل';

  @override
  String deleteOfflineCopy(String surahName) {
    return 'حذف النسخة غير المتصلة من $surahName؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get queue => 'قائمة التشغيل';

  @override
  String get noSurahsInQueue => 'لا توجد سور في قائمة التشغيل';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'سورة $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'التنزيلات';

  @override
  String get manageOfflineLibrary => 'إدارة مكتبتك القرآنية دون اتصال';

  @override
  String get offlineMode => 'وضع عدم الاتصال';

  @override
  String get storageUsage => 'استخدام التخزين';

  @override
  String surahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سور',
      one: 'سورة',
    );
    return '$_temp0';
  }

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get downloadedByReciter => 'مُنزَّل حسب القارئ';

  @override
  String get clearAllDownloads => 'مسح جميع التنزيلات';

  @override
  String get clearAllDownloadsConfirm =>
      'سيؤدي هذا إلى إزالة جميع السور المنزّلة من هذا الجهاز. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get clearAllButton => 'مسح الكل';

  @override
  String get noDownloadsYet => 'لا توجد تنزيلات بعد';

  @override
  String get noDownloadsSubtitle =>
      'اضغط على أيقونة التنزيل في المشغّل لحفظ سورة للاستماع دون اتصال.';

  @override
  String get bookmarksTitle => 'الإشارات المرجعية';

  @override
  String get myBookmarks => 'إشاراتي المرجعية';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count آيات محفوظة',
      one: 'آية محفوظة',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'آخر قراءة';

  @override
  String get noSurahOpenedYet => 'لم تُفتح أي سورة بعد';

  @override
  String get openSurahFromQuranTab => 'افتح سورة من تبويب القرآن';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'الآية $ayah • الصفحات $start–$end';
  }

  @override
  String get continueReading => 'متابعة القراءة';

  @override
  String get noBookmarksYet => 'لا توجد إشارات مرجعية بعد';

  @override
  String get noBookmarksSubtitle =>
      'ابدأ بحفظ الآيات المفضلة لديك لبناء كنزك الروحي الشخصي.';

  @override
  String get exploreQuran => 'استكشاف القرآن';

  @override
  String get recitersTitle => 'القراء';

  @override
  String get featuredReciters => 'القراء المميزون';

  @override
  String get searchRecitersHint => 'ابحث بالاسم أو الأسلوب...';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get language => 'اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get prayerTimesReminders => 'أوقات الصلاة والتذكيرات';

  @override
  String get prayerTimesSubtitle => 'تلقّي إشعارات بأوقات الصلاة';

  @override
  String get dailyReflectionReminder => 'تذكير التأمل اليومي';

  @override
  String get dailyReflectionSubtitle => 'تذكير لطيف بآية يومك';

  @override
  String get offline => 'غير متصل';

  @override
  String get offlineModeTitle => 'وضع عدم الاتصال';

  @override
  String get offlineModeSubtitle => 'تشغيل السور المنزّلة فقط';

  @override
  String get dataPrivacy => 'البيانات والخصوصية';

  @override
  String get clearAllData => 'مسح جميع البيانات';

  @override
  String get clearAllDataSubtitle => 'إعادة ضبط التطبيق';

  @override
  String get about => 'حول';

  @override
  String get supportApp => 'دعم هذا التطبيق';

  @override
  String get supportAppSubtitle => 'صدقة جارية — تبرّع إن استفدت';

  @override
  String get version => 'الإصدار';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get systemDefault => 'إعداد النظام';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get chooseTheme => 'اختر السمة';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get clearAllDataTitle => 'مسح جميع البيانات';

  @override
  String get clearAllDataConfirm =>
      'سيؤدي هذا إلى حذف جميع الإشارات المرجعية والتنزيلات والإحصائيات والإعدادات. لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get clearAllDataButton => 'مسح الكل';

  @override
  String get done => 'تم';

  @override
  String get allDataCleared => 'تم مسح جميع البيانات. أعد تشغيل التطبيق.';

  @override
  String get dailyReflectionLabel => 'تأمل يومي';

  @override
  String get listen => 'استمع';

  @override
  String get save => 'حفظ';

  @override
  String get share => 'مشاركة';

  @override
  String get previousReflections => 'التأملات السابقة';

  @override
  String get viewAllButton => 'عرض الكل';

  @override
  String get addReflection => 'إضافة تأمل';

  @override
  String get myReflection => 'تأملي';

  @override
  String get reflectionHint => 'كيف تتفاعل هذه الآية مع يومك؟';

  @override
  String get clear => 'مسح';

  @override
  String get saveNote => 'حفظ الملاحظة';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get reflectionCleared => 'تم مسح تأملك.';

  @override
  String get reflectionSaved => 'تم حفظ تأملك.';

  @override
  String get selectAyah => 'اختر آية';

  @override
  String get selectAyahDefault => 'اختر آية';

  @override
  String get yourReflection => 'تأملك';

  @override
  String get saveReflection => 'حفظ التأمل';

  @override
  String get selectAyahSheet => 'اختر آية';

  @override
  String get empty => 'فارغ';

  @override
  String get pleaseWriteReflection => 'يرجى كتابة تأملك أولاً.';

  @override
  String get reflectionHasSaved => 'تم حفظ تأملك.';

  @override
  String get allReflections => 'جميع التأملات';

  @override
  String get yourReflections => 'تأملاتك';

  @override
  String get noMoreReflections => 'لا توجد تأملات بعد';

  @override
  String get noMoreReflectionsSubtitle =>
      'اضغط على \"إضافة تأمل\" لحفظ أفكارك حول أي آية.';

  @override
  String get addFirstReflection => 'أضف تأملك الأول';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'ابدأ الآن';

  @override
  String get onboardingBack => 'رجوع';

  @override
  String get onboardingSlide1Title => 'اكتشف تلاوة القرآن';

  @override
  String get onboardingSlide1Body =>
      'استمع إلى كلام الله بأجمل الأصوات في مكان مصمم لروحك.';

  @override
  String get onboardingSlide2Title => 'استمع في أي مكان';

  @override
  String get onboardingSlide2Body =>
      'حمّل تلاواتك المفضلة واستمع إليها دون اتصال بالإنترنت.';

  @override
  String get onboardingSlide3Title => 'تعلم وتأمل';

  @override
  String get onboardingSlide3Body =>
      'تعمق في الحكمة الإلهية مع التفسير كلمة بكلمة والإشارات المرجعية لرحلتك الروحية.';
}
