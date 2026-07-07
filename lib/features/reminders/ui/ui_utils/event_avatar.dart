import 'dart:io';

import 'package:celebray/app_theme.dart';
import 'package:flutter/material.dart';

/// Displays a local event photo, or a fallback icon if the file is missing.
class EventAvatar extends StatelessWidget {
  final String? imagePath;
  final double size;
  final double borderRadius;
  final IconData fallbackIcon;

  const EventAvatar({
    super.key,
    required this.imagePath,
    this.size = 52,
    this.borderRadius = 14,
    this.fallbackIcon = Icons.celebration_outlined,
  });

  bool get _fileExists {
    if (imagePath == null || imagePath!.isEmpty) return false;
    return File(imagePath!).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: size,
        height: size,
        color: AppTheme.surfaceMuted,
        child: _fileExists
            ? Image.file(
                File(imagePath!),
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Icon(
      fallbackIcon,
      color: AppTheme.black,
      size: size * 0.46,
    );
  }

  static IconData iconForEventType(String type) {
    return switch (type.toLowerCase()) {
      'birthday' => Icons.cake_outlined,
      'anniversary' => Icons.favorite_border_rounded,
      'graduation' => Icons.school_outlined,
      'wedding' => Icons.diversity_2_outlined,
      _ => Icons.celebration_outlined,
    };
  }
}
