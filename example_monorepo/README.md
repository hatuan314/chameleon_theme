# Chameleon Theme - Monorepo Demo

This repository demonstrates how to manage a multi-module Flutter application using [Melos](https://melos.invertase.dev) and how the `chameleon_theme` engine propagates real-time theme changes across multiple independent packages.

## Directory Structure

```
example_monorepo/
├── melos.yaml                  # Melos monorepo configuration
├── pubspec.yaml                # Root pubspec declaring melos
└── packages/
    ├── apps/
    │   └── main_app/           # The runner Flutter app integrating all modules
    └── features/
        ├── module_a/           # Independent Feature A containing theme controllers
        └── module_b/           # Independent Feature B showing reactive elements
```

## How It Works

This demo contains two feature modules and a main runner application:
1. **`chameleon_theme` (Library Core):** Located at the root of the workspace. It manages the theme state, loading configurations, and emitting changes via `ThemeService` (extends `ChangeNotifier`).
2. **`module_a` (Feature Module A):** An independent package that contains UI widgets consuming the theme. It exposes buttons to switch user segments (e.g., to `VIP` or `STANDARD`) directly modifying the shared `ThemeService`.
3. **`module_b` (Feature Module B):** An independent package that only reads and reacts to theme changes. It does not have any control logic. It renders content and customized UI elements dynamically based on `context.appTheme`.
4. **`main_app` (Main Application):** Integrates both `module_a` and `module_b` into a single screen. It instantiates the `ThemeService` and wraps the `MaterialApp` in a `ListenableBuilder`.

---

## Technical Analysis: Does theme-switching update the entire App?

**Yes, absolutely.** When you change the theme in one module (e.g., clicking a button in `module_a`), the entire application, including `module_b`, updates instantly. 

### Why and How does it propagate?

1. **Shared State Singleton/DI:** 
   The `ThemeService` instance is created at the entry point of the main application (`main_app/lib/main.dart`) and is shared across modules. In this example, it is passed down through constructors. In production, this can be managed by Dependency Injection (like `get_it`) or InheritedWidgets.
   
2. **Flutter's Reactive Tree & InheritedWidgets:**
   The `MaterialApp` in `main_app` is wrapped inside a `ListenableBuilder` listening to the `ThemeService`.
   ```dart
   ListenableBuilder(
     listenable: themeService,
     builder: (context, child) {
       final activeTheme = themeService.current;
       return MaterialApp(
         theme: ThemeData(
           extensions: [activeTheme], // AppTheme injected here
         ),
         home: HomePage(themeService: themeService),
       );
     },
   )
   ```
   When `themeService.applyForUser(...)` is called inside `module_a`, it updates `ThemeService._current` and triggers `notifyListeners()`.
   
3. **Rebuild Propagation:**
   `ListenableBuilder` catches the notification and rebuilds the `MaterialApp` with the new `ThemeData` containing the updated `AppTheme` extension. Because `ThemeData` has changed, Flutter's `Theme` (which uses `InheritedTheme` internally) notifies all descending elements in the widget tree that depend on it.

4. **Dynamic Leaf Updates:**
   Even though `module_b` is an isolated package and knows nothing about the button clicks in `module_a`, its widgets use `context.appTheme` (from the shared `chameleon_theme` package extension). Since `context.appTheme` internally calls `Theme.of(context)`, Flutter marks the widgets in `module_b` as dirty and rebuilds them on the next frame with the new styles.

---

## Setup & Run Instructions

Since this project uses FVM (Flutter Version Manager) to run a specific SDK version, make sure you use the local FVM Flutter binaries.

### 1. Bootstrap the Monorepo
From the `example_monorepo` folder, run Melos bootstrap using the local SDK's `dart`:
```bash
# Set PATH to FVM SDK and run bootstrap
PATH="$PWD/../.fvm/flutter_sdk/bin:$PATH" ../.fvm/flutter_sdk/bin/dart run melos bootstrap
```
This command resolves all dependencies, automatically symlinks local packages (including the parent `chameleon_theme`), and generates proper configuration files.

### 2. Static Analysis Verification
To verify code correctness across the workspace, you can run:
```bash
# Analyze a specific module, e.g., main_app:
cd packages/apps/main_app
../../../../.fvm/flutter_sdk/bin/flutter analyze --no-pub
```

### 3. Run the App
To run the main application:
```bash
cd packages/apps/main_app
../../../../.fvm/flutter_sdk/bin/flutter run
```
Once launched, you will see a screen showcasing both **Feature A** and **Feature B**. Clicking "VIP Theme" or "Standard" in Feature A will instantly change the appearance, fonts, radii, and banners in both Feature A and Feature B simultaneously.
