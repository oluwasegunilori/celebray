import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/auth/presentation/sign_in_screen.dart';
import 'package:celebray/features/home/presentation/home_screen.dart';
import 'package:celebray/features/notifications/notification_navigation_handler.dart';
import 'package:celebray/features/onboarding/presentation/onboarding_gate.dart';
import 'package:celebray/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';

class CelebrayApp extends StatelessWidget {
  final Widget? initialHome;

  const CelebrayApp({super.key, this.initialHome});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebray',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: initialHome == null,
      navigatorKey: NotificationNavigationHandler.navigatorKey,
      home: initialHome ?? const OnboardingGate(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/sign-in': (context) => SignInScreen(
              onSignedIn: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
      },
    );
  }
}
