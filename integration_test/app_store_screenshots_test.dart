import 'package:celebray/core/demo/screenshot_bootstrap.dart';
import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await IntegrationTestWidgetsFlutterBinding.instance.takeScreenshot(name);
}

Future<void> _tapBottomNav(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(ValueKey('bottom_nav_${label.toLowerCase()}')));
  await tester.pumpAndSettle();
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Store screenshots', () {
    testWidgets('capture iPhone marketing screens', (tester) async {
      await bootstrapScreenshotApp();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _capture(tester, '01_reminders');

      await _tapBottomNav(tester, 'Calendar');
      await _capture(tester, '02_calendar');

      await _tapBottomNav(tester, 'Generate');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mom — Birthday').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Generate Messages'));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await tester.drag(
        find.byType(Scrollable).last,
        const Offset(0, -420),
      );
      await tester.pumpAndSettle();
      await _capture(tester, '03_generator');

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await _capture(tester, '04_settings');
    });

    testWidgets('capture onboarding screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          home: const OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('05_onboarding_messages');
    });
  });
}
