import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_theme.dart';
import '../domain/tenant_theme_registry.dart';
import '../domain/user_context.dart';

/// Runtime ChangeNotifier orchestrator that holds the active AppTheme
/// and notifies UI listeners when the theme variant is switched.
class ThemeService extends ChangeNotifier {
  TenantThemeRegistry? _registry;
  AppTheme _current;
  SharedPreferences? _prefs;
  UserContext? _pendingUser;

  ThemeService(AppTheme initial, {TenantThemeRegistry? registry})
      : _current = initial,
        _registry = registry {
    _initPrefs();
  }

  /// Retrieves the active semantic theme.
  AppTheme get current => _current;

  /// Retrieves the active tenant registry.
  TenantThemeRegistry? get registry => _registry;

  /// Sets the registry and resolves any pending buffered user themes.
  set registry(TenantThemeRegistry? value) {
    _registry = value;
    if (value != null) {
      // If SharedPreferences is already initialized, try to restore saved variant
      if (_prefs != null) {
        _restoreSavedVariant(value);
      }
      // Apply any pending user requests
      final pending = _pendingUser;
      if (pending != null) {
        _pendingUser = null;
        applyForUser(pending);
      }
    }
  }

  /// Resolves the theme variant for [user] and triggers an instant UI rebuild.
  /// Buffers requests silently if the registry is not yet ready (FR-buffer).
  void applyForUser(UserContext user) {
    final reg = _registry;
    if (reg == null) {
      _pendingUser = user;
      return;
    }

    final tokens = reg.resolve(user);
    _current = AppTheme.fromTokens(tokens, tokens.semanticMap);

    final variantKey = reg.rules.variantFor(user.segment);
    _prefs?.setString('theme_variant', variantKey);

    notifyListeners();
  }

  /// Applies a custom theme directly and notifies all listeners to trigger UI updates.
  void applyCustomTheme(AppTheme customTheme) {
    _current = customTheme;
    notifyListeners();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final reg = _registry;
      if (reg != null) {
        _restoreSavedVariant(reg);
      }

      final pending = _pendingUser;
      if (pending != null) {
        _pendingUser = null;
        applyForUser(pending);
      }
    } catch (e) {
      dev.log('Failed to initialize SharedPreferences: $e', name: 'theme_engine');
    }
  }

  void _restoreSavedVariant(TenantThemeRegistry reg) {
    final savedVariant = _prefs?.getString('theme_variant');
    if (savedVariant != null) {
      final tokens = reg.variants[savedVariant] ?? reg.variants[reg.rules.defaultVariant];
      if (tokens != null) {
        _current = AppTheme.fromTokens(tokens, tokens.semanticMap);
        notifyListeners();
      }
    }
  }
}
