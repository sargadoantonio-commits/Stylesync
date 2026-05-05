import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "app_colors.dart";
import "app_typography.dart";

class StyleButton extends StatefulWidget {
  const StyleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  State<StyleButton> createState() => _StyleButtonState();
}

class _StyleButtonState extends State<StyleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _animateDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _pressController.animateTo(0.96,
          duration: const Duration(milliseconds: 80), curve: Curves.easeOut);
    }
  }

  void _animateUp([TapUpDetails? details]) {
    if (widget.onPressed != null) {
      _pressController.animateTo(1.0,
          duration: const Duration(milliseconds: 120), curve: Curves.easeOut);
    }
  }

  void _animateCancel() {
    if (widget.onPressed != null) {
      _pressController.animateTo(1.0,
          duration: const Duration(milliseconds: 80), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      label: widget.label,
      hint: widget.onPressed != null
          ? 'Activate ${widget.label}'
          : 'Disabled ${widget.label}',
      child: Tooltip(
        message: widget.label,
        child: ScaleTransition(
          scale: _pressController,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onPressed!();
                    },
              onTapDown: _animateDown,
              onTapUp: _animateUp,
              onTapCancel: _animateCancel,
              borderRadius: BorderRadius.circular(12),
              focusColor: AppColors.accentMagenta.withValues(alpha: 0.15),
              hoverColor: AppColors.accentMagenta.withValues(alpha: 0.08),
              splashColor: AppColors.accentMagenta.withValues(alpha: 0.18),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.accentMagenta, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentMagenta.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.accentMagenta.withValues(alpha: 0.15),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accentMagenta.withValues(alpha: 0.15),
                      AppColors.glassFill,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon,
                            color: AppColors.accentMagenta, size: 20),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.label,
                        style:
                            AppTypography.interBody(16, weight: FontWeight.w600)
                                .copyWith(
                          color: widget.onPressed == null
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
