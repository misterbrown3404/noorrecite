import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/core/storage/local_storage_service.dart';
import 'package:qari_verse/features/azkar/presentation/pages/tasbih_page.dart';
import 'package:qari_verse/features/home/presentation/controllers/prayer_times_controller.dart';
import 'package:qari_verse/features/home/presentation/widgets/azkar_card.dart';
import 'package:qari_verse/features/home/presentation/widgets/next_prayer_card.dart';

class _UnusedStorage implements LocalStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget host(Widget child) => MaterialApp(
  home: MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: child,
  ),
);

void main() {
  testWidgets('Azkar counts independently and reset requires confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(host(const TasbihPage()));
    await tester.pumpAndSettle();
    final tap = find.text('Tap to count');
    await tester.ensureVisible(tap);
    await tester.pumpAndSettle();
    await tester.tap(tap);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tahmid'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.text('Tasbih'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byTooltip('Reset current counter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('worship cards fit a narrow phone and show prayer states', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = PrayerTimesController(_UnusedStorage());
    await tester.pumpWidget(
      host(
        Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              NextPrayerCard(controller: controller),
              const SizedBox(height: 16),
              const AzkarCard(),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Finding your\nprayer times'), findsOneWidget);
    controller.isLoading(false);
    controller.error(
      'Location services are off. Turn them on for prayer times.',
    );
    await tester.pumpAndSettle();
    expect(find.text('Try location again'), findsOneWidget);
    expect(tester.takeException(), isNull);
    controller.error('');
    controller.nextPrayer.value = PrayerTimeInfo(
      name: 'Dhuhr',
      time: DateTime(2026, 10, 25, 12, 30),
      isNext: true,
      timeRemaining: const Duration(hours: 1),
    );
    controller.currentPrayer.value = PrayerTimeInfo(
      name: 'Fajr',
      time: DateTime(2026, 10, 25, 5, 30),
      isNext: false,
      timeRemaining: Duration.zero,
    );
    controller.afterSunrise.value = true;
    controller.hijriDate.value = '14 Jumada Al-Awwal 1448 AH';
    controller.remaining.value = const Duration(hours: 1);
    await tester.pumpAndSettle();
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('5:30 AM'), findsOneWidget);
    expect(find.text('LAST PRAYER'), findsOneWidget);
    expect(find.text('14 Jumada Al-Awwal 1448 AH'), findsOneWidget);
    expect(find.text('In 1h 0m 0s'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.onClose();
  });
}
