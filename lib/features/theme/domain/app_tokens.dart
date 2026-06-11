import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../presentation/theme_defaults.dart';

/// Primitive layer carrying raw configuration tokens loaded from JSON.
class AppTokens {
  final Color colorPrimary;
  final Color colorSecondary;
  final Color colorSurface;
  final Color colorOnPrimary;
  final String fontFamily;
  final double fontWeight;
  final double fontSize;
  final Map<String, double> spacing;
  final Map<String, double> radii;
  final Map<String, String> semanticMap;
  final Map<String, dynamic>? custom;

  AppTokens({
    required this.colorPrimary,
    required this.colorSecondary,
    required this.colorSurface,
    required this.colorOnPrimary,
    required this.fontFamily,
    required this.fontWeight,
    required this.fontSize,
    required this.spacing,
    required this.radii,
    required this.semanticMap,
    this.custom,
  });

  /// Factory constructor to parse AppTokens from a JSON map with robust fallback logic.
  factory AppTokens.fromJson(Map<String, dynamic> json, {required String tenantKey}) {
    final colorsJson = json['colors'] is Map ? json['colors'] as Map<String, dynamic> : const <String, dynamic>{};
    final typographyJson = json['typography'] is Map ? json['typography'] as Map<String, dynamic> : const <String, dynamic>{};
    final spacingJson = json['spacing'] is Map ? json['spacing'] as Map<String, dynamic> : null;
    final radiiJson = json['radii'] is Map ? json['radii'] as Map<String, dynamic> : null;
    final semanticMapJson = json['semanticMap'] is Map ? json['semanticMap'] as Map<String, dynamic> : const <String, dynamic>{};
    final customJson = json['custom'] is Map ? json['custom'] as Map<String, dynamic> : null;

    final parsedSemanticMap = semanticMapJson.map((k, v) => MapEntry(k, v.toString()));

    Color? parseColor(String key) {
      final val = colorsJson[key];
      if (val is! String) {
        _logFallback('colors.$key', tenantKey, 'missing');
        return null;
      }
      final cleanHex = val.replaceAll('#', '').trim();
      if (cleanHex.length != 6) {
        _logFallback('colors.$key', tenantKey, 'malformed hex string "$val"');
        return null;
      }
      final parsed = int.tryParse(cleanHex, radix: 16);
      if (parsed == null) {
        _logFallback('colors.$key', tenantKey, 'invalid hex value "$val"');
        return null;
      }
      return Color(0xFF000000 | parsed);
    }

    double? parseDouble(Map<String, dynamic> map, String key, String section) {
      final val = map[key];
      if (val == null) {
        _logFallback('$section.$key', tenantKey, 'missing');
        return null;
      }
      if (val is num) return val.toDouble();
      if (val is String) {
        final parsed = double.tryParse(val);
        if (parsed != null) return parsed;
      }
      _logFallback('$section.$key', tenantKey, 'malformed value "$val"');
      return null;
    }

    String? parseString(Map<String, dynamic> map, String key, String section) {
      final val = map[key];
      if (val == null) {
        _logFallback('$section.$key', tenantKey, 'missing');
        return null;
      }
      return val.toString();
    }

    Map<String, double> parseMap(Map<String, dynamic>? sourceMap, Map<String, double> defaultMap, String section) {
      if (sourceMap == null) {
        _logFallback(section, tenantKey, 'missing section');
        return defaultMap;
      }
      final parsedMap = <String, double>{};
      defaultMap.forEach((key, defaultValue) {
        final val = sourceMap[key];
        if (val == null) {
          _logFallback('$section.$key', tenantKey, 'missing');
          parsedMap[key] = defaultValue;
        } else if (val is num) {
          parsedMap[key] = val.toDouble();
        } else if (val is String) {
          final parsed = double.tryParse(val);
          if (parsed != null) {
            parsedMap[key] = parsed;
          } else {
            _logFallback('$section.$key', tenantKey, 'malformed value "$val"');
            parsedMap[key] = defaultValue;
          }
        } else {
          _logFallback('$section.$key', tenantKey, 'invalid type');
          parsedMap[key] = defaultValue;
        }
      });
      return parsedMap;
    }

    return AppTokens(
      colorPrimary: parseColor('primary') ?? ThemeDefaults.colorPrimary,
      colorSecondary: parseColor('secondary') ?? ThemeDefaults.colorSecondary,
      colorSurface: parseColor('surface') ?? ThemeDefaults.colorSurface,
      colorOnPrimary: parseColor('onPrimary') ?? ThemeDefaults.colorOnPrimary,
      fontFamily: parseString(typographyJson, 'fontFamily', 'typography') ?? ThemeDefaults.fontFamily,
      fontWeight: parseDouble(typographyJson, 'fontWeight', 'typography') ?? ThemeDefaults.fontWeight,
      fontSize: parseDouble(typographyJson, 'fontSize', 'typography') ?? ThemeDefaults.fontSize,
      spacing: parseMap(spacingJson, ThemeDefaults.spacing, 'spacing'),
      radii: parseMap(radiiJson, ThemeDefaults.radii, 'radii'),
      semanticMap: parsedSemanticMap,
      custom: customJson,
    );
  }

  static void _logFallback(String tokenName, String tenantKey, String reason) {
    dev.log(
      'Fallback: Token "$tokenName" is $reason for tenant "$tenantKey". Using default value.',
      name: 'theme_engine',
    );
  }
}
