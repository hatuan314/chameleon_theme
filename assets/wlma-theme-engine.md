# Flutter White Label Mobile App — Theme Engine Documentation

**Version:** 1.0  
**Scope:** Financial Sector  
**Stack:** Flutter · Monorepo · Clean Architecture

---

## Overview

The theme engine translates raw color and typography values from a tenant's config into a type-safe, widget-consumable theme system. The chosen approach is **Design Token System + ThemeExtension**, which separates primitive values (tokens) from their semantic meaning (semantic layer).

Widgets never reference raw color values. They reference semantic roles — `buttonBackground`, `cardSurface` — and the engine resolves those to the correct token for the active tenant and theme variant.

---

## Two-Layer Architecture

```
JSON config
    │
    ▼
AppTokens          ← primitive values, map 1:1 from JSON
(colorPrimary, spacingMd, radiusMd ...)
    │
    ▼
AppTheme           ← semantic roles, map tokens to meaning
(buttonBackground = colorPrimary, cardRadius = radiusMd ...)
    │
    ▼
Widget
(context.appTheme.buttonBackground)
```

**Token layer** holds raw values from the tenant's JSON. Different tenant → different token values, same class structure.

**Semantic layer** maps those tokens to named roles used in the UI. This layer is identical across all tenants — only the token values flowing into it differ.

---

## AppTokens

```dart
class AppTokens {
  final Color  colorPrimary;
  final Color  colorSecondary;
  final Color  colorSurface;
  final Color  colorOnPrimary;
  final double spacingSm;    // 8px
  final double spacingMd;    // 16px
  final double spacingLg;    // 24px
  final double radiusSm;     // 4px
  final double radiusMd;     // 8px
  final double radiusLg;     // 16px
  final String fontFamily;

  factory AppTokens.fromJson(Map<String, dynamic> json) {
    final colors = json['colors'] as Map<String, dynamic>;
    return AppTokens(
      colorPrimary:   Color(int.parse(colors['primary'].replaceAll('#', '0xFF'))),
      colorSecondary: Color(int.parse(colors['secondary'].replaceAll('#', '0xFF'))),
      colorSurface:   Color(int.parse(colors['surface'].replaceAll('#', '0xFF'))),
      colorOnPrimary: Color(int.parse(colors['onPrimary'].replaceAll('#', '0xFF'))),
      spacingSm:  8,
      spacingMd:  16,
      spacingLg:  24,
      radiusSm:   4,
      radiusMd:   8,
      radiusLg:   16,
      fontFamily: json['typography']['fontFamily'] as String,
    );
  }
}
```

---

## AppTheme (Semantic Layer)

```dart
class AppTheme extends ThemeExtension<AppTheme> {
  final Color  buttonBackground;
  final Color  buttonForeground;
  final Color  cardSurface;
  final Color  inputBorder;
  final double cardRadius;
  final double buttonRadius;
  final String fontFamily;

  // Build semantic layer from tokens
  factory AppTheme.fromTokens(AppTokens t) => AppTheme(
    buttonBackground: t.colorPrimary,
    buttonForeground: t.colorOnPrimary,
    cardSurface:      t.colorSurface,
    inputBorder:      t.colorPrimary.withOpacity(0.5),
    cardRadius:       t.radiusMd,
    buttonRadius:     t.radiusSm,
    fontFamily:       t.fontFamily,
  );

  // Required by ThemeExtension for animation support
  @override
  AppTheme copyWith({...}) => ...;

  @override
  AppTheme lerp(AppTheme? other, double t) => ...;
}
```

---

## Multi-Theme Variants (VIP / Standard)

A tenant can declare multiple theme variants. The active variant is determined at runtime based on the authenticated user's segment.

**Config schema for multi-theme:**

```json
{
  "themes": {
    "default": {
      "colors": { "primary": "#005BAC", "surface": "#FFFFFF" },
      "typography": { "fontFamily": "SVN-Gilroy" }
    },
    "vip": {
      "colors": { "primary": "#C8A951", "surface": "#1A1A2E" },
      "typography": { "fontFamily": "Playfair Display" }
    }
  },
  "themeRules": {
    "default": "default",
    "conditions": [
      { "if": "user.segment == 'VIP'",   "use": "vip" },
      { "if": "user.segment == 'BLACK'", "use": "vip" }
    ]
  }
}
```

