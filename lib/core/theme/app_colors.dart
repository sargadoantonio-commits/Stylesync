import "package:flutter/material.dart";

/// StyleSync Design System — Philippine Market Edition (Davao, by ARTificial Grind)
/// Production-grade dark theme with magenta primary, teal status, gold accent
abstract final class AppColors {
  // Core backgrounds
  static const Color kBg =
      Color(0xFF0A1214); // Deep space — scaffold background
  static const Color kCard = Color(0xFF1A2B2F); // Card surface
  static const Color kCard2 = Color(0xFF0D1B1E); // Input field background

  // Primary & semantic accents
  static const Color kPrimary =
      Color(0xFFD946A6); // Magenta — ALL buttons/brand/borders
  static const Color kPrimaryDark =
      Color(0xFFB93D8C); // Magenta pressed/hover state
  static const Color kTeal = Color(0xFF00F5D4); // Teal — verified/status ONLY
  static const Color kGold = Color(0xFFFFD700); // Gold — queue, earnings, XP

  // Border colors with opacity
  static const Color kBorder =
      Color(0x26D946A6); // Magenta 15% — standard borders
  static const Color kBorderGold =
      Color(0x33FFD700); // Gold 20% — premium/loyalty
  static const Color kBorderTeal =
      Color(0x3300F5D4); // Teal 20% — verified/payment

  // Semantic colors
  static const Color kSuccess = Color(0xFF00B894); // Success states
  static const Color kDanger = Color(0xFFEF4444); // Errors, delete, danger

  // Text & UI elements
  static const Color kText = Color(0xFFE8FEF8); // Primary text — light cyan
  static const Color kMuted = Color(0xFF8CB7B8); // Secondary text — muted cyan

  // Legacy aliases for compatibility
  static const Color white = Color(0xFFFAFAFA); // Pure white
  static const Color background = kBg;
  static const Color deepNavy = kBg; // Alias for background
  static const Color deepTeal = kTeal; // Deep teal alias
  static const Color card = kCard;
  static const Color textPrimary = kText;
  static const Color textMuted = kMuted;
  static const Color accentMagenta = kPrimary; // Magenta primary
  static const Color accentCyan = kTeal; // Teal secondary
  static const Color accentGold = kGold; // Gold accent
  static const Color goldAccent = kGold; // Gold accent (alternate)
  static const Color glassFill = kCard; // Glass card fill color
  static const Color glassBorder = kBorder; // Glass card border
  static const Color kAccent = kPrimary; // Magenta (deprecated, use kPrimary)

  // Deprecated — kept for gradual migration
  static const Color accentRed = kDanger;
}
