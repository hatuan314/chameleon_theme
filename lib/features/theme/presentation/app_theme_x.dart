import 'package:flutter/material.dart';
import '../domain/app_theme.dart';
import 'theme_defaults.dart';

/// Extension to allow convenient access to the AppTheme from BuildContext.
extension AppThemeX on BuildContext {
  /// The active semantic theme. Always non-null once MaterialApp is built.
  /// If the AppTheme extension is absent, it falls back to ThemeDefaults.tokens.
  AppTheme get appTheme {
    return Theme.of(this).extension<AppTheme>() ?? ThemeDefaults.tokens;
  }
}

/// Helper extension on AppTheme to parse and resolve custom color strings.
extension CustomColorX on AppTheme {
  Color? customColor(String key) {
    final hex = customValue<String>(key);
    if (hex == null) return null;
    final cleanHex = hex.replaceAll('#', '').trim();
    if (cleanHex.length != 6) return null;
    final parsed = int.tryParse(cleanHex, radix: 16);
    if (parsed == null) return null;
    return Color(0xFF000000 | parsed);
  }
}
