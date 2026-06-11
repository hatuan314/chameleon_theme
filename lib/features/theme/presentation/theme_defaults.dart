import 'package:flutter/material.dart';
import '../domain/app_theme.dart';
import '../domain/app_tokens.dart';

/// Defines the neutral, accessible monochrome safe default values for the theme engine.
/// Used for per-token fallback (FR-007) and full-variant fallback (FR-009).
class ThemeDefaults {
  ThemeDefaults._();

  // Colors
  static const Color colorPrimary = Color(0xFF212121);
  static const Color colorSecondary = Color(0xFF757575);
  static const Color colorSurface = Color(0xFFFFFFFF);
  static const Color colorOnPrimary = Color(0xFFFFFFFF);

  // Typography
  static const String fontFamily = 'Roboto';
  static const double fontWeight = 400.0; // Maps to FontWeight.w400
  static const double fontSize = 14.0;

  // Spacing & Radii defaults
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;

  static const Map<String, double> spacing = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 16.0,
    'lg': 24.0,
    'xl': 32.0,
  };

  static const Map<String, double> radii = {
    'xs': 4.0,
    'sm': 8.0,
    'md': 12.0,
    'lg': 16.0,
  };

  // Safe semantic roles
  static const Color buttonBackground = colorPrimary;
  static const Color buttonForeground = colorOnPrimary;
  static const Color cardSurface = colorSurface;
  static const Color inputBorder = Color(0x80212121); // colorPrimary with 50% opacity

  /// Standard fallback theme instance using ThemeDefaults.
  static final AppTheme tokens = AppTheme(
    buttonBackground: buttonBackground,
    buttonForeground: buttonForeground,
    cardSurface: cardSurface,
    inputBorder: inputBorder,
    cardRadius: cardRadius,
    buttonRadius: buttonRadius,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    fontSize: fontSize,
    custom: null,
  );

  /// Standard fallback tokens instance using ThemeDefaults.
  static final AppTokens appTokens = AppTokens(
    colorPrimary: colorPrimary,
    colorSecondary: colorSecondary,
    colorSurface: colorSurface,
    colorOnPrimary: colorOnPrimary,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    fontSize: fontSize,
    spacing: spacing,
    radii: radii,
    semanticMap: const {},
    custom: null,
  );
}
