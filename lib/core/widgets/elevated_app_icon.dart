import 'package:celebray/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// App icon with Material elevation on dark splash/loading screens.
class ElevatedAppIcon extends StatelessWidget {
  const ElevatedAppIcon({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = size * 0.223;

    return Material(
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: 0.55),
      color: AppTheme.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/splash_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
