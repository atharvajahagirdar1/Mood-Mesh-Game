import 'package:flutter/material.dart';

class AppTheme {
  // Minimalist, Clean Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundDark = Color(0xFFF0F4F8);  // Very subtle cool grey
  
  // 3D Button Colors - High Contrast
  static const Color primary = Color(0xFFFFB703); // Warm Gold
  static const Color primaryDark = Color(0xFFE89D00); 
  
  static const Color secondary = Color(0xFF4EA8DE); // Bright Cyan
  static const Color secondaryDark = Color(0xFF0077B6);
  
  static const Color accent = Color(0xFFFF595E); // Punchy Red
  static const Color accentDark = Color(0xFFD62828);

  static const Color success = Color(0xFF06D6A0); // Vivid Green
  static const Color successDark = Color(0xFF05B083);
  
  static const Color coinGold = Color(0xFFFFC107);
  static const Color coinDark = Color(0xFFF77F00);

  // Hint Glow Colors
  static const Color neonBlue = Color(0xFF00E5FF);
  
  static const Color textDark = Color(0xFF1D2D44); // Deep Navy Blue for extreme readability
  static const Color textLight = Color(0xFF748A9D);
  static const Color white = Colors.white;

  // Vibrant Mood Colors (For the Dots)
  static const Color moodHappy = Color(0xFFFFEA00); // Lemon Yellow
  static const Color moodAngry = Color(0xFFFF3D00); // Neon Red
  static const Color moodSleepy = Color(0xFF00E5FF); // Cyan Blue

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundLight,
      primaryColor: primary,
      fontFamily: 'Nunito', 
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        centerTitle: true,
        titleTextStyle: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.w900),
      ),
    );
  }

  static BoxDecoration gameBoxDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, 8)), // Softer, modern shadow
    ],
    border: Border.all(color: const Color(0xFFE5E9F0), width: 2), // Clean outline
  );
}
