import 'package:celebray/features/sharing/models/card_style.dart';
import 'package:celebray/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardTypographyPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CardTypographyPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CardStyles.typography.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final style = CardStyles.typography[i];
          final selected = selectedIndex == i;

          return FilterChip(
            label: Text(
              style.name,
              style: GoogleFonts.getFont(
                style.fontFamily,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            selected: selected,
            onSelected: (_) => onSelected(i),
            showCheckmark: false,
            selectedColor: AppTheme.accentLight,
            side: BorderSide(
              color: selected ? AppTheme.accent : AppTheme.border,
            ),
            labelStyle: TextStyle(
              color: selected ? AppTheme.black : AppTheme.textSecondary,
            ),
          );
        },
      ),
    );
  }
}
