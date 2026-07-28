abstract final class ApiEndpoints {
  static const String reciters = 'reciters';
  static const String suwar = 'suwar';

  /// Audio URL: {server}{surahNumber padded to 3 digits}.mp3
  /// e.g. https://server6.mp3quran.net/akdr/001.mp3
  static String audioUrl(String server, int surahNumber) =>
      '$server${surahNumber.toString().padLeft(3, '0')}.mp3';
}
