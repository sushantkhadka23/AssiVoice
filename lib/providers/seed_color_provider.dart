import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preference_service.dart';

class SeedColorNotifier extends StateNotifier<Color> {
  SeedColorNotifier() : super(Colors.blue) {
    _loadSeedColor();
  }

  // load seed color from preferences
  Future<void> _loadSeedColor() async {
    final color = await PreferenceService.getSeedColor();
    state = color;
  }

  // update seed color in preferences
  Future<void> updateSeedColor(Color color) async {
    state = color;
    await PreferenceService.setSeedColor(color);
  }
}
