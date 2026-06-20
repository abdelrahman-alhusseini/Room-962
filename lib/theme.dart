import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomColors {
  static const Color voidBlack = Color(0xFF050607);
  static const Color obsidian = Color(0xFF0B0D10);
  static const Color charcoal = Color(0xFF12161B);
  static const Color slate = Color(0xFF1A2028);
  static const Color border = Color(0xFF29313B);
  static const Color gold = Color(0xFFCDBB9A);
  static const Color goldLight = Color(0xFFE1D1B0);
  static const Color goldPale = Color(0xFFF0E8D9);
  static const Color goldMuted = Color(0xFF9E8F78);
  static const Color offWhite = Color(0xFFECE7DD);
  static const Color muted = Color(0xFF7E858D);
  static const Color error = Color(0xFFC0392B);
  static const Color success = Color(0xFF6B8F7B);
}

class RoomTheme {
  static ThemeData get theme {
    final cormorant = GoogleFonts.cormorantGaramondTextTheme();
    final inter = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RoomColors.voidBlack,
      colorScheme: const ColorScheme.dark(
        primary: RoomColors.gold,
        secondary: RoomColors.goldLight,
        surface: RoomColors.obsidian,
        error: RoomColors.error,
      ),
      textTheme: TextTheme(
        displayLarge: cormorant.displayLarge?.copyWith(
          fontSize: 76,
          fontWeight: FontWeight.w300,
          color: RoomColors.gold,
          letterSpacing: 7.6,
          height: 1.0,
        ),
        displayMedium: cormorant.displayMedium?.copyWith(
          fontSize: 44,
          fontWeight: FontWeight.w400,
          color: RoomColors.offWhite,
          letterSpacing: 2.0,
          height: 1.08,
        ),
        headlineMedium: cormorant.headlineMedium?.copyWith(
          fontSize: 25,
          fontWeight: FontWeight.w400,
          color: RoomColors.offWhite,
          letterSpacing: 0.8,
          height: 1.35,
        ),
        titleMedium: inter.titleMedium?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: RoomColors.goldMuted,
          letterSpacing: 1.4,
          height: 1.4,
        ),
        bodyLarge: inter.bodyLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: RoomColors.offWhite,
          height: 1.75,
        ),
        bodyMedium: inter.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: RoomColors.goldMuted,
          height: 1.6,
        ),
        labelLarge: inter.labelLarge?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: RoomColors.gold,
          letterSpacing: 1.4,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: false,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: RoomColors.goldMuted, width: 1),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: RoomColors.goldMuted, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: RoomColors.gold, width: 1.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: RoomColors.error, width: 1),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: RoomColors.error, width: 1.5),
        ),
        labelStyle: TextStyle(
          color: RoomColors.goldMuted,
          fontSize: 10,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: RoomColors.muted,
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
