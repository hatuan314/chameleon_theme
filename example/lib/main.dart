import 'package:chameleon_theme_example/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chameleon_theme/chameleon_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = ConfigService();
  TenantThemeRegistry? registry;
  AppTheme initialTheme = ThemeDefaults.tokens;

  try {
    // Load config dynamically from a JSON string to showcase the new 002-json-config-loading API.
    final jsonString = await rootBundle.loadString(
      'packages/chameleon_theme/assets/configs/tenants/xbank.json',
    );
    final config = await configService.loadFromJsonString(jsonString);
    registry = TenantThemeRegistry.fromConfig(config, tenantKey: 'xbank');

    final defaultVariant = registry.rules.defaultVariant;
    final defaultTokens =
        registry.variants[defaultVariant] ?? ThemeDefaults.appTokens;
    initialTheme = AppTheme.fromTokens(
      defaultTokens,
      defaultTokens.semanticMap,
    );
  } catch (e) {
    // Rely on per-token and full-variant fallback or let exception propagate.
    // As per FR-030/FR-007, invalid JSON (unparseable) -> unrecoverable exception.
    rethrow;
  }

  final themeService = ThemeService(initialTheme, registry: registry);

  runApp(MyApp(themeService: themeService));
}

class MyApp extends StatelessWidget {
  final ThemeService themeService;

  const MyApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, child) {
        final activeTheme = themeService.current;
        return MaterialApp(
          title: 'Chameleon Theme Engine',
          themeAnimationDuration: Duration.zero,
          theme: ThemeData(extensions: [activeTheme]),
          home: MyHomePage(themeService: themeService),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
