import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../core/theme/app_colors.dart";
import "../core/theme/app_typography.dart";

/// A styled queue card showing queue position, status, and available actions.
/// Premium tickets show an icon and live entries animate for better attention.
class QueueCard extends StatefulWidget {
  const QueueCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    this.isLive = false,
    this.isPremium = false,
    this.onCancel,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final bool isLive;
  final bool isPremium;
  final VoidCallback? onCancel;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<QueueCard> createState() => _QueueCardState();
}

class _QueueCardState extends State<QueueCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.isPremium
        ? AppColors.accentRed
        : AppColors.accentRed.withValues(alpha: 0.7);
    final card = Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: AppColors.deepNavy,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: themeColor.withValues(alpha: 0.45), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(widget.title,
                              style: AppTypography.orbitronHeading(16)
                                  .copyWith(color: AppColors.white)),
                        ),
                        if (widget.isPremium)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.goldAccent, size: 18),
                                const SizedBox(width: 4),
                                Text('Premium',
                                    style: AppTypography.interBody(12,
                                            weight: FontWeight.w700)
                                        .copyWith(color: AppColors.goldAccent)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(widget.subtitle,
                        style: AppTypography.interBody(14)
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (widget.isLive)
                Semantics(
                  label: 'Live booking available',
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "LIVE",
                      style:
                          AppTypography.interBody(11, weight: FontWeight.w700)
                              .copyWith(color: AppColors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(widget.statusLabel,
              style:
                  AppTypography.interBody(14).copyWith(color: AppColors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.onAction != null && widget.actionLabel != null)
                Expanded(
                  child: Tooltip(
                    message: widget.actionLabel!,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onAction?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(widget.actionLabel!,
                            style: AppTypography.interBody(15,
                                    weight: FontWeight.w600)
                                .copyWith(color: AppColors.white)),
                      ),
                    ),
                  ),
                ),
              if (widget.onAction != null &&
                  widget.actionLabel != null &&
                  widget.onCancel != null)
                const SizedBox(width: 12),
              if (widget.onCancel != null)
                Tooltip(
                  message: 'Cancel action',
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        widget.onCancel?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: AppColors.accentRed.withValues(alpha: 0.8)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Cancel",
                          style: AppTypography.interBody(15,
                                  weight: FontWeight.w600)
                              .copyWith(color: AppColors.accentRed)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    final semanticsCard = Semantics(
      container: true,
      label:
          '${widget.title}. ${widget.subtitle}. ${widget.statusLabel}. ${widget.isPremium ? 'Premium ticket.' : 'Standard ticket.'}',
      child: card,
    );

    if (!widget.isLive) return semanticsCard;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final factor =
            1 + 0.015 * math.sin(_pulseController.value * math.pi * 2);
        return Transform.scale(scale: factor, child: child);
      },
      child: semanticsCard,
    );
  }
}
