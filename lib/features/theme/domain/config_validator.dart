import 'validation_exception.dart';

/// A validation utility for raw theme configuration maps.
///
/// This class validates JSON schema, data type constraints, formatting
/// (e.g. hex colors), and semantic cross-references before the configuration
/// is parsed into domain models, preventing invalid runtime states.
class ConfigValidator {
  ConfigValidator._();

  // Compiled once per isolate — used on the performance-sensitive validate() path (SC-002).
  static final RegExp _hexColorRegex =
      RegExp(r'^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

  // Maps each known semanticMap role to the token group it must reference.
  // Centralises role→group knowledge so a new role only needs one edit here.
  static const Map<String, String> _roleToGroup = {
    'buttonBackground': 'colors',
    'buttonForeground': 'colors',
    'cardSurface': 'colors',
    'cardRadius': 'radii',
    'buttonRadius': 'radii',
  };

  // Sanitises an attacker-controlled value before embedding it in an error
  // message: strips control characters (prevents log/ANSI injection if a host
  // app forwards these messages to a logger) and truncates to a safe length
  // (prevents oversized values from bloating logs).
  static String _safe(Object? value) {
    final text = value.toString().replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    return text.length > 64 ? '${text.substring(0, 64)}…' : text;
  }

  /// Validates the provided raw [json] configuration map.
  ///
  /// Throws a [ValidationException] containing all collected errors if
  /// any validation rules are violated. Errors are returned in structural
  /// order (root errors first, then variant errors sorted by variant name,
  /// then rules errors) with duplicates removed (SC-001).
  static void validate(Map<String, dynamic> json) {
    final rootErrors = <String>[];
    final variantErrorsMap = <String, List<String>>{};
    final rulesErrors = <String>[];

    // 1. Root Level Checks
    final themes = json['themes'];
    if (themes == null || themes is! Map || themes.isEmpty) {
      rootErrors.add("Root property 'themes' is required and must be a non-empty Map");
    }

    final themeRules = json['theme_rules'];
    if (themeRules == null || themeRules is! Map) {
      rootErrors.add("Root property 'theme_rules' is required and must be a Map");
    }

    // 2. Theme Variant Checks (under "themes")
    if (themes is Map) {
      for (final entry in themes.entries) {
        if (entry.key is! String) {
          rootErrors.add("Theme variant key '${_safe(entry.key)}' must be a String");
          continue;
        }
        final variantName = entry.key as String;
        final variant = entry.value;

        if (variant is! Map) {
          variantErrorsMap.putIfAbsent(variantName, () => []).add("Theme variant '${_safe(variantName)}' must be a Map");
          continue;
        }

        final variantErrors = <String>[];

        // Verify each optional token group is a Map when present (FR-009)
        for (final groupName in const ['colors', 'typography', 'spacing', 'radii', 'semanticMap']) {
          final group = variant[groupName];
          if (group != null && group is! Map) {
            variantErrors.add("Token group '$groupName' in variant '${_safe(variantName)}' must be a Map");
          }
        }

        // Validate hex color values (FR-004)
        final colors = variant['colors'];
        if (colors is Map) {
          for (final colorEntry in colors.entries) {
            final colorKey = colorEntry.key;
            final colorValue = colorEntry.value;
            if (colorValue is! String || !_hexColorRegex.hasMatch(colorValue)) {
              variantErrors.add("Invalid hex color value '${_safe(colorValue)}' for key '${_safe(colorKey)}' in variant '${_safe(variantName)}'");
            }
          }
        }

        // Validate semanticMap cross-references (FR-010)
        final semanticMap = variant['semanticMap'];
        if (semanticMap is Map) {
          for (final roleEntry in semanticMap.entries) {
            final roleKey = roleEntry.key;
            final tokenKey = roleEntry.value;
            if (tokenKey is! String) continue;
            final groupName = _roleToGroup[roleKey];
            if (groupName == null) continue;
            final groupMap = variant[groupName];
            if (groupMap is! Map || !groupMap.containsKey(tokenKey)) {
              variantErrors.add(
                "semanticMap role '${_safe(roleKey)}' in variant '${_safe(variantName)}' references undefined token key '${_safe(tokenKey)}'",
              );
            }
          }
        }

        if (variantErrors.isNotEmpty) {
          variantErrorsMap.putIfAbsent(variantName, () => []).addAll(variantErrors);
        }
      }
    }

    // 3. Theme Rules Checks (under "theme_rules")
    if (themeRules is Map) {
      final defaultVariant = themeRules['default'];
      if (defaultVariant == null || defaultVariant is! String) {
        rulesErrors.add("Property 'default' under 'theme_rules' is required and must be a String");
      } else {
        if (themes is Map && !themes.containsKey(defaultVariant)) {
          rulesErrors.add("Default theme variant '${_safe(defaultVariant)}' in 'theme_rules' is not defined under 'themes'");
        }
      }

      final conditions = themeRules['conditions'];
      if (conditions == null || conditions is! Map) {
        rulesErrors.add("Property 'conditions' under 'theme_rules' is required and must be a Map");
      } else {
        for (final conditionEntry in conditions.entries) {
          final targetVariant = conditionEntry.value;
          if (targetVariant is! String) continue;
          if (themes is Map && !themes.containsKey(targetVariant)) {
            rulesErrors.add("Conditional theme variant '${_safe(targetVariant)}' in 'theme_rules.conditions' is not defined under 'themes'");
          }
        }
      }
    }

    // 4. Assemble: root first, variants sorted by name, rules last (SC-001)
    final allErrors = <String>[
      ...rootErrors,
      for (final name in (variantErrorsMap.keys.toList()..sort()))
        ...variantErrorsMap[name] ?? const [],
      ...rulesErrors,
    ];

    // Deduplicate while preserving structural order (SC-001)
    final seen = <String>{};
    final dedupedErrors = [for (final e in allErrors) if (seen.add(e)) e];

    if (dedupedErrors.isNotEmpty) {
      throw ValidationException(dedupedErrors);
    }
  }
}
