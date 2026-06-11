import 'package:flutter_test/flutter_test.dart';
import 'package:chameleon_theme/features/theme/domain/theme_rules.dart';

void main() {
  group('ThemeRules Tests', () {
    test('should parse theme rules from JSON correctly', () {
      final json = {
        'default': 'default',
        'conditions': {
          'VIP': 'vip',
          'BLACK': 'vip',
        }
      };

      final rules = ThemeRules.fromJson(json);

      expect(rules.defaultVariant, 'default');
      expect(rules.segmentToVariant['VIP'], 'vip');
      expect(rules.segmentToVariant['BLACK'], 'vip');
    });

    test('should resolve variant name based on segment match', () {
      final rules = ThemeRules(
        defaultVariant: 'default',
        segmentToVariant: const {'VIP': 'vip', 'BLACK': 'vip'},
      );

      // Matched segment
      expect(rules.variantFor('VIP'), 'vip');
      expect(rules.variantFor('BLACK'), 'vip');

      // Unmatched segment
      expect(rules.variantFor('STANDARD'), 'default');
      expect(rules.variantFor(null), 'default');
    });
  });
}
