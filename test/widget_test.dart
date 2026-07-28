// Smoke test for the QariVerse app shell.
//
// Verifies the app boots into the splash screen without exceptions.

import 'package:QariVerse/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

//import 'package:noorrecite/app/app.dart';

void main() {
  testWidgets('App boots into the splash screen', (tester) async {
    await tester.pumpWidget(const QariVerseApp());
    await tester.pump();

    expect(find.text('QariVerse'), findsOneWidget);
    expect(find.text('BISMILLAH'), findsOneWidget);

    // Drain one-shot animation timers (FadeInUp: 400ms delay + 900ms duration).
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
  });
}
