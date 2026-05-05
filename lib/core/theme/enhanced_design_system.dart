import 'package:flutter/material.dart';
import 'app_colors.dart';

/// StyleSync Enhanced Design System
/// Adds visual hierarchy, animations, spacing, and professional design patterns

abstract final class EnhancedSpacing {
  // Micro spacing
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  // Section spacing
  static const double section = 40;
}

abstract final class EnhancedRadius {
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 50;
}

abstract final class EnhancedShadows {
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static final List<BoxShadow> highlight = [
    BoxShadow(
      color: AppColors.accentMagenta.withValues(alpha: 0.2),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> highlightTeal = [
    BoxShadow(
      color: AppColors.accentCyan.withValues(alpha: 0.15),
      blurRadius: 20,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> glow = [
    BoxShadow(
      color: AppColors.accentMagenta.withValues(alpha: 0.3),
      blurRadius: 32,
      spreadRadius: 2,
    ),
  ];
}

abstract final class EnhancedGradients {
  static final LinearGradient magentaToTransparent = LinearGradient(
    colors: [
      AppColors.accentMagenta.withValues(alpha: 0.2),
      AppColors.accentMagenta.withValues(alpha: 0),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient magentaPrimary = LinearGradient(
    colors: [
      AppColors.accentMagenta.withValues(alpha: 0.3),
      AppColors.accentMagenta.withValues(alpha: 0.1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient tealAccent = LinearGradient(
    colors: [
      AppColors.accentCyan.withValues(alpha: 0.15),
      AppColors.accentCyan.withValues(alpha: 0.05),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient goldAccent = LinearGradient(
    colors: [
      AppColors.accentGold.withValues(alpha: 0.2),
      AppColors.accentGold.withValues(alpha: 0.05),
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static final LinearGradient premiumGradient = LinearGradient(
    colors: [
      AppColors.accentGold.withValues(alpha: 0.3),
      AppColors.accentMagenta.withValues(alpha: 0.2),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient sectionHeader = LinearGradient(
    colors: [
      AppColors.accentMagenta.withValues(alpha: 0.15),
      Colors.transparent,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

abstract final class EnhancedAnimations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static Curve easeOutQuad = Curves.easeOutQuad;
  static Curve easeInOutCubic = Curves.easeInOutCubic;
  static Curve easeOutCubic = Curves.easeOutCubic;
  static Curve bounceOut = Curves.elasticOut;
}

abstract final class EnhancedBorders {
  static BoxBorder magentaBorder = Border.all(
    color: AppColors.accentMagenta.withValues(alpha: 0.3),
    width: 1.2,
  );

  static BoxBorder tealBorder = Border.all(
    color: AppColors.accentCyan.withValues(alpha: 0.2),
    width: 1,
  );

  static BoxBorder goldBorder = Border.all(
    color: AppColors.accentGold.withValues(alpha: 0.3),
    width: 1,
  );

  static BoxBorder subtleBorder = Border.all(
    color: AppColors.textMuted.withValues(alpha: 0.1),
    width: 0.8,
  );
}

/// Enhanced card decoration helper
class EnhancedCardDecoration {
  static BoxDecoration createGlassDecoration({
    required Color color,
    Color? borderColor,
    List<BoxShadow>? shadows,
    double radius = EnhancedRadius.lg,
    double borderWidth = 1.2,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? AppColors.accentMagenta.withValues(alpha: 0.2),
        width: borderWidth,
      ),
      boxShadow: shadows ?? EnhancedShadows.md,
    );
  }

  static BoxDecoration createPremiumDecoration({
    double radius = EnhancedRadius.lg,
  }) {
    return BoxDecoration(
      gradient: EnhancedGradients.premiumGradient,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.accentGold.withValues(alpha: 0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.accentGold.withValues(alpha: 0.2),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration createActionDecoration({
    double radius = EnhancedRadius.md,
  }) {
    return BoxDecoration(
      gradient: EnhancedGradients.magentaPrimary,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.accentMagenta.withValues(alpha: 0.3),
        width: 1,
      ),
      boxShadow: EnhancedShadows.md,
    );
  }
}

/// Enhanced icon container for consistent icon styling
class EnhancedIconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;
  final double containerSize;
  final double iconSize;

  const EnhancedIconContainer({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    this.size = 24,
    this.containerSize = 48,
    this.iconSize = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withValues(alpha: 0.25),
            backgroundColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(EnhancedRadius.md),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    );
  }
}

/// Animated action button with HCI feedback
class EnhancedAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color? borderColor;
  final double? width;
  final double borderRadius;

  const EnhancedAnimatedButton({
    required this.child,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    this.backgroundColor = AppColors.accentMagenta,
    this.borderColor,
    this.width,
    this.borderRadius = EnhancedRadius.lg,
    super.key,
  });

  @override
  State<EnhancedAnimatedButton> createState() => _EnhancedAnimatedButtonState();
}

class _EnhancedAnimatedButtonState extends State<EnhancedAnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: EnhancedAnimations.fast,
          width: widget.width,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.backgroundColor.withValues(alpha: 0.8)
                : widget.backgroundColor,
            border: Border.all(
              color: widget.borderColor ??
                  widget.backgroundColor.withValues(alpha: 0.5),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.backgroundColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : EnhancedShadows.lg,
          ),
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: EnhancedAnimations.fast,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
