import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/messages/message_generator_service.dart';
import 'package:celebray/features/sharing/share_service.dart';
import 'package:celebray/features/sharing/models/card_style.dart';
import 'package:celebray/features/sharing/widgets/card_alignment_picker.dart';
import 'package:celebray/features/sharing/widgets/card_color_picker.dart';
import 'package:celebray/features/sharing/widgets/card_typography_picker.dart';
import 'package:celebray/features/sharing/widgets/greeting_card.dart';
import 'package:flutter/material.dart';

class ShareEventSheet extends StatefulWidget {
  final EventModel event;

  const ShareEventSheet({super.key, required this.event});

  static Future<void> show(BuildContext context, {required EventModel event}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShareEventSheet(event: event),
    );
  }

  @override
  State<ShareEventSheet> createState() => _ShareEventSheetState();
}

class _ShareEventSheetState extends State<ShareEventSheet> {
  int _colorIndex = 0;
  int _typographyIndex = 0;
  CardTextAlignment _alignment = CardStyles.defaultAlignment;
  final _cardKey = GlobalKey();

  EventModel get event => widget.event;

  String get _message => MessageGeneratorService.shareMessageFor(event);

  Future<void> _shareCard(BuildContext shareContext) async {
    await ShareService.shareGreetingCard(
      cardKey: _cardKey,
      shareContext: shareContext,
    );
  }

  Future<void> _shareText(BuildContext shareContext) async {
    await ShareService.shareMessage(
      message: _message,
      shareContext: shareContext,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Share ${event.name.isNotEmpty ? event.name : event.type}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pick a color and text style, then share.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Color',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                CardColorPicker(
                  selectedIndex: _colorIndex,
                  onSelected: (index) => setState(() => _colorIndex = index),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Text style',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                CardTypographyPicker(
                  selectedIndex: _typographyIndex,
                  onSelected: (index) =>
                      setState(() => _typographyIndex = index),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Alignment',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                CardAlignmentPicker(
                  selected: _alignment,
                  onSelected: (alignment) =>
                      setState(() => _alignment = alignment),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Preview',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.38,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: GreetingCardPreview(
                        cardKey: _cardKey,
                        message: _message,
                        colorIndex: _colorIndex,
                        typographyIndex: _typographyIndex,
                        alignment: _alignment,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Builder(
                  builder: (shareContext) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _shareCard(shareContext),
                      icon: const Icon(Icons.image),
                      label: const Text('Share Card'),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (shareContext) => SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _shareText(shareContext),
                      icon: const Icon(Icons.text_snippet_outlined),
                      label: const Text('Share as Text'),
                    ),
                  ),
                ),
                if (event.generatedMessage == null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Using a suggested message. Save a custom one from Generate Message.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
