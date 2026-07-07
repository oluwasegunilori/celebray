import 'package:celebray/features/sharing/models/card_style.dart';
import 'package:flutter/material.dart';

class CardColorPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CardColorPicker({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: CardStyles.colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final theme = CardStyles.colors[i];
          final selected = selectedIndex == i;

          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: theme.gradient),
                border: Border.all(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: theme.gradient.first.withValues(alpha: 0.45),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: selected
                  ? Icon(
                      Icons.check,
                      size: 18,
                      color: theme.textColor,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
