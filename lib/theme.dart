import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomColors {
  static const Color voidBlack = Color(0xFF0B0A09);
  static const Color obsidian = Color(0xFF141412);
  static const Color charcoal = Color(0xFF111110);
  static const Color slate = Color(0xFF1A1A18);
  static const Color border = Color(0xFF1E1C1A);
  static const Color gold = Color(0xFFC4A96B);
  static const Color goldLight = Color(0xFFD2BC82);
  static const Color goldPale = Color(0xFFE7D8B6);
  static const Color goldMuted = Color(0xFF8A7248);
  static const Color offWhite = Color(0xFFDEDAD4);
  static const Color muted = Color(0xFF5A5550);
  static const Color error = Color(0xFF8C4040);
  static const Color success = Color(0xFF6F866C);
}

class RoomTheme {
  static ThemeData get theme {
    final cormorant = GoogleFonts.cormorantGaramondTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: RoomColors.voidBlack,
      fontFamily: GoogleFonts.cormorantGaramond().fontFamily,
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
          fontStyle: FontStyle.italic,
          color: RoomColors.gold,
          letterSpacing: 7.6,
          height: 1.0,
        ),
        displayMedium: cormorant.displayMedium?.copyWith(
          fontSize: 44,
          fontWeight: FontWeight.w300,
          fontStyle: FontStyle.italic,
          color: RoomColors.offWhite,
          letterSpacing: 1.0,
          height: 1.08,
        ),
        headlineMedium: cormorant.headlineMedium?.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w400,
          color: RoomColors.offWhite,
          letterSpacing: 0.5,
          height: 1.35,
        ),
        titleMedium: cormorant.titleMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: RoomColors.goldMuted,
          letterSpacing: 1.95,
          height: 1.4,
        ),
        bodyLarge: cormorant.bodyLarge?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: RoomColors.offWhite,
          height: 1.65,
        ),
        bodyMedium: cormorant.bodyMedium?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: RoomColors.goldMuted,
          height: 1.55,
        ),
        labelLarge: cormorant.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: RoomColors.gold,
          letterSpacing: 1.8,
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
          fontSize: 11,
          letterSpacing: 1.8,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(
          color: RoomColors.muted,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}
