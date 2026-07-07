import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/sharing/models/card_style.dart';
import 'package:flutter/material.dart';

class CardAlignmentPicker extends StatelessWidget {
  final CardTextAlignment selected;
  final ValueChanged<CardTextAlignment> onSelected;

  const CardAlignmentPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  IconData _iconFor(CardTextAlignment alignment) {
    return switch (alignment) {
      CardTextAlignment.left => Icons.format_align_left,
      CardTextAlignment.center => Icons.format_align_center,
      CardTextAlignment.right => Icons.format_align_right,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CardTextAlignment>(
      segments: CardStyles.alignmentOptions
          .map(
            (alignment) => ButtonSegment(
              value: alignment,
              label: Text(CardStyles.alignmentLabel(alignment)),
              icon: Icon(_iconFor(alignment), size: 18),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (selection) => onSelected(selection.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppTheme.black;
          return AppTheme.textSecondary;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppTheme.accentLight;
          return AppTheme.surfaceMuted;
        }),
        side: WidgetStateProperty.all(const BorderSide(color: AppTheme.border)),
      ),
    );
  }
}
