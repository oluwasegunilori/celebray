import 'package:celebray/app.dart';
import 'package:celebray/core/database/app_database.dart';
import 'package:celebray/core/database/app_database_provider.dart';
import 'package:celebray/features/auth/data/google_sign_in_bootstrap.dart';
import 'package:celebray/features/notifications/notification_navigation_handler.dart';
import 'package:celebray/features/notifications/notification_service.dart';
import 'package:celebray/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await GoogleSignInBootstrap.initialize();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await NotificationService.init(
    onNotificationResponse: NotificationNavigationHandler.handleNotificationResponse,
  );
  await NotificationService.requestPermissions();

  final db = await AppDatabase.open();
  NotificationNavigationHandler.bindDatabase(db);
  await NotificationNavigationHandler.captureColdStartLaunch();

  final events = await db.watchAllEvents().first;
  await NotificationService.rescheduleAll(events);
  await UpcomingWidgetService.syncEvents(events);

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const CelebrayApp(),
    ),
  );
}
