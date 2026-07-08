import 'package:celebray/features/sharing/models/card_style.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GreetingCardWidget extends StatelessWidget {
  final String message;
  final int colorIndex;
  final int typographyIndex;
  final CardTextAlignment alignment;

  const GreetingCardWidget({
    super.key,
    required this.message,
    this.colorIndex = 0,
    this.typographyIndex = 0,
    this.alignment = CardStyles.defaultAlignment,
  });

  TextStyle _messageStyle(CardColorTheme color, CardTypographyStyle typo) {
    final size = CardStyles.messageFontSize(message, typo.fontSize);
    return GoogleFonts.getFont(
      typo.fontFamily,
      fontSize: size,
      fontWeight: typo.fontWeight,
      fontStyle: typo.fontStyle,
      letterSpacing: typo.letterSpacing,
      height: typo.height,
      color: color.textColor,
    );
  }

  TextStyle _brandStyle(CardColorTheme color, CardTypographyStyle typo) {
    return GoogleFonts.getFont(
      typo.fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.4,
      color: color.brandColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = CardStyles.colorAt(colorIndex);
    final typo = CardStyles.typographyAt(typographyIndex);
    final align = CardStyles.textAlign(alignment);
    final geometry = CardStyles.geometryAlignment(alignment);

    return Container(
      width: 360,
      height: 520,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: color.gradient,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(40, 48, 40, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: geometry,
              child: SizedBox(
                width: double.infinity,
                child: typo.showQuoteMarks
                    ? _QuotedMessage(
                        message: message,
                        style: _messageStyle(color, typo),
                        align: align,
                        quoteColor: color.textColor.withValues(alpha: 0.25),
                      )
                    : _MessageBlock(
                        message: message,
                        style: _messageStyle(color, typo),
                        align: align,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 1,
                color: color.brandColor.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 10),
              Text('— Celebray', style: _brandStyle(color, typo)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBlock extends StatelessWidget {
  final String message;
  final TextStyle style;
  final TextAlign align;

  const _MessageBlock({
    required this.message,
    required this.style,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: align,
      style: style,
    );
  }
}

class _QuotedMessage extends StatelessWidget {
  final String message;
  final TextStyle style;
  final TextAlign align;
  final Color quoteColor;

  const _QuotedMessage({
    required this.message,
    required this.style,
    required this.align,
    required this.quoteColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -18,
          left: align == TextAlign.right ? null : (align == TextAlign.center ? 0 : -4),
          right: align == TextAlign.right ? -4 : (align == TextAlign.center ? 0 : null),
          child: align == TextAlign.center
              ? Text(
                  '“',
                  textAlign: TextAlign.center,
                  style: style.copyWith(
                    fontSize: (style.fontSize ?? 20) * 2.2,
                    color: quoteColor,
                    height: 1,
                  ),
                )
              : Text(
                  '“',
                  style: style.copyWith(
                    fontSize: (style.fontSize ?? 20) * 2.2,
                    color: quoteColor,
                    height: 1,
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            message,
            textAlign: align,
            style: style,
          ),
        ),
      ],
    );
  }
}

/// Rounded preview wrapper; [RepaintBoundary] inside stays square for export.
class GreetingCardPreview extends StatelessWidget {
  final GlobalKey cardKey;
  final String message;
  final int colorIndex;
  final int typographyIndex;
  final CardTextAlignment alignment;

  const GreetingCardPreview({
    super.key,
    required this.cardKey,
    required this.message,
    this.colorIndex = 0,
    this.typographyIndex = 0,
    this.alignment = CardStyles.defaultAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: RepaintBoundary(
        key: cardKey,
        child: GreetingCardWidget(
          message: message,
          colorIndex: colorIndex,
          typographyIndex: typographyIndex,
          alignment: alignment,
        ),
      ),
    );
  }
}
