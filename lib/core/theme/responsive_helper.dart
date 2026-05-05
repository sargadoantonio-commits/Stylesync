import "package:flutter/material.dart";

/// Responsive design helper for managing adaptive layouts across different screen sizes
class ResponsiveHelper {
  /// Get screen width
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  /// Get screen height
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  /// Get device padding (safe area)
  static EdgeInsets devicePadding(BuildContext context) => MediaQuery.of(context).padding;

  /// Get device view insets (keyboard, notches)
  static EdgeInsets deviceViewInsets(BuildContext context) => MediaQuery.of(context).viewInsets;

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) => MediaQuery.of(context).orientation == Orientation.landscape;

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) => MediaQuery.of(context).orientation == Orientation.portrait;

  /// Get responsive breakpoint
  static ScreenSize getScreenSize(BuildContext context) {
    final width = screenWidth(context);
    if (width < 480) {
      return ScreenSize.extraSmall; // Phones like iPhone SE
    } else if (width < 600) {
      return ScreenSize.small; // Regular phones
    } else if (width < 840) {
      return ScreenSize.medium; // Large phones / small tablets
    } else if (width < 1200) {
      return ScreenSize.large; // Tablets
    } else {
      return ScreenSize.extraLarge; // Large tablets / desktop
    }
  }

  /// Get responsive padding based on screen size
  static double getResponsivePadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.extraSmall:
        return 12;
      case ScreenSize.small:
        return 16;
      case ScreenSize.medium:
        return 18;
      case ScreenSize.large:
        return 20;
      case ScreenSize.extraLarge:
        return 24;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.extraSmall:
        return 10;
      case ScreenSize.small:
        return 12;
      case ScreenSize.medium:
        return 14;
      case ScreenSize.large:
        return 16;
      case ScreenSize.extraLarge:
        return 18;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.extraSmall:
        return baseSize * 0.85;
      case ScreenSize.small:
        return baseSize * 0.90;
      case ScreenSize.medium:
        return baseSize;
      case ScreenSize.large:
        return baseSize * 1.05;
      case ScreenSize.extraLarge:
        return baseSize * 1.10;
    }
  }

  /// Get responsive spacing (vertical/horizontal)
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.extraSmall:
        return baseSpacing * 0.75;
      case ScreenSize.small:
        return baseSpacing * 0.85;
      case ScreenSize.medium:
        return baseSpacing;
      case ScreenSize.large:
        return baseSpacing * 1.05;
      case ScreenSize.extraLarge:
        return baseSpacing * 1.10;
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.extraSmall:
        return 42;
      case ScreenSize.small:
        return 48;
      case ScreenSize.medium:
        return 50;
      case ScreenSize.large:
        return 52;
      case ScreenSize.extraLarge:
        return 56;
    }
  }

  /// Get max width for centered content (useful for large screens)
  static double getMaxContentWidth(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.extraSmall:
        return double.infinity;
      case ScreenSize.small:
        return double.infinity;
      case ScreenSize.medium:
        return double.infinity;
      case ScreenSize.large:
        return 500;
      case ScreenSize.extraLarge:
        return 600;
    }
  }

  /// Check if device is small (phone)
  static bool isSmallDevice(BuildContext context) {
    return getScreenSize(context) == ScreenSize.extraSmall || getScreenSize(context) == ScreenSize.small;
  }

  /// Check if device is medium or large (tablet)
  static bool isTablet(BuildContext context) {
    final screenSize = getScreenSize(context);
    return screenSize == ScreenSize.medium || screenSize == ScreenSize.large || screenSize == ScreenSize.extraLarge;
  }
}

enum ScreenSize { extraSmall, small, medium, large, extraLarge }
