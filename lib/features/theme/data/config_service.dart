import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/config_validator.dart';
import '../domain/validation_exception.dart';
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

  /// Validates [json] against theme schema, then parses it into a [ThemeConfig].
  ///
  /// Throws a [ValidationException] if validation fails.
  /// This method is introduced to support dynamic configuration fetching
  /// from remote servers, removing compile-time/bundled asset dependencies.
  Future<ThemeConfig> loadFromJson(Map<String, dynamic> json) async {
    ConfigValidator.validate(json);
    try {
      return ThemeConfig.fromJson(json);
    } on TypeError catch (e) {
      // The validator only guards the structure it knows about; a malformed
      // nested shape can still trip a cast inside the generated fromJson.
      // Surface it as a ValidationException to honour this method's contract.
      throw ValidationException(['Failed to parse configuration into ThemeConfig: $e']);
    }
  }

  /// Decodes [jsonString], validates it, and parses it into a [ThemeConfig].
  ///
  /// Throws a [FormatException] if [jsonString] contains invalid JSON syntax.
  /// Throws a [ValidationException] if validation rules are violated, including
  /// when the decoded value is not a JSON object (Map).
  /// This enables loading configurations retrieved directly as text payloads.
  Future<ThemeConfig> loadFromJsonString(String jsonString) async {
    final decoded = json.decode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw ValidationException(const ['Configuration root must be a JSON object (Map)']);
    }
    return loadFromJson(decoded);
  }
}
