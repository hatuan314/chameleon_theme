import 'package:flutter/material.dart';
import 'app_tokens.dart';
import '../presentation/theme_defaults.dart';

/// Semantic role layer built from AppTokens.
/// Exposes named UI roles to widgets.
class AppTheme extends ThemeExtension<AppTheme> {
  final Color buttonBackground;
  final Color buttonForeground;
  final Color cardSurface;
  final Color inputBorder;
  final double cardRadius;
  final double buttonRadius;
  final String fontFamily;
  final double fontWeight;
  final double fontSize;
  final Map<String, dynamic>? custom;

  AppTheme({
    required this.buttonBackground,
    required this.buttonForeground,
    required this.cardSurface,
    required this.inputBorder,
    required this.cardRadius,
    required this.buttonRadius,
    required this.fontFamily,
    required this.fontWeight,
    required this.fontSize,
    this.custom,
  });

  /// Factory constructor to map primitive AppTokens to semantic AppTheme roles using a SemanticMap.
  factory AppTheme.fromTokens(AppTokens t, Map<String, dynamic> semanticMap) {
    Color resolveColor(String role, Color defaultValue) {
      final tokenKey = semanticMap[role];
      if (tokenKey == 'primary') return t.colorPrimary;
      if (tokenKey == 'secondary') return t.colorSecondary;
      if (tokenKey == 'surface') return t.colorSurface;
      if (tokenKey == 'onPrimary') return t.colorOnPrimary;
      return defaultValue;
    }

    double resolveRadius(String role, double defaultValue) {
      final tokenKey = semanticMap[role];
      if (tokenKey is String) {
        return t.radii[tokenKey] ?? defaultValue;
      }
      return defaultValue;
    }

    return AppTheme(
      buttonBackground: resolveColor('buttonBackground', ThemeDefaults.buttonBackground),
      buttonForeground: resolveColor('buttonForeground', ThemeDefaults.buttonForeground),
      cardSurface: resolveColor('cardSurface', ThemeDefaults.cardSurface),
      inputBorder: t.colorPrimary.withValues(alpha: 0.5),
      cardRadius: resolveRadius('cardRadius', ThemeDefaults.cardRadius),
      buttonRadius: resolveRadius('buttonRadius', ThemeDefaults.buttonRadius),
      fontFamily: t.fontFamily,
      fontWeight: t.fontWeight,
      fontSize: t.fontSize,
      custom: t.custom,
    );
  }

  /// Looks up a custom key-value pair from the tenant's custom configuration map.
  /// Safely returns null if the key is missing or the type is mismatched.
  T? customValue<T>(String key) {
    final val = custom?[key];
    if (val is T) return val;
    return null;
  }

  @override
  AppTheme copyWith({
    Color? buttonBackground,
    Color? buttonForeground,
    Color? cardSurface,
    Color? inputBorder,
    double? cardRadius,
    double? buttonRadius,
    String? fontFamily,
    double? fontWeight,
    double? fontSize,
    Map<String, dynamic>? custom,
  }) {
    return AppTheme(
      buttonBackground: buttonBackground ?? this.buttonBackground,
      buttonForeground: buttonForeground ?? this.buttonForeground,
      cardSurface: cardSurface ?? this.cardSurface,
      inputBorder: inputBorder ?? this.inputBorder,
      cardRadius: cardRadius ?? this.cardRadius,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      fontSize: fontSize ?? this.fontSize,
      custom: custom ?? this.custom,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other is! AppTheme) return this;
    // Snaps instantly at the 0.5 threshold to support transition-free cuts.
    return t < 0.5 ? this : other;
  }
}
