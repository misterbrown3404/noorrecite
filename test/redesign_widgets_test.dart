import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/core/widgets/floating_nav_dock.dart';
import 'package:qari_verse/core/widgets/animations.dart';

void main() {
  testWidgets('navigation fits a small phone and selects the requested tab', (
    tester,
  ) async {
    tester.view.reset();
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: FloatingNavDock(
            items: FloatingNavDock.mainTabs,
            currentIndex: 0,
            onTap: (value) => selected = value,
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Listen'));
    expect(selected, 2);
  });
  testWidgets('reduced motion shows entrance content immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: FadeInUp(delay: Duration(seconds: 1), child: Text('Ready')),
        ),
      ),
    );
    expect(find.text('Ready'), findsOneWidget);
    expect(find.byType(Opacity), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), isNull);
  });
}
