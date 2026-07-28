// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'Assalamu Alaikum,';

  @override
  String get nextPrayer => 'SOLAT SETERUSNYA';

  @override
  String get unableToLoadPrayerTimes => 'Tidak dapat memuatkan waktu solat';

  @override
  String get retry => 'Cuba Lagi';

  @override
  String get continueListening => 'TERUSKAN MENDENGAR';

  @override
  String get dailyAyah => 'AYAT HARIAN';

  @override
  String get popularReciters => 'Qari Popular';

  @override
  String get viewAll => 'LIHAT SEMUA';

  @override
  String get quranTitle => 'Al-Quran';

  @override
  String get allSurahs => 'Semua Surah';

  @override
  String get juz => 'Juzuk';

  @override
  String get makkah => 'Makkiyyah';

  @override
  String get madinah => 'Madaniyyah';

  @override
  String get bookmarksFilter => 'Penanda';

  @override
  String get searchHint => 'Cari Surah, Juzuk, atau Kata Kunci...';

  @override
  String get lastRead => 'TERAKHIR DIBACA';

  @override
  String ayahLabel(int n) {
    return 'Ayat $n';
  }

  @override
  String percentCompleted(String pct) {
    return '$pct% Selesai';
  }

  @override
  String pagesRange(int start, int end) {
    return 'Halaman $start–$end';
  }

  @override
  String pagesRangeLabel(int start, int end) {
    return 'HALAMAN $start–$end';
  }

  @override
  String get nowPlaying => 'Sedang Dimainkan';

  @override
  String get removeDownload => 'Buang Muat Turun';

  @override
  String deleteOfflineCopy(String surahName) {
    return 'Padam salinan luar talian $surahName?';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Padam';

  @override
  String get queue => 'GILIRAN';

  @override
  String get noSurahsInQueue => 'Tiada surah dalam giliran';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'Surah $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'Muat Turun';

  @override
  String get manageOfflineLibrary => 'Urus perpustakaan Quran luar talian anda';

  @override
  String get offlineMode => 'MOD LUAR TALIAN';

  @override
  String get storageUsage => 'PENGGUNAAN STORAN';

  @override
  String surahCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'surah',
      one: 'surah',
    );
    return '$_temp0';
  }

  @override
  String get clearAll => 'PADAM SEMUA';

  @override
  String get downloadedByReciter => 'DIMUAT TURUN MENGIKUT QARI';

  @override
  String get clearAllDownloads => 'Padam semua muat turun';

  @override
  String get clearAllDownloadsConfirm =>
      'Ini akan membuang semua surah yang dimuat turun dari peranti ini. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get clearAllButton => 'Padam semua';

  @override
  String get noDownloadsYet => 'Tiada muat turun lagi';

  @override
  String get noDownloadsSubtitle =>
      'Ketik ikon muat turun pada pemain untuk menyimpan surah untuk didengar luar talian.';

  @override
  String get bookmarksTitle => 'Penanda';

  @override
  String get myBookmarks => 'Penanda Saya';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ayat Disimpan',
      one: '$count Ayat Disimpan',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'Terakhir Dibaca';

  @override
  String get noSurahOpenedYet => 'Tiada surah dibuka lagi';

  @override
  String get openSurahFromQuranTab => 'Buka surah dari tab Quran';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'Ayat $ayah • Halaman $start–$end';
  }

  @override
  String get continueReading => 'Teruskan Membaca';

  @override
  String get noBookmarksYet => 'Tiada Penanda Lagi';

  @override
  String get noBookmarksSubtitle =>
      'Mula simpan ayat kegemaran anda untuk membina khazanah rohani peribadi.';

  @override
  String get exploreQuran => 'Terokai Quran';

  @override
  String get recitersTitle => 'Qari';

  @override
  String get featuredReciters => 'Qari Pilihan';

  @override
  String get searchRecitersHint => 'Cari mengikut nama atau gaya...';

  @override
  String get settingsTitle => 'Tetapan';

  @override
  String get appearance => 'PENAMPILAN';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Bahasa';

  @override
  String get notifications => 'PEMBERITAHUAN';

  @override
  String get prayerTimesReminders => 'Waktu Solat & Peringatan';

  @override
  String get prayerTimesSubtitle => 'Terima pemberitahuan untuk waktu solat';

  @override
  String get dailyReflectionReminder => 'Peringatan Renungan Harian';

  @override
  String get dailyReflectionSubtitle =>
      'Peringatan lembut untuk ayat harian anda';

  @override
  String get offline => 'LUAR TALIAN';

  @override
  String get offlineModeTitle => 'Mod Luar Talian';

  @override
  String get offlineModeSubtitle => 'Main hanya surah yang dimuat turun';

  @override
  String get dataPrivacy => 'DATA & PRIVASI';

  @override
  String get clearAllData => 'Padam Semua Data';

  @override
  String get clearAllDataSubtitle => 'Tetapkan semula aplikasi ke keadaan asal';

  @override
  String get about => 'TENTANG';

  @override
  String get supportApp => 'Sokong Aplikasi Ini';

  @override
  String get supportAppSubtitle =>
      'Sedekah percuma — derma jika anda mendapat manfaat';

  @override
  String get version => 'Versi';

  @override
  String get lightMode => 'Mod Cerah';

  @override
  String get darkMode => 'Mod Gelap';

  @override
  String get systemDefault => 'Lalai Sistem';

  @override
  String get chooseLanguage => 'Pilih Bahasa';

  @override
  String get chooseTheme => 'Pilih Tema';

  @override
  String get light => 'Cerah';

  @override
  String get dark => 'Gelap';

  @override
  String get clearAllDataTitle => 'Padam Semua Data';

  @override
  String get clearAllDataConfirm =>
      'Ini akan memadam semua penanda, muat turun, statistik, dan tetapan. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get clearAllDataButton => 'Padam Semua';

  @override
  String get done => 'Selesai';

  @override
  String get allDataCleared => 'Semua data dipadam. Mulakan semula aplikasi.';

  @override
  String get dailyReflectionLabel => 'RENUNGAN HARIAN';

  @override
  String get listen => 'Dengar';

  @override
  String get save => 'Simpan';

  @override
  String get share => 'Kongsi';

  @override
  String get previousReflections => 'Renungan Sebelumnya';

  @override
  String get viewAllButton => 'Lihat Semua';

  @override
  String get addReflection => 'Tambah Renungan';

  @override
  String get myReflection => 'RENUNGAN SAYA';

  @override
  String get reflectionHint => 'Bagaimana ayat ini bergema dengan hari anda?';

  @override
  String get clear => 'Padam';

  @override
  String get saveNote => 'Simpan Nota';

  @override
  String get saved => 'Disimpan';

  @override
  String get reflectionCleared => 'Renungan anda telah dipadam.';

  @override
  String get reflectionSaved => 'Renungan anda telah disimpan.';

  @override
  String get selectAyah => 'PILIH AYAT';

  @override
  String get selectAyahDefault => 'Pilih Ayat';

  @override
  String get yourReflection => 'RENUNGAN ANDA';

  @override
  String get saveReflection => 'Simpan Renungan';

  @override
  String get selectAyahSheet => 'Pilih Ayat';

  @override
  String get empty => 'Kosong';

  @override
  String get pleaseWriteReflection =>
      'Sila tulis renungan anda terlebih dahulu.';

  @override
  String get reflectionHasSaved => 'Renungan anda telah disimpan.';

  @override
  String get allReflections => 'SEMUA RENUNGAN';

  @override
  String get yourReflections => 'Renungan Anda';

  @override
  String get noMoreReflections => 'Tiada renungan lagi';

  @override
  String get noMoreReflectionsSubtitle =>
      'Ketik \"Tambah Renungan\" untuk menyimpan fikiran anda tentang mana-mana ayat.';

  @override
  String get addFirstReflection => 'Tambah Renungan Pertama Anda';

  @override
  String get onboardingSkip => 'Langkau';

  @override
  String get onboardingNext => 'Seterusnya';

  @override
  String get onboardingGetStarted => 'MULAKAN';

  @override
  String get onboardingBack => 'Kembali';

  @override
  String get onboardingSlide1Title => 'Temui Bacaan Al-Quran';

  @override
  String get onboardingSlide1Body =>
      'Hayati kalam ilahi melalui suara-suara paling indah di dunia dalam ruang yang direka untuk jiwa anda.';

  @override
  String get onboardingSlide2Title => 'Dengar di Mana-mana';

  @override
  String get onboardingSlide2Body =>
      'Muat turun bacaan kegemaran anda dan dengar secara luar talian, walaupun di tempat paling terpencil.';

  @override
  String get onboardingSlide3Title => 'Belajar dan Renung';

  @override
  String get onboardingSlide3Body =>
      'Selami lebih dalam hikmah ilahi dengan Tafsir perkataan demi perkataan dan penanda buku tersusun untuk perjalanan rohani anda.';
}
