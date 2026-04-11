import 'package:flutter/material.dart';

class AppTheme {
  // Pastel Color Palette
  static const Color background = Color(0xFFFFF7F0);
  
  // Vibrant 3D Button Colors
  static const Color primary = Color(0xFFFFD166);
  static const Color primaryDark = Color(0xFFE5BC5C);
  
  static const Color secondary = Color(0xFF6EC6FF);
  static const Color secondaryDark = Color(0xFF5AB3E5);
  
  static const Color accent = Color(0xFFEF476F);
  static const Color accentDark = Color(0xFFD63D62);

  static const Color success = Color(0xFF06D6A0);
  static const Color successDark = Color(0xFF05C08F);
  
  static const Color coinGold = Color(0xFFFFC107);
  static const Color coinDark = Color(0xFFF57F17);
  
  static const Color textDark = Color(0xFF2D3142);
  static const Color textLight = Color(0xFF9094A6);
  static const Color white = Colors.white;

  // Mood Colors
  static const Color moodHappy = Color(0xFFFFD166);
  static const Color moodAngry = Color(0xFFEF476F);
  static const Color moodSleepy = Color(0xFF6EC6FF);

  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      fontFamily: 'Nunito', 
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textDark),
        centerTitle: true,
        titleTextStyle: TextStyle(color: textDark, fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Common UI Styles for Game Feel
  static BoxDecoration gameBoxDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 10, offset: Offset(0, 8)),
    ],
  );
}
