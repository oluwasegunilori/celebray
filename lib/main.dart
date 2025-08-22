import 'package:celebray/features/core/db/app_database.dart';
import 'package:celebray/features/core/db/app_database_provider.dart';
import 'package:celebray/features/home/home_screen.dart';
import 'package:celebray/features/signin/sign_in_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/onboarding_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AppDatabase db = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
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
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      home: const OnboardingManager(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/sign-in': (context) => SignInScreen(
          onSignedIn: () async {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      },
    );
  }
}
