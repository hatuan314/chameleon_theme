import 'package:json_annotation/json_annotation.dart';

part 'theme_config.g.dart';

/// Decodes the top-level structure of the tenant JSON configuration.
/// Uses snake_case field renaming (e.g., theme_rules -> themeRules).
@JsonSerializable(fieldRename: FieldRename.snake)
class ThemeConfig {
  final Map<String, dynamic> themes;
  final Map<String, dynamic> themeRules;

  ThemeConfig({
    required this.themes,
    required this.themeRules,
  });

  /// Factory constructor to parse JSON into ThemeConfig.
  factory ThemeConfig.fromJson(Map<String, dynamic> json) => _$ThemeConfigFromJson(json);

  /// Converts ThemeConfig instance to a JSON map.
  Map<String, dynamic> toJson() => _$ThemeConfigToJson(this);
}
