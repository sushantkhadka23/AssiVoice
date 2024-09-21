import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _themeKey = 'theme_mode';
  static const String _userNameKey = 'user_name';
  static const String _seedColorKey = 'seed_color';

  static SharedPreferences? _prefs;

  // Initialize the SharedPreferences instance
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Set theme mode asynchronously
  static Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs?.setInt(_themeKey, themeMode.index);
  }

  // Get theme mode asynchronously
  static Future<ThemeMode> getThemeMode() async {
    final themeModeIndex = _prefs?.getInt(_themeKey) ?? ThemeMode.system.index;
    return ThemeMode.values[themeModeIndex];
  }

  // Set username asynchronously and cache it
  static Future<void> setUserName(String name) async {
    await _prefs?.setString(_userNameKey, name);
  }

  // Get username asynchronously and cache it
  static Future<String> getUserName() async {
    final userName = _prefs?.getString(_userNameKey) ?? '';
    return userName;
  }

  // Check if the stored username is active asynchronously
  static Future<bool> isUserNameActive() async {
    final userName = _prefs?.getString(_userNameKey);
    return userName != null && userName.isNotEmpty;
  }

  // Synchronous check if the username is present
  static bool isUserNameActiveSync() {
    final userName = _prefs?.getString(_userNameKey);
    return userName != null && userName.isNotEmpty;
  }

  // Set seed color asynchronously
  static Future<void> setSeedColor(Color color) async {
    await _prefs?.setInt(_seedColorKey, color.value);
  }

  // Get seed color asynchronously
  static Future<Color> getSeedColor() async {
    final colorValue = _prefs?.getInt(_seedColorKey) ?? Colors.blue.value;
    return Color(colorValue);
  }

  // Clear all preferences
  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // Clear the stored username
  static Future<void> clearUserName() async {
    await _prefs?.remove(_userNameKey);
  }
}
