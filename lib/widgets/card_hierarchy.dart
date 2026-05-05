import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

/// Enhanced Primary action card - for important CTAs with modern design
class PrimaryCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onTap;
  final bool highlighted;
  final IconData? leadingIcon;

  const PrimaryCard({
    required this.title,
    this.subtitle,
    required this.child,
    this.onTap,
    this.highlighted = false,
    this.leadingIcon,
    super.key,
  });

  @override
  State<PrimaryCard> createState() => _PrimaryCardState();
}

class _PrimaryCardState extends State<PrimaryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: widget.highlighted
                ? LinearGradient(
                    colors: [
                      AppColors.accentMagenta.withValues(alpha: 0.25),
                      AppColors.accentMagenta.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      AppColors.deepNavy.withValues(alpha: 0.8),
                      AppColors.deepNavy.withValues(alpha: 0.95),
                    ],
                  ),
            border: Border.all(
              color: widget.highlighted
                  ? AppColors.accentMagenta.withValues(alpha: 0.5)
                  : AppColors.accentMagenta.withValues(alpha: 0.2),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered || widget.highlighted
                ? [
                    BoxShadow(
                      color: AppColors.accentMagenta.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (widget.leadingIcon != null) ...[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.accentMagenta.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.leadingIcon,
                        color: AppColors.accentMagenta,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: AppTypography.orbitronHeading(18)
                          .copyWith(color: AppColors.white),
                    ),
                  ),
                ],
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.subtitle!,
                  style: AppTypography.interBody(13)
                      .copyWith(color: AppColors.textMuted),
                ),
              ],
              const SizedBox(height: 20),
              widget.child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Secondary info card with better visual hierarchy
class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsets padding;
  final Color? accentColor;
  final IconData? icon;

  const InfoCard({
    required this.title,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.accentColor,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.accentMagenta;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.deepNavy.withValues(alpha: 0.5),
            AppColors.deepNavy.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: accent.withValues(alpha: 0.15),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                title,
                style: AppTypography.interBody(13, weight: FontWeight.w700)
                    .copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

/// Enhanced Alert/Status card with professional styling
class AlertCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? bgColor;
  final Color? borderColor;
  final Color? iconColor;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AlertCard({
    required this.title,
    this.subtitle,
    required this.icon,
    this.bgColor,
    this.borderColor,
    this.iconColor,
    this.onAction,
    this.actionLabel,
    super.key,
  });

  @override
  State<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.bgColor ?? AppColors.accentRed.withValues(alpha: 0.12);
    final border = widget.borderColor ?? AppColors.accentRed.withValues(alpha: 0.35);
    final ic = widget.iconColor ?? AppColors.accentRed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: ic.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: ic.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: ic, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: AppTypography.interBody(14, weight: FontWeight.w700)
                        .copyWith(color: AppColors.white),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle!,
                      style: AppTypography.interBody(12)
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.onAction != null) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onAction,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: ic.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: ic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Enhanced Loading state with shimmer effect
class LoadingCard extends StatefulWidget {
  final int count;
  final double height;

  const LoadingCard({
    this.count = 1,
    this.height = 120,
    super.key,
  });

  @override
  State<LoadingCard> createState() => _LoadingCardState();
}

class _LoadingCardState extends State<LoadingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.count,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < widget.count - 1 ? 14 : 0),
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.deepNavy.withValues(alpha: 0.4),
                      AppColors.deepNavy.withValues(alpha: 0.6),
                      AppColors.deepNavy.withValues(alpha: 0.4),
                    ],
                    stops: [
                      _shimmerController.value - 0.3,
                      _shimmerController.value,
                      _shimmerController.value + 0.3,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accentMagenta.withValues(alpha: 0.1),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Enhanced Action button grid with hover effects
class ActionButtonGrid extends StatelessWidget {
  final List<ActionButtonItem> items;
  final int crossAxisCount;

  const ActionButtonGrid({
    required this.items,
    this.crossAxisCount = 2,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ActionButtonTile(item: item);
      },
    );
  }
}

class _ActionButtonTile extends StatefulWidget {
  final ActionButtonItem item;

  const _ActionButtonTile({required this.item});

  @override
  State<_ActionButtonTile> createState() => _ActionButtonTileState();
}

class _ActionButtonTileState extends State<_ActionButtonTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.item.bgColor ?? AppColors.accentMagenta;

    return GestureDetector(
      onTap: widget.item.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bgColor.withValues(alpha: _isHovered ? 0.18 : 0.12),
                bgColor.withValues(alpha: _isHovered ? 0.12 : 0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: bgColor.withValues(alpha: _isHovered ? 0.4 : 0.25),
              width: _isHovered ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: _isHovered ? 1.12 : 1,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.item.icon,
                  size: 36,
                  color: widget.item.iconColor ?? bgColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.item.label,
                textAlign: TextAlign.center,
                style: AppTypography.interBody(13, weight: FontWeight.w600)
                    .copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionButtonItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? bgColor;
  final Color? iconColor;

  ActionButtonItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.bgColor,
    this.iconColor,
  });
}

