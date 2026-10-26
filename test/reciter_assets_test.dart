import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/core/constants/app_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('every mapped portrait decodes and has matching attribution', () async {
    final sources =
        (jsonDecode(
                  await File(
                    'assets/images/reciter_sources.json',
                  ).readAsString(),
                )
                as List)
            .cast<Map<String, dynamic>>();
    expect(sources.map((s) => s['id']).toSet().length, sources.length);
    expect(AppAssets.reciterImages.length, sources.length);
    for (final source in sources) {
      expect(AppAssets.reciterImage(source['id'] as int), source['asset']);
      expect(source['license'], isNotEmpty);
      expect(source['author'], isNotEmpty);
      expect(
        Uri.parse(source['source'] as String).host,
        isIn(['commons.wikimedia.org', 'ar.assabile.com', 'recitid.ai']),
      );
      final codec = await ui.instantiateImageCodec(
        await File(source['asset'] as String).readAsBytes(),
      );
      final frame = await codec.getNextFrame();
      expect(frame.image.width, greaterThan(0));
      frame.image.dispose();
      codec.dispose();
    }
  });
  test('unknown reciters never inherit somebody else’s face', () {
    expect(AppAssets.reciterImage(999999), isNull);
    expect(AppAssets.reciterImage(-1), isNull);
  });
}
