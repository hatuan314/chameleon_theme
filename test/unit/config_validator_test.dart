import 'package:flutter_test/flutter_test.dart';
import 'package:chameleon_theme/features/theme/domain/config_validator.dart';
import 'package:chameleon_theme/features/theme/domain/validation_exception.dart';

void main() {
  group('ConfigValidator Tests', () {
    test('should validate valid configuration map without error', () {
      final validJson = {
        'themes': {
          'default': {
            'colors': {
              'primary': '#E31837',
              'secondary': '#4A5568',
              'surface': '#FFFFFF',
              'onPrimary': '#FFFFFF',
            },
            'radii': {
              'sm': 8.0,
            },
            'semanticMap': {
              'buttonBackground': 'primary',
              'cardRadius': 'sm',
            }
          }
        },
        'theme_rules': {
          'default': 'default',
          'conditions': {
            'VIP': 'default',
          }
        }
      };

      expect(() => ConfigValidator.validate(validJson), returnsNormally);
    });

    test('should collect root property errors', () {
      final invalidJson = <String, dynamic>{};

      expect(
        () => ConfigValidator.validate(invalidJson),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.errors,
            'errors',
            containsAll([
              "Root property 'themes' is required and must be a non-empty Map",
              "Root property 'theme_rules' is required and must be a Map",
            ]),
          ),
        ),
      );
    });

    test('should collect variant type errors', () {
      final Map<String, dynamic> invalidJson = {
        'themes': {
          'default': 'not-a-map',
        },
        'theme_rules': {
          'default': 'default',
          'conditions': <String, String>{},
        }
      };

      expect(
        () => ConfigValidator.validate(invalidJson),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.errors,
            'errors',
            contains("Theme variant 'default' must be a Map"),
          ),
        ),
      );
    });

    test('should collect token group type errors', () {
      final Map<String, dynamic> invalidJson = {
        'themes': {
          'default': {
            'colors': 'not-a-map',
            'typography': 'not-a-map',
            'spacing': 'not-a-map',
            'radii': 'not-a-map',
            'semanticMap': 'not-a-map',
          }
        },
        'theme_rules': {
          'default': 'default',
          'conditions': <String, String>{},
        }
      };

      expect(
        () => ConfigValidator.validate(invalidJson),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.errors,
            'errors',
            containsAll([
              "Token group 'colors' in variant 'default' must be a Map",
              "Token group 'typography' in variant 'default' must be a Map",
              "Token group 'spacing' in variant 'default' must be a Map",
              "Token group 'radii' in variant 'default' must be a Map",
              "Token group 'semanticMap' in variant 'default' must be a Map",
            ]),
          ),
        ),
      );
    });

    test('should validate hex color patterns', () {
      final Map<String, dynamic> invalidJson = {
        'themes': {
          'default': {
            'colors': {
              'primary': 'red',
              'secondary': '#FF00',
              'surface': '#GGGGGG',
              'onPrimary': '123456',
              'accent': '#FF00FF00', // valid 8-char
              'divider': '#FFF', // valid 3-char
              'border': '#fF00aa', // valid 6-char case-insensitive
            }
          }
        },
        'theme_rules': {
          'default': 'default',
          'conditions': <String, String>{},
        }
      };

      expect(
        () => ConfigValidator.validate(invalidJson),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.errors,
            'errors',
            containsAll([
              "Invalid hex color value 'red' for key 'primary' in variant 'default'",
              "Invalid hex color value '#FF00' for key 'secondary' in variant 'default'",
              "Invalid hex color value '#GGGGGG' for key 'surface' in variant 'default'",
              "Invalid hex color value '123456' for key 'onPrimary' in variant 'default'",
            ]),
          ),
        ),
      );
    });

    test('should validate theme rules default and conditions targets', () {
      final invalidJson = {
        'themes': {
          'default': {
            'colors': {'primary': '#E31837'}
          }
        },
        'theme_rules': {
          'default': 'premium',
          'conditions': {
            'VIP': 'vip_variant',
          }
        }
      };

      expect(
        () => ConfigValidator.validate(invalidJson),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.errors,
            'errors',
            containsAll([
              "Default theme variant 'premium' in 'theme_rules' is not defined under 'themes'",
              "Conditional theme variant 'vip_variant' in 'theme_rules.conditions' is not defined under 'themes'",
            ]),
          ),
        ),
      );
    });

    test('should validate semanticMap references pointing to existing tokens', () {
      final Map<String, dynamic> invalidJson = {
        'themes': {
          'default': {
            'colors': {
              'primary': '#E31837',
            },
            'radii': {
              'sm': 8.0,
            },
            'semanticMap': {
              'buttonBackground': 'accent', // undefined color token
              'cardRadius': 'lg', // undefined radius token
            }
          }
        },
        'theme_rules': {
          'default': 'default',
          'conditions': <String, String>{},
        }
      };

      expect(
        () => ConfigValidator.validate(invalidJson),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.errors,
            'errors',
            containsAll([
              "semanticMap role 'buttonBackground' in variant 'default' references undefined token key 'accent'",
              "semanticMap role 'cardRadius' in variant 'default' references undefined token key 'lg'",
            ]),
          ),
        ),
      );
    });

    test('should validate error sorting and deduplication', () {
      // Input has errors at different levels:
      // 1. Root errors: missing 'theme_rules'
      // 2. Variant default errors: invalid hex color
      // 3. Duplicate errors: if we somehow trigger duplicates (though validation logic shouldn't duplicate,
      //    we check that list is deduplicated).
      final invalidJson = {
        'themes': {
          'default': {
            'colors': {
              'primary': 'invalid_color',
              'secondary': 'invalid_color', // same error value for different key
            }
          }
        },
        // 'theme_rules' is missing (root error)
      };

      expect(
        () => ConfigValidator.validate(invalidJson),
        throwsA(
          isA<ValidationException>().having(
            (e) {
              // Verify root errors come before variant errors
              final rootIdx = e.errors.indexOf("Root property 'theme_rules' is required and must be a Map");
              final varIdx = e.errors.indexWhere((err) => err.contains('default'));
              expect(rootIdx, lessThan(varIdx));
              return e.errors;
            },
            'errors',
            hasLength(3), // 1 root, 2 variant
          ),
        ),
      );
    });

    test('should pass performance benchmark (SC-002)', () {
      final typicalJson = {
        'themes': {
          'default': {
            'colors': {
              'primary': '#E31837',
              'secondary': '#4A5568',
              'surface': '#FFFFFF',
              'onPrimary': '#FFFFFF',
            },
            'radii': {
              'sm': 8.0,
              'md': 12.0,
            },
            'semanticMap': {
              'buttonBackground': 'primary',
              'cardRadius': 'sm',
            }
          },
          'dark': {
            'colors': {
              'primary': '#1A1A1A',
              'secondary': '#FFFFFF',
              'surface': '#000000',
              'onPrimary': '#FFFFFF',
            },
            'radii': {
              'sm': 8.0,
            },
            'semanticMap': {
              'buttonBackground': 'primary',
              'cardRadius': 'sm',
            }
          }
        },
        'theme_rules': {
          'default': 'default',
          'conditions': {
            'dark_mode': 'dark',
          }
        }
      };

      // Warm-up
      for (var i = 0; i < 100; i++) {
        ConfigValidator.validate(typicalJson);
      }

      final stopwatch = Stopwatch()..start();
      const iterations = 1000;
      for (var i = 0; i < iterations; i++) {
        ConfigValidator.validate(typicalJson);
      }
      stopwatch.stop();

      final averageMs = stopwatch.elapsedMilliseconds / iterations;
      // SC-002: average execution must be < 10ms
      expect(averageMs, lessThan(10.0));
    });
  });
}
