import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test - onboarding screen loads', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const OnboardingScreen(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Celebray'), findsWidgets);
  });
}
