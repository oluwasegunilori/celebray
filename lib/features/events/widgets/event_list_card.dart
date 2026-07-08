import 'package:celebray/core/theme/app_theme.dart';
import 'package:celebray/core/utils/event_date_utils.dart';
import 'package:celebray/core/widgets/event_avatar.dart';
import 'package:celebray/features/events/domain/event_model.dart';
import 'package:celebray/features/events/presentation/event_display_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class EventListCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showDateCountdown;
  final EdgeInsetsGeometry margin;

  const EventListCard({
    super.key,
    required this.event,
    this.onTap,
    this.trailing,
    this.showDateCountdown = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  });

  String _dateLabel(DateTime eventDate) {
    const weekThreshold = 7;
    final next = EventDateUtils.nextOccurrence(eventDate);
    final days = EventDateUtils.daysUntilNext(eventDate);

    if (days <= weekThreshold) {
      return timeago.format(next, locale: 'en', allowFromNow: true);
    }

    final now = DateTime.now();
    if (next.year == now.year) {
      return DateFormat('EEE, MMM d').format(next);
    }
    return DateFormat('EEE, MMM d, y').format(next);
  }

  @override
  Widget build(BuildContext context) {
    final labels = EventDisplayLabels.from(event);
    final hasMessage = event.generatedMessage?.trim().isNotEmpty ?? false;
    final days = EventDateUtils.daysUntilNext(event.date);
    final urgent = days <= 1;
    final withinWeek = days <= 7;

    return Padding(
      padding: margin,
      child: Material(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 12, trailing == null ? 12 : 4, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventAvatar(
                    imagePath: event.imagePath,
                    fallbackIcon: EventAvatar.iconForEventType(event.type),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                labels.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.black,
                                  height: 1.25,
                                ),
                              ),
                            ),
                            if (hasMessage) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: AppTheme.accent.withValues(alpha: 0.85),
                              ),
                            ],
                          ],
                        ),
                        if (labels.showTypeChip || labels.showRelationshipChip) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (labels.showTypeChip)
                                _EventMetaChip(
                                  label: event.type,
                                  icon: EventAvatar.iconForEventType(event.type),
                                  emphasized: true,
                                ),
                              if (labels.showRelationshipChip)
                                _EventMetaChip(label: event.relationship),
                            ],
                          ),
                        ],
                        if (showDateCountdown) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _DateChip(
                                label: _dateLabel(event.date),
                                highlighted: withinWeek,
                                urgent: urgent,
                              ),
                              Text(
                                DateFormat('h:mm a').format(
                                  EventDateUtils.nextOccurrence(event.date),
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (event.memories.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            event.memories.first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textSecondary.withValues(alpha: 0.9),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventMetaChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool emphasized;

  const _EventMetaChip({
    required this.label,
    this.icon,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: emphasized ? AppTheme.accentLight : AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: emphasized
              ? AppTheme.accent.withValues(alpha: 0.35)
              : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: emphasized ? AppTheme.accentDark : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: emphasized ? AppTheme.accentDark : AppTheme.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final bool highlighted;
  final bool urgent;

  const _DateChip({
    required this.label,
    required this.highlighted,
    required this.urgent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: urgent ? AppTheme.accentLight : AppTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: urgent
              ? AppTheme.accent.withValues(alpha: 0.4)
              : AppTheme.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: urgent ? AppTheme.accentDark : AppTheme.black,
          height: 1.2,
        ),
      ),
    );
  }
}
