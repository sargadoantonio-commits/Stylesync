import "package:flutter/material.dart";
import "responsive_helper.dart";

/// Responsive card wrapper that adjusts padding and border radius based on screen size
class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveHelper.getResponsivePadding(context);
    final borderRadius = ResponsiveHelper.getResponsiveBorderRadius(context);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? EdgeInsets.all(responsivePadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: child,
    );
  }
}

/// Responsive button that adjusts size and text based on screen size
class ResponsiveButton extends StatelessWidget {
  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.style,
  });

  final VoidCallback? onPressed;
  final String label;
  final IconData? icon;
  final bool isLoading;
  final bool enabled;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveHelper.getResponsiveButtonHeight(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(context, 16);

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: style,
        icon: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              )
            : (icon != null ? Icon(icon, size: fontSize) : const SizedBox.shrink()),
        label: Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Responsive spacer that provides proportional spacing
class ResponsiveSpacer extends StatelessWidget {
  const ResponsiveSpacer({super.key, this.baseHeight = 16, this.factor = 1.0});

  final double baseHeight;
  final double factor;

  @override
  Widget build(BuildContext context) {
    final height = ResponsiveHelper.getResponsiveSpacing(context, baseHeight) * factor;
    return SizedBox(height: height);
  }
}

/// Responsive grid layout that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveHelper.getScreenSize(context);
    final crossAxisCount = _getColumnCount(screenSize);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: children,
    );
  }

  int _getColumnCount(ScreenSize screenSize) {
    switch (screenSize) {
      case ScreenSize.extraSmall:
      case ScreenSize.small:
        return 1;
      case ScreenSize.medium:
        return 2;
      case ScreenSize.large:
      case ScreenSize.extraLarge:
        return 3;
    }
  }
}

/// Responsive flex container that wraps items intelligently
class ResponsiveFlexWrap extends StatelessWidget {
  const ResponsiveFlexWrap({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}
