import 'package:assivoice/providers/seed_color_provider.dart';
import 'package:assivoice/providers/theme_mode_provider.dart';
import 'package:assivoice/providers/user_name_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// seed color provider
final seedColorProvider =
    StateNotifierProvider<SeedColorNotifier, Color>((ref) {
  return SeedColorNotifier();
});

// theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// user name provider
final userNameProvider = StateNotifierProvider<UserNameNotifier, String>((ref) {
  return UserNameNotifier();
});
