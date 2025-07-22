import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import 'onboarding_screen.dart';

class OnboardingManager extends StatelessWidget {
  const OnboardingManager({super.key});

  Future<bool> _isUserOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isOnboarded') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserOnboarded(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data == true) {
          return const HomeScreen();
        } else {
          return const OnboardingScreen();
        }
      },
    );
  }
}
