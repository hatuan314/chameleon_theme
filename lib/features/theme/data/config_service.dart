import 'dart:convert';
import 'package:flutter/services.dart';
import 'theme_config.dart';

/// Service responsible for loading and decoding bundled tenant JSON assets.
class ConfigService {
  final AssetBundle? assetBundle;

  ConfigService({this.assetBundle});

  /// Loads the tenant config by its [tenantKey].
  /// Throws a detailed Exception if the file is missing or contains invalid JSON syntax (FR-007).
  Future<ThemeConfig> load(String tenantKey) async {
    final bundle = assetBundle ?? rootBundle;
    final path = 'packages/chameleon_theme/assets/configs/tenants/$tenantKey.json';
    try {
      final jsonString = await bundle.loadString(path);
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException('Root of config must be a JSON object, got ${decoded.runtimeType}');
      }
      return ThemeConfig.fromJson(decoded);
    } catch (e) {
      // Re-throw to crash startup on unparseable/missing config files (FR-007)
      throw Exception('Failed to load/parse tenant config for "$tenantKey" at path "$path": $e');
    }
  }
}
