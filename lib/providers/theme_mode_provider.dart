import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preference_service.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // load theme from preferences
    final themeMode = await PreferenceService.getThemeMode();
    // update state with the loaded theme mode
    state = themeMode;
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    // update state
    state = themeMode;
    // save new theme mode to preferences
    await PreferenceService.setThemeMode(themeMode);
  }
}
