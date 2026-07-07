import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/messages/message_tones.dart';
import 'package:flutter/material.dart';

/// Grid tone selector — all options visible, no horizontal scroll.
class TonePicker extends StatelessWidget {
  final ValueNotifier<String> toneNotifier;
  final List<String> tones;

  const TonePicker({
    super.key,
    required this.toneNotifier,
    this.tones = MessageTones.all,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tone',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ValueListenableBuilder<String>(
          valueListenable: toneNotifier,
          builder: (context, selectedTone, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 8.0;
                const columns = 3;
                final cellWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: tones.map((tone) {
                    final selected = selectedTone == tone;
                    return SizedBox(
                      width: cellWidth,
                      child: _ToneOption(
                        label: MessageTones.label(tone),
                        selected: selected,
                        onTap: () => toneNotifier.value = tone,
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ToneOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToneOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryLight : AppTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.accentDark : AppTheme.textSecondary,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
