import 'package:celebray/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TutorialStep {
  final String title;
  final String body;
  final GlobalKey? targetKey;
  final int? tabIndex;

  const TutorialStep({
    required this.title,
    required this.body,
    this.targetKey,
    this.tabIndex,
  });
}

class FeatureTutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final int stepIndex;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const FeatureTutorialOverlay({
    super.key,
    required this.steps,
    required this.stepIndex,
    required this.onNext,
    required this.onSkip,
  });

  @override
  State<FeatureTutorialOverlay> createState() => _FeatureTutorialOverlayState();
}

class _FeatureTutorialOverlayState extends State<FeatureTutorialOverlay> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTargetRect());
  }

  @override
  void didUpdateWidget(FeatureTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stepIndex != widget.stepIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateTargetRect());
    }
  }

  void _updateTargetRect() {
    final step = widget.steps[widget.stepIndex];
    final key = step.targetKey;
    if (key == null) {
      if (_targetRect != null) {
        setState(() => _targetRect = null);
      }
      return;
    }

    final context = key.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final rect = offset & renderBox.size;
    if (_targetRect != rect) {
      setState(() => _targetRect = rect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[widget.stepIndex];
    final isLastStep = widget.stepIndex == widget.steps.length - 1;
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final padding = mediaQuery.padding;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onNext,
              behavior: HitTestBehavior.opaque,
              child: CustomPaint(
                painter: _SpotlightPainter(
                  hole: _targetRect?.inflate(8),
                  borderRadius: 14,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          if (_targetRect != null)
            Positioned(
              left: _targetRect!.left - 4,
              top: _targetRect!.top - 4,
              width: _targetRect!.width + 8,
              height: _targetRect!.height + 8,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.accent, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _TooltipCard(
            title: step.title,
            body: step.body,
            stepIndex: widget.stepIndex,
            stepCount: widget.steps.length,
            isLastStep: isLastStep,
            targetRect: _targetRect,
            screenSize: screenSize,
            safePadding: padding,
            onNext: widget.onNext,
            onSkip: widget.onSkip,
          ),
        ],
      ),
    );
  }
}

class _TooltipCard extends StatelessWidget {
  final String title;
  final String body;
  final int stepIndex;
  final int stepCount;
  final bool isLastStep;
  final Rect? targetRect;
  final Size screenSize;
  final EdgeInsets safePadding;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TooltipCard({
    required this.title,
    required this.body,
    required this.stepIndex,
    required this.stepCount,
    required this.isLastStep,
    required this.targetRect,
    required this.screenSize,
    required this.safePadding,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    const cardWidth = 320.0;
    const horizontalInset = 20.0;
    final left = ((screenSize.width - cardWidth) / 2)
        .clamp(horizontalInset, screenSize.width - cardWidth - horizontalInset);

    double top;
    if (targetRect == null) {
      top = (screenSize.height - 220) / 2;
    } else if (targetRect!.center.dy > screenSize.height * 0.55) {
      top = (targetRect!.top - 196).clamp(
        safePadding.top + 16,
        screenSize.height - 220,
      );
    } else {
      top = (targetRect!.bottom + 16).clamp(
        safePadding.top + 16,
        screenSize.height - 220,
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: cardWidth,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        color: AppTheme.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${stepIndex + 1} of $stepCount',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Skip'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onNext,
                  child: Text(isLastStep ? 'Got it' : 'Next'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? hole;
  final double borderRadius;

  _SpotlightPainter({required this.hole, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (hole != null) {
      overlay.addRRect(
        RRect.fromRectAndRadius(hole!, Radius.circular(borderRadius)),
      );
    }

    overlay.fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlay,
      Paint()..color = AppTheme.black.withValues(alpha: 0.72),
    );
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.hole != hole;
  }
}
