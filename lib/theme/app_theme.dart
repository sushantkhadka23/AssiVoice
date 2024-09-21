import 'package:flutter/material.dart';

class AppTheme {
  // available colors for seed color
  static List<Color> availableColors = const [
    Color(0xFF007BA7), // Cerulean Blue
    Color(0xFF3EB489), // Mint Green
    Color(0xFFFF6F61), // Coral
    Color(0xFF708090), // Slate Gray
    Color(0xFF8F00FF), // Electric Violet
    Color(0xFFFF4500), // Sunset Orange
    Color(0xFF30D5C8), // Turquoise
    Color(0xFFDAA520), // Goldenrod
    Color(0xFFC85A5A), // Deep Rose
    Color(0xFF0077BE), // Ocean Blue
    Color(0xFF93C572), // Pistachio
    Color(0xFF967BB6), // Lavender Purple
    Color(0xFFDC143C), // Crimson Red
    Color(0xFF4682B4), // Steel Blue
  ];

  // light theme
  static ThemeData lightTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Lato',
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
    );
  }

  // dark theme
  static ThemeData darkTheme(Color seedColor) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Lato',
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
    );
  }
}
