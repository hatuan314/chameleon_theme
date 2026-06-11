import 'package:flutter/material.dart';
import 'package:chameleon_theme/chameleon_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:module_a/module_a.dart';
import 'package:module_b/module_b.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = ConfigService();
  TenantThemeRegistry? registry;
  AppTheme initialTheme = ThemeDefaults.tokens;

  try {
    final config = await configService.load('xbank');
    registry = TenantThemeRegistry.fromConfig(config, tenantKey: 'xbank');

    final defaultVariant = registry.rules.defaultVariant;
    final defaultTokens =
        registry.variants[defaultVariant] ?? ThemeDefaults.appTokens;
    initialTheme = AppTheme.fromTokens(defaultTokens, defaultTokens.semanticMap);
  } catch (e) {
    debugPrint('Error loading initial config: $e');
  }

  final themeService = ThemeService(initialTheme, registry: registry);

  runApp(MainApp(themeService: themeService));
}

class MainApp extends StatefulWidget {
  final ThemeService themeService;

  const MainApp({super.key, required this.themeService});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              HomeScreen(themeService: widget.themeService),
        ),
        GoRoute(
          path: '/module_a',
          builder: (context, state) =>
              ModuleAScreen(themeService: widget.themeService),
        ),
        GoRoute(
          path: '/module_b',
          builder: (context, state) =>
              ModuleBScreen(themeService: widget.themeService),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.themeService,
      builder: (context, child) {
        final activeTheme = widget.themeService.current;
        return MaterialApp.router(
          title: 'Monorepo Chameleon Theme Demo',
          themeAnimationDuration: Duration.zero,
          theme: ThemeData(extensions: [activeTheme]),
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
