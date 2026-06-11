import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chameleon_theme/features/theme/domain/app_tokens.dart';
import 'package:chameleon_theme/features/theme/domain/app_theme.dart';
import 'package:chameleon_theme/features/theme/domain/theme_rules.dart';
import 'package:chameleon_theme/features/theme/domain/tenant_theme_registry.dart';
import 'package:chameleon_theme/features/theme/domain/user_context.dart';
import 'package:chameleon_theme/features/theme/presentation/theme_service.dart';
import 'package:chameleon_theme/features/theme/presentation/app_theme_x.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Runtime Theme Variant Switch Widget Tests', () {
    testWidgets('should update UI instantly when variant switches', (WidgetTester tester) async {
      final semanticMap = {
        'buttonBackground': 'primary',
        'buttonForeground': 'onPrimary',
      };

      final defaultTokens = AppTokens(
        colorPrimary: const Color(0xFF005BAC),
        colorSecondary: const Color(0xFF4A5568),
        colorSurface: const Color(0xFFFFFFFF),
        colorOnPrimary: const Color(0xFFFFFFFF),
        fontFamily: 'Inter',
        fontWeight: 400.0,
        fontSize: 14.0,
        spacing: const {},
        radii: const {},
        semanticMap: semanticMap,
      );

      final vipTokens = AppTokens(
        colorPrimary: const Color(0xFFD4AF37),
        colorSecondary: const Color(0xFF212121),
        colorSurface: const Color(0xFF121212),
        colorOnPrimary: const Color(0xFF000000),
        fontFamily: 'Playfair Display',
        fontWeight: 700.0,
        fontSize: 14.0,
        spacing: const {},
        radii: const {},
        semanticMap: semanticMap,
      );

      final registry = TenantThemeRegistry(
        variants: {
          'default': defaultTokens,
          'vip': vipTokens,
        },
        rules: ThemeRules(
          defaultVariant: 'default',
          segmentToVariant: const {'VIP': 'vip'},
        ),
        tenantKey: 'xbank',
      );

      final initialTheme = AppTheme.fromTokens(defaultTokens, semanticMap);
      final themeService = ThemeService(initialTheme, registry: registry);

      await tester.pumpWidget(
        ListenableBuilder(
          listenable: themeService,
          builder: (context, child) {
            final activeTheme = themeService.current;
            return MaterialApp(
              themeAnimationDuration: Duration.zero,
              theme: ThemeData(
                extensions: [activeTheme],
              ),
              home: Scaffold(
                body: Builder(
                  builder: (ctx) {
                    return Container(
                      key: const Key('theme-probe'),
                      color: ctx.appTheme.buttonBackground,
                    );
                  },
                ),
              ),
            );
          },
        ),
      );

      // Verify initial default theme primary color is applied
      var container = tester.widget<Container>(find.byKey(const Key('theme-probe')));
      expect(container.color, const Color(0xFF005BAC));

      // Apply VIP user context
      themeService.applyForUser(const UserContext(segment: 'VIP'));
      await tester.pump(); // Pump one frame

      // Verify VIP theme is applied immediately
      container = tester.widget<Container>(find.byKey(const Key('theme-probe')));
      expect(container.color, const Color(0xFFD4AF37));

      // Revert back to Standard
      themeService.applyForUser(const UserContext(segment: 'STANDARD'));
      await tester.pump(); // Pump one frame

      // Verify it reverts to default
      container = tester.widget<Container>(find.byKey(const Key('theme-probe')));
      expect(container.color, const Color(0xFF005BAC));
    });
  });
}
