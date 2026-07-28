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
  static const mosqueLandscape = '$_img/home_dashboard__1.jpg';
  static const userAvatar = '$_img/home_dashboard__5.jpg';

  // Reading heroes / artwork.
  static const quranOnVelvet = '$_img/audio_player_screen__1.jpg';
  static const quranOnCushion = '$_img/bookmarks_screen__1.jpg';
  static const fatihaPage = '$_img/full_quran_screen__2.jpg';
  static const lanternsBg = '$_img/daily_reflection_screen__1.jpg';
  static const goldOrnament = '$_img/premium_subscription_screen__1.jpg';
  static const profileAvatar = '$_img/profile_screen__1.jpg';

  /// Reciter portraits, indexed to align with [reciterPortraits].
  static const reciterMishary = '$_img/download_center__2.jpg';
  static const reciterSudais = '$_img/reciters_screen__7.jpg';
  static const reciterNigeria = '$_img/reciters_screen__3.jpg';
  static const reciterIndonesia = '$_img/reciters_screen__2.jpg';
  static const reciterEgypt = '$_img/reciters_screen__8.jpg';
  static const reciterSaudiYoung = '$_img/reciters_screen__1.jpg';
  static const reciterIran = '$_img/reciters_screen__5.jpg';
  static const reciterMorocco = '$_img/reciters_screen__6.jpg';
  static const reciterOman = '$_img/reciters_screen__4.jpg';

  /// Maps reciter API IDs to portrait assets. Reciters not in this map
  /// fall back to a generic avatar in the UI.
  static const Map<int, String> reciterImages = {
    1: reciterSudais,
    2: reciterSudais,
    3: reciterSudais,
    4: reciterSudais,
    5: reciterSudais,
    6: reciterSudais,
    7: reciterSudais,
    8: reciterSudais,
    9: reciterSudais,
    10: reciterSudais,
    11: reciterSudais,
    12: reciterSudais,
    13: reciterSudais,
    14: reciterSudais,
    15: reciterSaudiYoung,
    16: reciterSaudiYoung,
    17: reciterSaudiYoung,
    18: reciterSaudiYoung,
    19: reciterSudais,
    20: reciterSudais,
    21: reciterSudais,
    22: reciterSudais,
    23: reciterSudais,
    24: reciterSaudiYoung,
    25: reciterSudais,
    26: reciterSaudiYoung,
    27: reciterSudais,
    28: reciterSudais,
    29: reciterSudais,
    30: reciterSaudiYoung,
    31: reciterSudais,
    32: reciterSaudiYoung,
    33: reciterSudais,
    34: reciterSaudiYoung,
    35: reciterSudais,
    36: reciterSaudiYoung,
    37: reciterSudais,
    38: reciterSaudiYoung,
    39: reciterSudais,
    40: reciterSaudiYoung,
    41: reciterSaudiYoung,
    42: reciterSaudiYoung,
    43: reciterSaudiYoung,
    44: reciterSaudiYoung,
    46: reciterSaudiYoung,
    47: reciterSaudiYoung,
    48: reciterSaudiYoung,
    49: reciterSudais,
    50: reciterSaudiYoung,
    51: reciterEgypt,
    52: reciterSudais,
    54: reciterSudais,
    55: reciterSaudiYoung,
    56: reciterSaudiYoung,
    57: reciterSaudiYoung,
    58: reciterSudais,
    59: reciterSudais,
    60: reciterSaudiYoung,
    61: reciterSudais,
    62: reciterSudais,
    63: reciterSudais,
    64: reciterSaudiYoung,
    66: reciterSaudiYoung,
    67: reciterSaudiYoung,
    68: reciterSaudiYoung,
    69: reciterSaudiYoung,
    70: reciterSaudiYoung,
    71: reciterSaudiYoung,
    72: reciterSaudiYoung,
    73: reciterSaudiYoung,
    74: reciterSaudiYoung,
    76: reciterSaudiYoung,
    77: reciterSudais,
    78: reciterSaudiYoung,
    79: reciterSaudiYoung,
    80: reciterSaudiYoung,
    81: reciterSudais,
    82: reciterSaudiYoung,
    83: reciterSaudiYoung,
    84: reciterSaudiYoung,
    85: reciterSaudiYoung,
    86: reciterSaudiYoung,
    87: reciterSaudiYoung,
    88: reciterSaudiYoung,
    89: reciterSaudiYoung,
    90: reciterSaudiYoung,
    91: reciterSaudiYoung,
    92: reciterSaudiYoung,
    93: reciterSaudiYoung,
    94: reciterSaudiYoung,
    95: reciterSaudiYoung,
    96: reciterSaudiYoung,
    97: reciterSaudiYoung,
    98: reciterSaudiYoung,
    100: reciterSaudiYoung,
    102: reciterSudais,
    112: reciterEgypt,
    118: reciterEgypt,
    121: reciterSudais,
    123: reciterMishary,
    125: reciterSudais,
    128: reciterIndonesia,
    138: reciterMorocco,
    150: reciterSaudiYoung,
    152: reciterSudais,
  };

  /// Returns the asset path for a reciter portrait, or null if unmapped.
  static String? reciterImage(int reciterId) => reciterImages[reciterId];
}
