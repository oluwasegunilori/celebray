import 'package:celebray/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Matches the native launch screen: black background, centered icon at 28% width.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppTheme.black,
      child: Center(
        child: FractionallySizedBox(
          widthFactor: 0.28,
          child: AspectRatio(
            aspectRatio: 1,
            child: Image(
              image: AssetImage('assets/splash_icon.png'),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
