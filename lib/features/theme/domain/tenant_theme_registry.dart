import 'dart:developer' as dev;
import '../data/theme_config.dart';
import '../presentation/theme_defaults.dart';
import 'app_tokens.dart';
import 'theme_rules.dart';
import 'user_context.dart';

/// Registry holding all parsed theme variants and segment rules for a tenant.
class TenantThemeRegistry {
  final Map<String, AppTokens> variants;
  final ThemeRules rules;
  final String tenantKey;

  TenantThemeRegistry({
    required this.variants,
    required this.rules,
    required this.tenantKey,
  });

  /// Factory constructor to parse the complete registry from ThemeConfig.
  factory TenantThemeRegistry.fromConfig(ThemeConfig config, {required String tenantKey}) {
    final parsedVariants = <String, AppTokens>{};
    config.themes.forEach((variantName, variantJson) {
      if (variantJson is Map<String, dynamic>) {
        parsedVariants[variantName] = AppTokens.fromJson(variantJson, tenantKey: tenantKey);
      }
    });

    final rules = ThemeRules.fromJson(config.themeRules);
    return TenantThemeRegistry(
      variants: parsedVariants,
      rules: rules,
      tenantKey: tenantKey,
    );
  }

  /// Resolves the AppTokens corresponding to the segment carried by [user].
  /// Employs variant fallback and safe defaults fallback on config mismatches (FR-009).
  AppTokens resolve(UserContext user) {
    final segment = user.segment;
    final variantKey = rules.variantFor(segment);
    final variantTokens = variants[variantKey];
    if (variantTokens != null) {
      return variantTokens;
    }

    _logFallback(variantKey, 'default', tenantKey);

    final defaultTokens = variants[rules.defaultVariant];
    if (defaultTokens != null) {
      return defaultTokens;
    }

    _logFallback(rules.defaultVariant, 'ThemeDefaults.appTokens', tenantKey);

    return ThemeDefaults.appTokens;
  }

  static void _logFallback(String missingVariant, String fallbackVariant, String tenantKey) {
    dev.log(
      'Fallback: Variant "$missingVariant" is missing. Falling back to "$fallbackVariant" for tenant "$tenantKey".',
      name: 'theme_engine',
    );
  }
}
