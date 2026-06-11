/// Resolves user segment to theme variant name based on rules declared in JSON.
class ThemeRules {
  final String defaultVariant;
  final Map<String, String> segmentToVariant;

  ThemeRules({
    required this.defaultVariant,
    required this.segmentToVariant,
  });

  /// Factory constructor to parse ThemeRules from a JSON map.
  factory ThemeRules.fromJson(Map<String, dynamic> json) {
    final def = json['default'] as String? ?? 'default';
    final cond = json['conditions'] is Map ? json['conditions'] as Map<String, dynamic> : const <String, dynamic>{};
    final map = <String, String>{};
    cond.forEach((k, v) {
      if (v is String) {
        map[k] = v;
      }
    });
    return ThemeRules(
      defaultVariant: def,
      segmentToVariant: map,
    );
  }

  /// Resolves the variant name for the given segment.
  /// Falls back to the defaultVariant if the segment is null or not matched.
  String variantFor(String? segment) {
    if (segment == null) return defaultVariant;
    return segmentToVariant[segment] ?? defaultVariant;
  }
}
