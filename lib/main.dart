import 'package:celebray/app_theme.dart';
import 'package:celebray/features/core/db/app_database.dart';
import 'package:celebray/features/core/db/app_database_provider.dart';
import 'package:celebray/features/home/home_screen.dart';
import 'package:celebray/features/onboarding/onboarding_manager.dart';
import 'package:celebray/features/settings/settings_screen.dart';
import 'package:celebray/features/signin/sign_in_screen.dart';
import 'package:celebray/firebase_options.dart';
import 'package:celebray/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await NotificationService.init();
  await NotificationService.requestPermissions();

  final db = await AppDatabase.open();

  final events = await db.watchAllEvents().first;
  await NotificationService.rescheduleAll(events);

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebray',
      theme: AppTheme.light,
      home: const OnboardingManager(),
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
