import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chameleon_theme/features/theme/data/config_service.dart';
import 'package:chameleon_theme/features/theme/domain/validation_exception.dart';

class FakeAssetBundle extends AssetBundle {
  final Map<String, String> assets;

  FakeAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
    throw Exception('Asset not found: $key');
  }

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }
}

void main() {
  group('ConfigService Tests', () {
    test('should load and parse valid tenant config JSON', () async {
      final fakeBundle = FakeAssetBundle({
        'packages/chameleon_theme/assets/configs/tenants/techcombank.json': '''
        {
          "themes": {
            "default": {
              "colors": {
                "primary": "#E31837"
              },
              "typography": {
                "fontFamily": "Inter"
              }
            }
          },
          "theme_rules": {
            "default": "default"
          }
        }
        '''
      });

      final service = ConfigService(assetBundle: fakeBundle);
      final config = await service.load('techcombank');

      expect(config.themes.containsKey('default'), isTrue);
      expect(config.themeRules['default'], 'default');
    });

    test('should throw Exception on invalid JSON syntax', () async {
      final fakeBundle = FakeAssetBundle({
        'packages/chameleon_theme/assets/configs/tenants/badbank.json': 'invalid-json-syntax'
      });

      final service = ConfigService(assetBundle: fakeBundle);

      expect(
        () => service.load('badbank'),
        throwsException,
      );
    });

    test('should throw Exception on missing config file', () async {
      final fakeBundle = FakeAssetBundle({});
      final service = ConfigService(assetBundle: fakeBundle);

      expect(
        () => service.load('missingbank'),
        throwsException,
      );
    });

    group('loadFromJson', () {
      test('should parse and load valid JSON map successfully', () async {
        final Map<String, dynamic> jsonMap = {
          'themes': {
            'default': {
              'colors': {'primary': '#E31837'}
            }
          },
          'theme_rules': {
            'default': 'default',
            'conditions': <String, String>{}
          }
        };

        final service = ConfigService();
        final config = await service.loadFromJson(jsonMap);

        expect(config.themes.containsKey('default'), isTrue);
        final defaultTheme = config.themes['default'] as Map<String, dynamic>;
        final colors = defaultTheme['colors'] as Map<String, dynamic>;
        expect(colors['primary'], '#E31837');
        expect(config.themeRules['default'], 'default');
      });
    });

    group('loadFromJsonString', () {
      test('should parse and load valid JSON string successfully', () async {
        final jsonStr = '''
        {
          "themes": {
            "default": {
              "colors": { "primary": "#E31837" }
            }
          },
          "theme_rules": {
            "default": "default",
            "conditions": {}
          }
        }
        ''';

        final service = ConfigService();
        final config = await service.loadFromJsonString(jsonStr);

        expect(config.themes.containsKey('default'), isTrue);
        final defaultTheme = config.themes['default'] as Map<String, dynamic>;
        final colors = defaultTheme['colors'] as Map<String, dynamic>;
        expect(colors['primary'], '#E31837');
      });

      test('should throw FormatException on invalid JSON syntax', () async {
        final service = ConfigService();
        expect(
          () => service.loadFromJsonString('{"themes": {'),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw ValidationException when root is not a JSON object', () async {
        final service = ConfigService();
        expect(
          () => service.loadFromJsonString('["not-a-map"]'),
          throwsA(isA<ValidationException>()),
        );
      });
    });
  });
}
