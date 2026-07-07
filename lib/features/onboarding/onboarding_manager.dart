import 'package:celebray/features/home/home_screen.dart';
import 'package:celebray/features/onboarding/onboarding_screen.dart';
import 'package:celebray/models/app_user.dart';
import 'package:celebray/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager extends StatefulWidget {
  const OnboardingManager({super.key});

  @override
  State<OnboardingManager> createState() => _OnboardingManagerState();
}

class _OnboardingManagerState extends State<OnboardingManager> {
  late final Future<_StartupState> _startupFuture;

  @override
  void initState() {
    super.initState();
    _startupFuture = _loadStartupState();
  }

  Future<_StartupState> _loadStartupState() async {
    final prefs = await SharedPreferences.getInstance();
    final isOnboarded = prefs.getBool('isOnboarded') ?? false;
    final user = await AuthService().restoreSession();
    return _StartupState(isOnboarded: isOnboarded, user: user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StartupState>(
      future: _startupFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final state = snapshot.data;
        if (state?.isOnboarded == true) {
          return const HomeScreen();
        }

        return const OnboardingScreen();
      },
    );
  }
}

class _StartupState {
  final bool isOnboarded;
  final AppUser? user;

  const _StartupState({required this.isOnboarded, this.user});
}
