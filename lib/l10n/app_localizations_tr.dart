// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'Esselamu Aleykum,';

  @override
  String get nextPrayer => 'SONRAKI NAMAZ';

  @override
  String get unableToLoadPrayerTimes => 'Namaz vakitleri yüklenemedi';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get continueListening => 'DİNLEMEYE DEVAM ET';

  @override
  String get dailyAyah => 'GÜNLÜK AYET';

  @override
  String get popularReciters => 'Popüler Hafızlar';

  @override
  String get viewAll => 'TÜMÜNÜ GÖR';

  @override
  String get quranTitle => 'Kuran';

  @override
  String get allSurahs => 'Tüm Sureler';

  @override
  String get juz => 'Cüz';

  @override
  String get makkah => 'Mekki';

  @override
  String get madinah => 'Medeni';

  @override
  String get bookmarksFilter => 'Yer İmleri';

  @override
  String get searchHint => 'Sure, Cüz veya Anahtar Kelime Ara...';

  @override
  String get lastRead => 'SON OKUNAN';

  @override
  String ayahLabel(int n) {
    return 'Ayet $n';
  }

  @override
  String percentCompleted(String pct) {
    return '%$pct Tamamlandı';
  }

  @override
  String pagesRange(int start, int end) {
    return 'Sayfalar $start–$end';
  }

  @override
  String pagesRangeLabel(int start, int end) {
    return 'SAYFALAR $start–$end';
  }

  @override
  String get nowPlaying => 'Şu An Çalıyor';

  @override
  String get removeDownload => 'İndirmeyi Kaldır';

  @override
  String deleteOfflineCopy(String surahName) {
    return '$surahName suresinin çevrimdışı kopyası silinsin mi?';
  }

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get queue => 'SIRA';

  @override
  String get noSurahsInQueue => 'Sırada sure yok';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'Sure $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'İndirmeler';

  @override
  String get manageOfflineLibrary => 'Çevrimdışı Kuran kütüphanenizi yönetin';

  @override
  String get offlineMode => 'ÇEVRİMDIŞI MOD';

  @override
  String get storageUsage => 'DEPOLAMA KULLANIMI';

  @override
  String surahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sure',
      one: 'sure',
    );
    return '$_temp0';
  }

  @override
  String get clearAll => 'TÜMÜNÜ TEMİZLE';

  @override
  String get downloadedByReciter => 'HAFIZA GÖRE İNDİRİLEN';

  @override
  String get clearAllDownloads => 'Tüm indirmeleri temizle';

  @override
  String get clearAllDownloadsConfirm =>
      'Bu işlem cihazdaki tüm indirilen sureleri kaldırır. Bu işlem geri alınamaz.';

  @override
  String get clearAllButton => 'Tümünü temizle';

  @override
  String get noDownloadsYet => 'Henüz indirme yok';

  @override
  String get noDownloadsSubtitle =>
      'Çevrimdışı dinlemek için oynatıcıdaki indirme simgesine dokunun.';

  @override
  String get bookmarksTitle => 'Yer İmleri';

  @override
  String get myBookmarks => 'Yer İmlerim';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kaydedilen Ayet',
      one: '$count Kaydedilen Ayet',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'Son Okunan';

  @override
  String get noSurahOpenedYet => 'Henüz sure açılmadı';

  @override
  String get openSurahFromQuranTab => 'Kuran sekmesinden sure açın';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'Ayet $ayah • Sayfalar $start–$end';
  }

  @override
  String get continueReading => 'Okumaya Devam Et';

  @override
  String get noBookmarksYet => 'Henüz Yer İmi Yok';

  @override
  String get noBookmarksSubtitle =>
      'Kişisel manevi hazinenizi oluşturmak için favori ayetlerinizi kaydetmeye başlayın.';

  @override
  String get exploreQuran => 'Kuranı Keşfet';

  @override
  String get recitersTitle => 'Hafızlar';

  @override
  String get featuredReciters => 'Öne Çıkan Hafızlar';

  @override
  String get searchRecitersHint => 'İsim veya stile göre ara...';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get appearance => 'GÖRÜNÜM';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Dil';

  @override
  String get notifications => 'BİLDİRİMLER';

  @override
  String get prayerTimesReminders => 'Namaz Vakitleri ve Hatırlatıcılar';

  @override
  String get prayerTimesSubtitle => 'Namaz vakitleri için bildirim alın';

  @override
  String get dailyReflectionReminder => 'Günlük Tefekkür Hatırlatıcısı';

  @override
  String get dailyReflectionSubtitle =>
      'Günlük ayetiniz için nazik bir hatırlatma';

  @override
  String get offline => 'ÇEVRİMDIŞI';

  @override
  String get offlineModeTitle => 'Çevrimdışı Mod';

  @override
  String get offlineModeSubtitle => 'Yalnızca indirilen sureleri oynat';

  @override
  String get dataPrivacy => 'VERİ VE GİZLİLİK';

  @override
  String get clearAllData => 'Tüm Verileri Temizle';

  @override
  String get clearAllDataSubtitle => 'Uygulamayı sıfırla';

  @override
  String get about => 'HAKKINDA';

  @override
  String get supportApp => 'Bu Uygulamayı Destekle';

  @override
  String get supportAppSubtitle =>
      'Ücretsiz sadaka — faydalandıysanız bağış yapın';

  @override
  String get version => 'Sürüm';

  @override
  String get lightMode => 'Açık Mod';

  @override
  String get darkMode => 'Koyu Mod';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String get chooseLanguage => 'Dil Seç';

  @override
  String get chooseTheme => 'Tema Seç';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get clearAllDataTitle => 'Tüm Verileri Temizle';

  @override
  String get clearAllDataConfirm =>
      'Bu işlem tüm yer imlerini, indirmeleri, istatistikleri ve ayarları siler. Bu işlem geri alınamaz.';

  @override
  String get clearAllDataButton => 'Tümünü Temizle';

  @override
  String get done => 'Tamam';

  @override
  String get allDataCleared =>
      'Tüm veriler temizlendi. Uygulamayı yeniden başlatın.';

  @override
  String get dailyReflectionLabel => 'GÜNLÜK TEFEKKÜR';

  @override
  String get listen => 'Dinle';

  @override
  String get save => 'Kaydet';

  @override
  String get share => 'Paylaş';

  @override
  String get previousReflections => 'Önceki Tefekküler';

  @override
  String get viewAllButton => 'Tümünü Gör';

  @override
  String get addReflection => 'Tefekkür Ekle';

  @override
  String get myReflection => 'TEFEKKÜRÜm';

  @override
  String get reflectionHint => 'Bu ayet gününüzle nasıl örtüşüyor?';

  @override
  String get clear => 'Temizle';

  @override
  String get saveNote => 'Notu Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get reflectionCleared => 'Tefekkürünüz temizlendi.';

  @override
  String get reflectionSaved => 'Tefekkürünüz kaydedildi.';

  @override
  String get selectAyah => 'AYET SEÇ';

  @override
  String get selectAyahDefault => 'Ayet Seç';

  @override
  String get yourReflection => 'TEFEKKÜRÜNÜz';

  @override
  String get saveReflection => 'Tefekkürü Kaydet';

  @override
  String get selectAyahSheet => 'Ayet Seç';

  @override
  String get empty => 'Boş';

  @override
  String get pleaseWriteReflection => 'Lütfen önce tefekkürünüzü yazın.';

  @override
  String get reflectionHasSaved => 'Tefekkürünüz kaydedildi.';

  @override
  String get allReflections => 'TÜM TEFEKKÜLER';

  @override
  String get yourReflections => 'Tefekküleriniz';

  @override
  String get noMoreReflections => 'Henüz tefekkür yok';

  @override
  String get noMoreReflectionsSubtitle =>
      'Herhangi bir ayet hakkındaki düşüncelerinizi kaydetmek için \"Tefekkür Ekle\"ye dokunun.';

  @override
  String get addFirstReflection => 'İlk Tefekkürünüzü Ekleyin';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingGetStarted => 'BAŞLA';

  @override
  String get onboardingBack => 'Geri';

  @override
  String get onboardingSlide1Title => 'Kur\'an Tilavetini Keşfedin';

  @override
  String get onboardingSlide1Body =>
      'İlahi kelamı, ruhunuz için tasarlanmış bir mekânda dünyanın en güzel sesleriyle deneyimleyin.';

  @override
  String get onboardingSlide2Title => 'Her Yerde Dinleyin';

  @override
  String get onboardingSlide2Body =>
      'En sevdiğiniz tilavetleri indirin ve en uzak yerlerde bile çevrimdışı dinleyin.';

  @override
  String get onboardingSlide3Title => 'Öğrenin ve Tefekkür Edin';

  @override
  String get onboardingSlide3Body =>
      'Kelime kelime Tefsir ve manevi yolculuğunuz için düzenlenmiş yer imleriyle ilahi hikmete daha derin dalın.';
}
