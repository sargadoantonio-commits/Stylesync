import "package:flutter/material.dart";

import "app_colors.dart";

abstract final class AppTypography {
  static const List<String> _interFallbackFonts = [
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];

  static const List<String> _orbitronFallbackFonts = [
    'Ethnocentric',
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];

  static TextStyle ethnocentric({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? decorationThickness,
    TextBaseline? textBaseline,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: 'Ethnocentric',
      fontFamilyFallback: _interFallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationThickness: decorationThickness,
      textBaseline: textBaseline,
      overflow: overflow,
    );
  }

  static TextStyle orbitron({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? decorationThickness,
    TextBaseline? textBaseline,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: 'Orbitron',
      fontFamilyFallback: _orbitronFallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationThickness: decorationThickness,
      textBaseline: textBaseline,
      overflow: overflow,
    );
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    Color? color,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? decorationThickness,
    TextBaseline? textBaseline,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontFamilyFallback: _interFallbackFonts,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationThickness: decorationThickness,
      textBaseline: textBaseline,
      overflow: overflow,
    );
  }

  static TextStyle orbitronHeading(double size, {FontWeight weight = FontWeight.w900}) {
    return orbitron(
      fontSize: size,
      fontWeight: weight,
      height: 1.28,
      letterSpacing: 0.10,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle interBody(double size, {FontWeight weight = FontWeight.w500}) {
    return inter(
      fontSize: size,
      fontWeight: weight,
      height: 1.6,
      letterSpacing: 0.40,
      color: AppColors.textPrimary,
    );
  }
}
