import 'package:celebray/app.dart';
import 'package:celebray/core/database/app_database.dart';
import 'package:celebray/core/database/app_database_provider.dart';
import 'package:celebray/core/demo/app_store_demo_data.dart';
import 'package:celebray/features/auth/data/google_sign_in_bootstrap.dart';
import 'package:celebray/features/home/presentation/home_screen.dart';
import 'package:celebray/features/notifications/notification_navigation_handler.dart';
import 'package:celebray/features/notifications/notification_service.dart';
import 'package:celebray/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const screenshotDatabaseFile = 'app_store_screenshots.db';

Future<AppDatabase> openScreenshotDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = '$dbPath/$screenshotDatabaseFile';
  await deleteDatabase(path);
  return AppDatabase.open(fileName: screenshotDatabaseFile);
}

Future<void> seedScreenshotDatabase(AppDatabase database) async {
  for (final event in AppStoreDemoData.entities()) {
    await database.insertEvent(event);
  }
}

Future<void> bootstrapScreenshotApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignInBootstrap.initialize();

  await NotificationService.init(
    onNotificationResponse: NotificationNavigationHandler.handleNotificationResponse,
  );

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isOnboarded', true);

  final db = await openScreenshotDatabase();
  await seedScreenshotDatabase(db);

  NotificationNavigationHandler.bindDatabase(db);

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const CelebrayApp(
        initialHome: HomeScreen(),
      ),
    ),
  );
}
