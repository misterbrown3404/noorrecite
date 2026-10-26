import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:qari_verse/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'onboarding fits a small phone and advances with reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const OnboardingPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Make room for Quran'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final next = find.widgetWithText(FilledButton, 'Next');
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('Find your favorite voice'), findsOneWidget);
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(find.text('Bring faith into your day'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'GET STARTED'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
