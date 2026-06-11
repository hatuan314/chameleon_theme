import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chameleon_theme/features/theme/domain/app_tokens.dart';
import 'package:chameleon_theme/features/theme/presentation/theme_defaults.dart';

void main() {
  group('AppTokens Parsing Tests', () {
    test('should parse valid token json correctly', () {
      final json = {
        'colors': {
          'primary': '#005BAC',
          'secondary': '#4A5568',
          'surface': '#FFFFFF',
          'onPrimary': '#FFFFFF',
        },
        'typography': {
          'fontFamily': 'Inter',
          'fontWeight': 500.0,
          'fontSize': 16.0,
        },
        'spacing': {
          'xs': 4.0,
          'sm': 8.0,
          'md': 16.0,
        },
        'radii': {
          'xs': 4.0,
          'sm': 8.0,
        },
        'custom': {
          'logoUrl': 'assets/techcom.png',
          'promoColor': '#FF9900',
        }
      };

      final tokens = AppTokens.fromJson(json, tenantKey: 'test-tenant');

      expect(tokens.colorPrimary, const Color(0xFF005BAC));
      expect(tokens.colorSecondary, const Color(0xFF4A5568));
      expect(tokens.colorSurface, const Color(0xFFFFFFFF));
      expect(tokens.colorOnPrimary, const Color(0xFFFFFFFF));
      expect(tokens.fontFamily, 'Inter');
      expect(tokens.fontWeight, 500.0);
      expect(tokens.fontSize, 16.0);
      expect(tokens.spacing['md'], 16.0);
      expect(tokens.radii['sm'], 8.0);
      expect(tokens.custom?['logoUrl'], 'assets/techcom.png');
    });

    test('should fallback to ThemeDefaults on missing or malformed values', () {
      final json = {
        'colors': {
          'primary': 'invalid-hex-color', // malformed
          // 'secondary' is missing
          'surface': '#FFFFFF',
          'onPrimary': '#FFFFFF',
        },
        'typography': {
          // fontFamily is missing
          'fontWeight': 'invalid-weight', // malformed
          'fontSize': 16.0,
        },
        // spacing and radii are missing
      };

      final tokens = AppTokens.fromJson(json, tenantKey: 'test-tenant');

      expect(tokens.colorPrimary, ThemeDefaults.colorPrimary);
      expect(tokens.colorSecondary, ThemeDefaults.colorSecondary);
      expect(tokens.colorSurface, const Color(0xFFFFFFFF));
      expect(tokens.fontFamily, ThemeDefaults.fontFamily);
      expect(tokens.fontWeight, ThemeDefaults.fontWeight);
      expect(tokens.spacing['md'], ThemeDefaults.spacing['md']);
      expect(tokens.radii['sm'], ThemeDefaults.radii['sm']);
      expect(tokens.custom, isNull);
    });
  });
}
