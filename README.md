# Chameleon Theme Engine

A flexible, rule-based, multi-tenant theme engine for Flutter white-label apps. It allows raw brand values to be parsed dynamically from declarative JSON configurations and maps them to semantic UI roles that widgets consume via a `BuildContext` extension. It also supports runtime theme variant switching (e.g., Standard to VIP) based on authenticated user segments with local storage persistence and dynamic custom theme extensions.

---

## Features

- **Declarative Onboarding**: Onboard a new tenant by adding a single JSON file without changing any widget code.
- **Rule-Based Runtime Switching**: Instantly switch theme variants (e.g., `default` to `vip`) when user segments are determined, with immediate transition-free UI updates.
- **Strict Widget Isolation**: Prevents raw color and spacing literals in widget code using automated compliance checks. Widgets only consume named semantic roles.
- **Robust Per-Token Fallback**: Missing or malformed individual tokens degrade gracefully to safe neutral monochrome defaults, logging details without crashing.
- **Dynamic Custom Extensions**: Query arbitrary, non-standard configs inside the tenant JSON through type-safe dynamic lookups.
- **Persisted State**: Automatically stores and restores the active variant key using `shared_preferences`.

---

## Directory Structure

```text
chameleon_theme/
├── assets/configs/tenants/     # Bundled tenant configuration files
│   ├── xbank.json              # Bank X configuration (default + VIP variants)
│   └── newbank.json            # Bank New configuration
├── lib/
│   ├── chameleon_theme.dart    # Gói export chính
│   └── features/theme/
│       ├── data/
│       │   ├── config_service.dart      # Loads and decodes tenant JSON assets
│       │   └── theme_config.dart        # JSON-serializable envelope models
│       ├── domain/
│       │   ├── app_tokens.dart          # Raw primitive design tokens
│       │   ├── app_theme.dart           # Semantic role layer (ThemeExtension)
│       │   ├── theme_rules.dart         # Segment to variant mapping resolver
│       │   ├── tenant_theme_registry.dart # Variant registry
│       │   └── user_context.dart        # User segment context wrapper
│       └── presentation/
│           ├── theme_service.dart       # ChangeNotifier orchestrator
│           ├── app_theme_x.dart         # BuildContext extensions and helpers
│           └── theme_defaults.dart      # Safe fallback design tokens
├── example/                     # Example app showcasing runtime switching
│   ├── lib/main.dart            # Bootstrap, manual DI, and interactive dashboard
│   └── test/widget_test.dart    # Smoke test for example app
└── test/
    ├── unit/                    # Unit tests for domain parsing & compliance
    └── widget/                  # Widget tests for runtime theme switching
```

---

## Onboarding a New Tenant

To configure a new tenant (e.g., `mybank`):

1. **Add Tenant Config JSON**: Create `assets/configs/tenants/mybank.json` and declare the variants, rule mapping, and semantic map:

```json
{
  "themes": {
    "default": {
      "colors": {
        "primary": "#005BAC",
        "secondary": "#4A5568",
        "surface": "#FAFAFA",
        "onPrimary": "#FFFFFF"
      },
      "typography": {
        "fontFamily": "Inter",
        "fontWeight": 400.0,
        "fontSize": 14.0
      },
      "radii": {
        "card": 12.0,
        "button": 8.0
      },
      "spacing": {
        "xs": 4.0,
        "sm": 8.0,
        "md": 16.0
      },
      "semanticMap": {
        "buttonBackground": "primary",
        "buttonForeground": "onPrimary",
        "cardSurface": "surface",
        "cardRadius": "card",
        "buttonRadius": "button"
      }
    }
  },
  "themeRules": {
    "default": "default"
  }
}
```

2. **Register Asset**: Make sure the assets directory is declared in the root `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/configs/tenants/
```

---

## Usage

### 1. Bootstrapping (Dependency Injection)

Bootstrap the theme engine at application startup in your `main()` method:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final configService = ConfigService();
  TenantThemeRegistry? registry;
  AppTheme initialTheme = ThemeDefaults.tokens;

  try {
    // Load config for the active tenant (selected at build time or configuration)
    final config = await configService.load('xbank');
    registry = TenantThemeRegistry.fromConfig(config, tenantKey: 'xbank');

    final defaultVariant = registry.rules.defaultVariant;
    final defaultTokens = registry.variants[defaultVariant] ?? ThemeDefaults.appTokens;
    initialTheme = AppTheme.fromTokens(defaultTokens, defaultTokens.semanticMap);
  } catch (e) {
    // Falls back safely if loading fails, or let it propagate for unparseable JSON
    rethrow;
  }

  final themeService = ThemeService(initialTheme, registry: registry);

  runApp(MyApp(themeService: themeService));
}
```

### 2. Wrapping your App

Expose the `ThemeService` through a `ListenableBuilder` to trigger rebuilds on variant changes:

```dart
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
          themeAnimationDuration: Duration.zero, // Ensures instant cut transitions
          theme: ThemeData(
            extensions: [activeTheme],
          ),
          home: MyHomePage(themeService: themeService),
        );
      },
    );
  }
}
```

### 3. Consuming Semantic Roles in Widgets

To prevent coupling widgets to raw values, **never** hardcode colors. Import the theme engine package and consume named semantic roles via `context.appTheme`:

```dart
import 'package:chameleon_theme/chameleon_theme.dart';

Widget build(BuildContext context) {
  final theme = context.appTheme;

  return Container(
    padding: EdgeInsets.all(theme.cardRadius),
    decoration: BoxDecoration(
      color: theme.cardSurface,
      borderRadius: BorderRadius.circular(theme.cardRadius),
      border: BorderSide(color: theme.inputBorder),
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.buttonBackground,
        foregroundColor: theme.buttonForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(theme.buttonRadius),
        ),
      ),
      onPressed: () {},
      child: Text(
        'Submit',
        style: TextStyle(
          fontFamily: theme.fontFamily,
          fontSize: theme.fontSize,
        ),
      ),
    ),
  );
}
```

---

## Dynamic Custom Config Extensions

For tenant-specific, non-standard configuration (e.g., enabling custom promotions or logos):

1. **Declare custom properties** in the JSON config under the `custom` block:
```json
"custom": {
  "enablePromo": true,
  "promoBannerBg": "#D4AF37",
  "partnerLogoUrl": "assets/images/vip_logo.png"
}
```

2. **Query custom properties** inside widget build methods:
```dart
final bool enablePromo = theme.customValue<bool>('enablePromo') ?? false;
final Color? promoBg = theme.customColor('promoBannerBg');
```
*Note: `theme.customColor` is a helper extension on `AppTheme` that safely parses hex color strings. Non-existent keys or type-mismatches will return `null` without crashing.*

---

## Compliance and Quality Checks

To ensure strict widget isolation, the automated compliance test suite `test/unit/widget_compliance_test.dart` scans all widget files outside the theme library for forbidden raw color literals like `Color(0x...)`, `Color.fromARGB(...)`, and `Color.fromRGBO(...)`.

To run tests and static analysis:

```bash
# Get dependencies
fvm flutter pub get

# Generate JSON serialization code
fvm dart run build_runner build --delete-conflicting-outputs

# Run all core tests (unit, widget, and compliance checks)
fvm flutter test

# Run static analysis
fvm flutter analyze
```
