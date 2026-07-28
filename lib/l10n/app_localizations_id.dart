// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'QariVerse';

  @override
  String get greeting => 'Assalamu Alaikum,';

  @override
  String get nextPrayer => 'SHOLAT BERIKUTNYA';

  @override
  String get unableToLoadPrayerTimes => 'Tidak dapat memuat waktu sholat';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get continueListening => 'LANJUTKAN MENDENGARKAN';

  @override
  String get dailyAyah => 'AYAT HARIAN';

  @override
  String get popularReciters => 'Qari Populer';

  @override
  String get viewAll => 'LIHAT SEMUA';

  @override
  String get quranTitle => 'Al-Quran';

  @override
  String get allSurahs => 'Semua Surah';

  @override
  String get juz => 'Juz';

  @override
  String get makkah => 'Makkiyah';

  @override
  String get madinah => 'Madaniyah';

  @override
  String get bookmarksFilter => 'Bookmark';

  @override
  String get searchHint => 'Cari Surah, Juz, atau Kata Kunci...';

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
  String get nowPlaying => 'Sedang Diputar';

  @override
  String get removeDownload => 'Hapus Unduhan';

  @override
  String deleteOfflineCopy(String surahName) {
    return 'Hapus salinan offline dari $surahName?';
  }

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Hapus';

  @override
  String get queue => 'ANTRIAN';

  @override
  String get noSurahsInQueue => 'Tidak ada surah dalam antrian';

  @override
  String surahSubtitle(String surahName, String reciterName) {
    return 'Surah $surahName · $reciterName';
  }

  @override
  String get downloadsTitle => 'Unduhan';

  @override
  String get manageOfflineLibrary => 'Kelola perpustakaan Quran offline Anda';

  @override
  String get offlineMode => 'MODE OFFLINE';

  @override
  String get storageUsage => 'PENGGUNAAN PENYIMPANAN';

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
  String get clearAll => 'HAPUS SEMUA';

  @override
  String get downloadedByReciter => 'DIUNDUH PER QARI';

  @override
  String get clearAllDownloads => 'Hapus semua unduhan';

  @override
  String get clearAllDownloadsConfirm =>
      'Ini akan menghapus semua surah yang diunduh dari perangkat ini. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get clearAllButton => 'Hapus semua';

  @override
  String get noDownloadsYet => 'Belum ada unduhan';

  @override
  String get noDownloadsSubtitle =>
      'Ketuk ikon unduh di pemutar untuk menyimpan surah untuk didengarkan secara offline.';

  @override
  String get bookmarksTitle => 'Bookmark';

  @override
  String get myBookmarks => 'Bookmark Saya';

  @override
  String savedAyahs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ayat Tersimpan',
      one: '$count Ayat Tersimpan',
    );
    return '$_temp0';
  }

  @override
  String get lastReadBadge => 'Terakhir Dibaca';

  @override
  String get noSurahOpenedYet => 'Belum ada surah yang dibuka';

  @override
  String get openSurahFromQuranTab => 'Buka surah dari tab Quran';

  @override
  String ayahAndPages(int ayah, int start, int end) {
    return 'Ayat $ayah • Halaman $start–$end';
  }

  @override
  String get continueReading => 'Lanjutkan Membaca';

  @override
  String get noBookmarksYet => 'Belum Ada Bookmark';

  @override
  String get noBookmarksSubtitle =>
      'Mulai simpan ayat favorit Anda untuk membangun perbendaharaan spiritual pribadi.';

  @override
  String get exploreQuran => 'Jelajahi Quran';

  @override
  String get recitersTitle => 'Qari';

  @override
  String get featuredReciters => 'Qari Unggulan';

  @override
  String get searchRecitersHint => 'Cari berdasarkan nama atau gaya...';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get appearance => 'TAMPILAN';

  @override
  String get theme => 'Tema';

  @override
  String get language => 'Bahasa';

  @override
  String get notifications => 'NOTIFIKASI';

  @override
  String get prayerTimesReminders => 'Waktu Sholat & Pengingat';

  @override
  String get prayerTimesSubtitle => 'Dapatkan notifikasi untuk waktu sholat';

  @override
  String get dailyReflectionReminder => 'Pengingat Renungan Harian';

  @override
  String get dailyReflectionSubtitle =>
      'Pengingat lembut untuk ayat harian Anda';

  @override
  String get offline => 'OFFLINE';

  @override
  String get offlineModeTitle => 'Mode Offline';

  @override
  String get offlineModeSubtitle => 'Putar hanya surah yang diunduh';

  @override
  String get dataPrivacy => 'DATA & PRIVASI';

  @override
  String get clearAllData => 'Hapus Semua Data';

  @override
  String get clearAllDataSubtitle => 'Reset aplikasi ke kondisi awal';

  @override
  String get about => 'TENTANG';

  @override
  String get supportApp => 'Dukung Aplikasi Ini';

  @override
  String get supportAppSubtitle => 'Sedekah gratis — donasi jika bermanfaat';

  @override
  String get version => 'Versi';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get systemDefault => 'Default Sistem';

  @override
  String get chooseLanguage => 'Pilih Bahasa';

  @override
  String get chooseTheme => 'Pilih Tema';

  @override
  String get light => 'Terang';

  @override
  String get dark => 'Gelap';

  @override
  String get clearAllDataTitle => 'Hapus Semua Data';

  @override
  String get clearAllDataConfirm =>
      'Ini akan menghapus semua bookmark, unduhan, statistik, dan pengaturan. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get clearAllDataButton => 'Hapus Semua';

  @override
  String get done => 'Selesai';

  @override
  String get allDataCleared => 'Semua data dihapus. Mulai ulang aplikasi.';

  @override
  String get dailyReflectionLabel => 'RENUNGAN HARIAN';

  @override
  String get listen => 'Dengarkan';

  @override
  String get save => 'Simpan';

  @override
  String get share => 'Bagikan';

  @override
  String get previousReflections => 'Renungan Sebelumnya';

  @override
  String get viewAllButton => 'Lihat Semua';

  @override
  String get addReflection => 'Tambah Renungan';

  @override
  String get myReflection => 'RENUNGAN SAYA';

  @override
  String get reflectionHint =>
      'Bagaimana ayat ini beresonansi dengan hari Anda?';

  @override
  String get clear => 'Hapus';

  @override
  String get saveNote => 'Simpan Catatan';

  @override
  String get saved => 'Tersimpan';

  @override
  String get reflectionCleared => 'Renungan Anda telah dihapus.';

  @override
  String get reflectionSaved => 'Renungan Anda telah disimpan.';

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
      'Silakan tulis renungan Anda terlebih dahulu.';

  @override
  String get reflectionHasSaved => 'Renungan Anda telah disimpan.';

  @override
  String get allReflections => 'SEMUA RENUNGAN';

  @override
  String get yourReflections => 'Renungan Anda';

  @override
  String get noMoreReflections => 'Belum ada renungan lagi';

  @override
  String get noMoreReflectionsSubtitle =>
      'Ketuk \"Tambah Renungan\" untuk menyimpan pikiran Anda tentang ayat apa pun.';

  @override
  String get addFirstReflection => 'Tambahkan Renungan Pertama Anda';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingNext => 'Berikutnya';

  @override
  String get onboardingGetStarted => 'MULAI';

  @override
  String get onboardingBack => 'Kembali';

  @override
  String get onboardingSlide1Title => 'Temukan Lantunan Al-Quran';

  @override
  String get onboardingSlide1Body =>
      'Rasakan firman ilahi melalui suara-suara terindah di dunia dalam ruang yang dirancang untuk jiwa Anda.';

  @override
  String get onboardingSlide2Title => 'Dengarkan di Mana Saja';

  @override
  String get onboardingSlide2Body =>
      'Unduh lantunan favorit Anda dan dengarkan secara offline, bahkan di tempat paling terpencil.';

  @override
  String get onboardingSlide3Title => 'Belajar dan Merenung';

  @override
  String get onboardingSlide3Body =>
      'Selami lebih dalam hikmah ilahi dengan Tafsir kata demi kata dan penanda yang terorganisir untuk perjalanan spiritual Anda.';
}
