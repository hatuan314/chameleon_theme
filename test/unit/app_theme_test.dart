import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chameleon_theme/features/theme/domain/app_tokens.dart';
import 'package:chameleon_theme/features/theme/domain/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    late AppTokens tokens;
    late Map<String, dynamic> semanticMap;

    setUp(() {
      tokens = AppTokens(
        colorPrimary: const Color(0xFF005BAC),
        colorSecondary: const Color(0xFF4A5568),
        colorSurface: const Color(0xFFFAFAFA),
        colorOnPrimary: const Color(0xFFFFFFFF),
        fontFamily: 'Inter',
        fontWeight: 600.0,
        fontSize: 16.0,
        spacing: {'small': 8.0, 'medium': 16.0},
        radii: {'card': 12.0, 'button': 8.0},
        semanticMap: const {},
        custom: {
          'promoBannerBg': '#FF5733',
          'partnerLogoUrl': 'assets/techcom.png',
          'enablePromo': true,
        },
      );

      semanticMap = {
        'buttonBackground': 'primary',
        'buttonForeground': 'onPrimary',
        'cardSurface': 'surface',
        'cardRadius': 'card',
        'buttonRadius': 'button',
      };
    });

    test('should construct AppTheme from AppTokens using SemanticMap', () {
      final theme = AppTheme.fromTokens(tokens, semanticMap);

      expect(theme.buttonBackground, const Color(0xFF005BAC));
      expect(theme.buttonForeground, const Color(0xFFFFFFFF));
      expect(theme.cardSurface, const Color(0xFFFAFAFA));
      expect(theme.inputBorder, const Color(0xFF005BAC).withValues(alpha: 0.5));
      expect(theme.cardRadius, 12.0);
      expect(theme.buttonRadius, 8.0);
      expect(theme.fontFamily, 'Inter');
      expect(theme.fontWeight, 600.0);
      expect(theme.fontSize, 16.0);
    });

    test('should copyWith custom and standard values correctly', () {
      final theme = AppTheme.fromTokens(tokens, semanticMap);
      final updatedTheme = theme.copyWith(
        buttonBackground: const Color(0xFFE31837),
        custom: {'newKey': 'newValue'},
      );

      expect(updatedTheme.buttonBackground, const Color(0xFFE31837));
      expect(updatedTheme.buttonForeground, const Color(0xFFFFFFFF));
      expect(updatedTheme.custom?['newKey'], 'newValue');
    });

    test('should snap lerp instantly (no interpolation)', () {
      final theme1 = AppTheme.fromTokens(tokens, semanticMap);
      final theme2 = theme1.copyWith(buttonBackground: const Color(0xFFE31837));

      // Snap boundary: < 0.5 returns theme1, >= 0.5 returns theme2
      final lerpedBegin = theme1.lerp(theme2, 0.49);
      final lerpedEnd = theme1.lerp(theme2, 0.5);

      expect(lerpedBegin.buttonBackground, theme1.buttonBackground);
      expect(lerpedEnd.buttonBackground, theme2.buttonBackground);
    });

    test('should lookup custom values with type-safety and null-safety', () {
      final theme = AppTheme.fromTokens(tokens, semanticMap);

      // Existing keys with matching types
      expect(theme.customValue<String>('partnerLogoUrl'), 'assets/techcom.png');
      expect(theme.customValue<bool>('enablePromo'), isTrue);

      // Non-existent key
      expect(theme.customValue<String>('nonExistentKey'), isNull);

      // Existing key with mismatched type (should return null, not throw)
      expect(theme.customValue<int>('enablePromo'), isNull);
    });
  });
}
