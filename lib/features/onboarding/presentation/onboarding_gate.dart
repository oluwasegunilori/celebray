import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/widgets/elevated_app_icon.dart';
import 'package:celebray/features/auth/data/auth_service.dart';
import 'package:celebray/features/auth/domain/app_user.dart';
import 'package:celebray/features/home/presentation/home_screen.dart';
import 'package:celebray/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingGate extends StatefulWidget {
  const OnboardingGate({super.key});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
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
            backgroundColor: AppTheme.black,
            body: Center(
              child: ElevatedAppIcon(),
            ),
          );
        }

        if (snapshot.data?.isOnboarded == true) {
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
