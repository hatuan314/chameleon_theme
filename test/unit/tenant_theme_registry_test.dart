import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chameleon_theme/features/theme/data/theme_config.dart';
import 'package:chameleon_theme/features/theme/domain/tenant_theme_registry.dart';
import 'package:chameleon_theme/features/theme/domain/user_context.dart';
import 'package:chameleon_theme/features/theme/presentation/theme_defaults.dart';

void main() {
  group('TenantThemeRegistry Tests', () {

    test('should resolve variant according to segment matching', () {
      final config = ThemeConfig(
        themes: {
          'default': {
            'colors': {'primary': '#005BAC'},
            'typography': {'fontFamily': 'Inter'},
          },
          'vip': {
            'colors': {'primary': '#D4AF37'},
            'typography': {'fontFamily': 'Playfair Display'},
          }
        },
        themeRules: {
          'default': 'default',
          'conditions': {'VIP': 'vip'}
        },
      );

      final registry = TenantThemeRegistry.fromConfig(config, tenantKey: 'xbank');

      final anonymousTokens = registry.resolve(UserContext.anonymous());
      final vipTokensResolved = registry.resolve(UserContext(segment: 'VIP'));
      final standardTokens = registry.resolve(UserContext(segment: 'STANDARD'));

      expect(anonymousTokens.colorPrimary, const Color(0xFF005BAC));
      expect(vipTokensResolved.colorPrimary, const Color(0xFFD4AF37));
      expect(standardTokens.colorPrimary, const Color(0xFF005BAC));
    });

    test('should fallback to default variant if matched variant is missing (FR-009)', () {
      final config = ThemeConfig(
        themes: {
          'default': {
            'colors': {'primary': '#005BAC'},
            'typography': {'fontFamily': 'Inter'},
          },
          // 'vip' is missing
        },
        themeRules: {
          'default': 'default',
          'conditions': {'VIP': 'vip'} // points to missing 'vip'
        },
      );

      final registry = TenantThemeRegistry.fromConfig(config, tenantKey: 'xbank');
      final vipTokensResolved = registry.resolve(UserContext(segment: 'VIP'));

      // Should fall back to default
      expect(vipTokensResolved.colorPrimary, const Color(0xFF005BAC));
    });

    test('should fallback to ThemeDefaults.tokens if default variant is also missing (FR-009)', () {
      final config = ThemeConfig(
        themes: {
          // Both default and vip are missing
        },
        themeRules: {
          'default': 'default',
          'conditions': {'VIP': 'vip'}
        },
      );

      final registry = TenantThemeRegistry.fromConfig(config, tenantKey: 'xbank');
      final anonymousTokens = registry.resolve(UserContext.anonymous());

      // Should fall back to ThemeDefaults global constants
      expect(anonymousTokens.colorPrimary, ThemeDefaults.colorPrimary);
      expect(anonymousTokens.fontFamily, ThemeDefaults.fontFamily);
    });
  });
}