**TenantThemeRegistry:**

```dart
class TenantThemeRegistry {
  final Map<String, AppTokens> _variants;
  final ThemeRules _rules;

  // All variants loaded at app launch
  factory TenantThemeRegistry.fromConfig(ThemeConfig config) =>
    TenantThemeRegistry(
      variants: config.themes.map((k, v) => MapEntry(k, AppTokens.fromJson(v))),
      rules:    ThemeRules.fromJson(config.themeRules),
    );

  // Variant resolved after user authenticates
  AppTokens resolve(UserContext user) {
    for (final condition in _rules.conditions) {
      if (condition.evaluate(user)) {
        return _variants[condition.use]!;
      }
    }
    return _variants[_rules.defaultTheme]!;
  }
}
```

**Variant selection timing:**

```
App launch → load all variants into TenantThemeRegistry (no user yet)
    │
User authenticates → server returns user.segment = "VIP"
    │
TenantThemeRegistry.resolve(user) → returns "vip" tokens
    │
ThemeService updates AppTheme → UI rebuilds with VIP theme
```

---

## ThemeService

`ThemeService` is the single entry point for all theme operations. It owns the active `AppTheme` and notifies the widget tree when the theme changes.

```dart
class ThemeService extends ChangeNotifier {
  AppTheme _current;
  AppTheme get current => _current;

  final TenantThemeRegistry _registry;

  void applyForUser(UserContext user) {
    final tokens = _registry.resolve(user);
    _current = AppTheme.fromTokens(tokens);
    notifyListeners(); // widget tree rebuilds
  }
}
```

---

## Registering into MaterialApp

```dart
void main() async {
  final config  = await ConfigService().load('vpbank');
  final registry = TenantThemeRegistry.fromConfig(config.theme);
  final theme    = AppTheme.fromTokens(registry.resolve(UserContext.anonymous()));

  getIt.registerSingleton<TenantThemeRegistry>(registry);
  getIt.registerSingleton<ThemeService>(ThemeService(theme));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: getIt<ThemeService>(),
      builder: (context, _) {
        final appTheme = getIt<ThemeService>().current;
        return MaterialApp(
          theme: ThemeData(
            fontFamily: appTheme.fontFamily,
            extensions: [appTheme],
          ),
          home: HomeScreen(),
        );
      },
    );
  }
}
```

---

## Widget Usage

Widgets access the semantic layer through a BuildContext extension — they never reference raw colors or spacing values.

```dart
extension AppThemeX on BuildContext {
  AppTheme get appTheme => Theme.of(this).extension<AppTheme>()!;
}

// In a widget
Container(
  decoration: BoxDecoration(
    color:        context.appTheme.cardSurface,
    borderRadius: BorderRadius.circular(context.appTheme.cardRadius),
  ),
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: context.appTheme.buttonBackground,
      foregroundColor: context.appTheme.buttonForeground,
    ),
    onPressed: () {},
    child: Text('Confirm'),
  ),
)
```

---

## Adding a New Tenant

To onboard a new tenant with a completely different visual identity:

1. Create `configs/tenants/newbank.json` with the `theme` domain filled in.
2. Run CI validation — no code changes required.
3. `flutter build --flavor newbank` — the theme engine picks up the new tokens automatically.

No widget code is modified. The semantic layer remains unchanged.

---

## Summary

| Concern | Solution |
|---|---|
| Per-tenant colors and fonts | `AppTokens` loaded from JSON |
| Semantic roles for widgets | `AppTheme` (ThemeExtension) |
| Multiple brand variants per tenant | `TenantThemeRegistry` + `ThemeRules` |
| Runtime theme switching (VIP) | `ThemeService.applyForUser()` |
| Widget isolation from raw values | `context.appTheme` extension |
| Adding a new tenant | New JSON file only, no code change |
