import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CelebrayApp());
}

class CelebrayApp extends StatelessWidget {
  const CelebrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celebray',
      theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
      initialRoute: '/',
      routes: {'/': (_) => OnboardingScreen()},
    );
  }
}
