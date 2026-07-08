import 'package:flutter/material.dart';

enum CardTextAlignment { left, center, right }

class CardColorTheme {
  final String name;
  final List<Color> gradient;
  final Color textColor;
  final Color brandColor;
  final Color messageBoxColor;

  const CardColorTheme({
    required this.name,
    required this.gradient,
    required this.textColor,
    required this.brandColor,
    required this.messageBoxColor,
  });
}

class CardTypographyStyle {
  final String name;
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final double letterSpacing;
  final double height;
  final bool showQuoteMarks;

  const CardTypographyStyle({
    required this.name,
    required this.fontFamily,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.fontStyle = FontStyle.normal,
    this.letterSpacing = 0,
    this.height = 1.65,
    this.showQuoteMarks = false,
  });
}

class CardStyles {
  CardStyles._();

  static const defaultAlignment = CardTextAlignment.center;

  static const alignmentOptions = <CardTextAlignment>[
    CardTextAlignment.left,
    CardTextAlignment.center,
    CardTextAlignment.right,
  ];

  static String alignmentLabel(CardTextAlignment alignment) {
    return switch (alignment) {
      CardTextAlignment.left => 'Left',
      CardTextAlignment.center => 'Center',
      CardTextAlignment.right => 'Right',
    };
  }
  static const colors = <CardColorTheme>[
    CardColorTheme(
      name: 'Midnight',
      gradient: [Color(0xFF111111), Color(0xFF333333)],
      textColor: Colors.white,
      brandColor: Color(0xB3FFFFFF),
      messageBoxColor: Color(0x26FFFFFF),
    ),
    CardColorTheme(
      name: 'Gold',
      gradient: [Color(0xFFD4A017), Color(0xFF9A7209)],
      textColor: Colors.white,
      brandColor: Color(0xCCFFFFFF),
      messageBoxColor: Color(0x24FFFFFF),
    ),
    CardColorTheme(
      name: 'Onyx Gold',
      gradient: [Color(0xFF111111), Color(0xFFD4A017)],
      textColor: Colors.white,
      brandColor: Color(0xB3FFFFFF),
      messageBoxColor: Color(0x22FFFFFF),
    ),
    CardColorTheme(
      name: 'Charcoal',
      gradient: [Color(0xFF2D2D2D), Color(0xFF111111)],
      textColor: Colors.white,
      brandColor: Color(0xB3FFFFFF),
      messageBoxColor: Color(0x24FFFFFF),
    ),
    CardColorTheme(
      name: 'Slate',
      gradient: [Color(0xFF4A4A4A), Color(0xFF1A1A1A)],
      textColor: Colors.white,
      brandColor: Color(0xB3FFFFFF),
      messageBoxColor: Color(0x24FFFFFF),
    ),
    CardColorTheme(
      name: 'Wine',
      gradient: [Color(0xFF4A1C2B), Color(0xFF8B2942)],
      textColor: Colors.white,
      brandColor: Color(0xCCFFFFFF),
      messageBoxColor: Color(0x28FFFFFF),
    ),
    CardColorTheme(
      name: 'Ocean',
      gradient: [Color(0xFF0D1B2A), Color(0xFF1B4965)],
      textColor: Colors.white,
      brandColor: Color(0xB3FFFFFF),
      messageBoxColor: Color(0x24FFFFFF),
    ),
    CardColorTheme(
      name: 'Forest',
      gradient: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
      textColor: Colors.white,
      brandColor: Color(0xB3FFFFFF),
      messageBoxColor: Color(0x24FFFFFF),
    ),
    CardColorTheme(
      name: 'Rose',
      gradient: [Color(0xFF7B3F61), Color(0xFFC97B93)],
      textColor: Colors.white,
      brandColor: Color(0xCCFFFFFF),
      messageBoxColor: Color(0x28FFFFFF),
    ),
    CardColorTheme(
      name: 'Plum',
      gradient: [Color(0xFF3D1C52), Color(0xFF6B3A7D)],
      textColor: Colors.white,
      brandColor: Color(0xB3FFFFFF),
      messageBoxColor: Color(0x24FFFFFF),
    ),
    CardColorTheme(
      name: 'Sunset',
      gradient: [Color(0xFF7B2D26), Color(0xFFD4A017)],
      textColor: Colors.white,
      brandColor: Color(0xCCFFFFFF),
      messageBoxColor: Color(0x24FFFFFF),
    ),
    CardColorTheme(
      name: 'Ivory',
      gradient: [Color(0xFFFAF7F0), Color(0xFFE8DFC8)],
      textColor: Color(0xFF1A1A1A),
      brandColor: Color(0xFF6B6B6B),
      messageBoxColor: Color(0x1A111111),
    ),
  ];

  static const typography = <CardTypographyStyle>[
    CardTypographyStyle(
      name: 'Elegant',
      fontFamily: 'Playfair Display',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      height: 1.65,
      showQuoteMarks: true,
    ),
    CardTypographyStyle(
      name: 'Modern',
      fontFamily: 'Montserrat',
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.75,
      letterSpacing: 0.2,
    ),
    CardTypographyStyle(
      name: 'Classic',
      fontFamily: 'Lora',
      fontSize: 20,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      height: 1.7,
    ),
    CardTypographyStyle(
      name: 'Statement',
      fontFamily: 'Oswald',
      fontSize: 23,
      fontWeight: FontWeight.w600,
      height: 1.6,
      letterSpacing: 0.6,
    ),
    CardTypographyStyle(
      name: 'Clean',
      fontFamily: 'Inter',
      fontSize: 19,
      fontWeight: FontWeight.w400,
      height: 1.75,
      letterSpacing: 0.1,
    ),
    CardTypographyStyle(
      name: 'Script',
      fontFamily: 'Dancing Script',
      fontSize: 26,
      fontWeight: FontWeight.w600,
      height: 1.6,
    ),
  ];

  static CardColorTheme colorAt(int index) =>
      colors[index % colors.length];

  static CardTypographyStyle typographyAt(int index) =>
      typography[index % typography.length];

  static Alignment geometryAlignment(CardTextAlignment alignment) {
    return switch (alignment) {
      CardTextAlignment.left => Alignment.centerLeft,
      CardTextAlignment.center => Alignment.center,
      CardTextAlignment.right => Alignment.centerRight,
    };
  }

  static TextAlign textAlign(CardTextAlignment alignment) {
    return switch (alignment) {
      CardTextAlignment.left => TextAlign.left,
      CardTextAlignment.center => TextAlign.center,
      CardTextAlignment.right => TextAlign.right,
    };
  }

  static double messageFontSize(String message, double base) {
    final length = message.trim().length;
    if (length > 200) return base * 0.72;
    if (length > 150) return base * 0.82;
    if (length > 100) return base * 0.9;
    return base;
  }
}
