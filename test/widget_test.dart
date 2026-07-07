import 'package:celebray/app_theme.dart';
import 'package:celebray/features/onboarding/onboarding_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test - onboarding manager loads', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const OnboardingManager(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Celebray'), findsWidgets);
  });
}
