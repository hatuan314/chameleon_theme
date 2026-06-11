import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chameleon_theme/features/theme/data/config_service.dart';

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
  });
}
