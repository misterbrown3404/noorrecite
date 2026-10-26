/// Central catalogue of bundled image assets (downloaded from the Stitch
/// mockups into `assets/images/`). Referencing paths here keeps string literals
/// out of widgets and makes re-mapping trivial.
abstract final class AppAssets {
  static const _img = 'assets/images';

  // Entry flow.
  static const splashQuran = '$_img/splash_screen_2__1.jpg';
  static const onboardingDiscover = '$_img/onboarding_discover__1.jpg';
  static const onboardingReflect = '$_img/onboarding_reflect__1.jpg';
  static const authMosque = '$_img/authentication_screen__1.jpg';

  // Home.
  static const homeQuran = '$_img/home_quran_unsplash.jpg';
  static const mosqueLandscape = '$_img/home_dashboard__1.jpg';
  static const userAvatar = '$_img/home_dashboard__5.jpg';

  // Reading heroes / artwork.
  static const quranOnVelvet = '$_img/audio_player_screen__1.jpg';
  static const quranOnCushion = '$_img/bookmarks_screen__1.jpg';
  static const fatihaPage = '$_img/full_quran_screen__2.jpg';
  static const lanternsBg = '$_img/daily_reflection_screen__1.jpg';
  static const goldOrnament = '$_img/premium_subscription_screen__1.jpg';
  static const profileAvatar = '$_img/profile_screen__1.jpg';

  /// Verified reciter portraits matched to named source profiles.
  /// Sources and licenses: assets/images/reciter_sources.json.
  /// Unmapped reciters deliberately use the neutral UI avatar.
  static const Map<int, String> reciterImages = {
    6: 'assets/images/reciter_6.jpg', // Ahmad Al-Hawashi
    9: 'assets/images/reciter_9.jpg', // Ahmad Nauina
    13: 'assets/images/reciter_13.png', // Alzain Mohammad Ahmad
    16: 'assets/images/reciter_16.jpeg', // Aloyoon Al-Koshi
    30: 'assets/images/reciter_30.jpg', // Saad Al-Ghamdi
    31: 'assets/images/reciter_31.png', // Saud Al-Shuraim
    41: 'assets/images/reciter_41.jpg', // Saleh Al-Talib
    43: 'assets/images/reciter_43.jpg', // Salah Albudair
    48: 'assets/images/reciter_48.jpg', // Adel Ryyan
    51: 'assets/images/reciter_51.jpg', // Abdulbasit Abdulsamad
    54: 'assets/images/reciter_54.jpg', // Abdulrahman Alsudaes
    62: 'assets/images/reciter_62.png', // Abdullah Al-Johany
    67: 'assets/images/reciter_67.jpg', // Abdulmohsen Al-Qasim
    76: 'assets/images/reciter_76.jpeg', // Ali Jaber
    86: 'assets/images/reciter_86.jpg', // Nasser Alqatami
    92: 'assets/images/reciter_92.jpg', // Yasser Al-Dosari
    102: 'assets/images/reciter_102.png', // Maher Al Meaqli
    111: 'assets/images/reciter_111.png', // Mohammed Jibreel
    112: 'assets/images/reciter_112.jpg', // Mohammed Siddiq Al-Minshawi
    118: 'assets/images/reciter_118.jpg', // Mahmoud Khalil Al-Hussary
    123: 'assets/images/reciter_123.jpg', // Mishary Alafasi
    125: 'assets/images/reciter_125.jpg', // Mustafa Ismail
    128: 'assets/images/reciter_128.jpg', // Muamar (From Indonesia)
    160: 'assets/images/reciter_160.jpg', // Adel Al-Khalbany
    217: 'assets/images/reciter_217.jpg', // Bandar Balilah
    221: 'assets/images/reciter_221.png', // Raad Al Kurdi
    231: 'assets/images/reciter_231.jpg', // Hazza Al-Balushi
    241: 'assets/images/reciter_241.jpg', // Mohammad Refat
    254: 'assets/images/reciter_254.jpg', // Bader Alturki
    21203: 'assets/images/reciter_21203.jpg', // Ayman Rushdi Swaid
  };

  /// Returns the asset path for a reciter portrait, or null if unmapped.
  static String? reciterImage(int reciterId) => reciterImages[reciterId];
}
