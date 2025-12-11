import 'package:flutter/material.dart';

class TemaAplikasi {
  // --- WARNA UTAMA ---
  static const Color _primaryColor = Colors.teal;
  static const Color _secondaryColor = Colors.green;

  // --- TEMA TERANG (LIGHT MODE) ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Skema Warna
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _secondaryColor,
    ),

    // Latar Belakang
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),

    // Pengaturan AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
    ),

    // UPDATE: Ganti CardTheme jadi CardThemeData
    cardTheme: CardThemeData( // <--- PERUBAHAN DI SINI
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    ),

    // Pengaturan Tombol Floating
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),
    
    // Pengaturan Tombol Biasa
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );

  // --- TEMA GELAP (DARK MODE) ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Skema Warna Gelap
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
      primary: _primaryColor,
      surface: const Color(0xFF1E1E1E), 
    ),

    // Latar Belakang Gelap
    scaffoldBackgroundColor: const Color(0xFF121212), 

    // Pengaturan AppBar Gelap
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.tealAccent,
      centerTitle: true,
      elevation: 0,
    ),

    // UPDATE: Ganti CardTheme jadi CardThemeData
    cardTheme: CardThemeData( // <--- PERUBAHAN DI SINI
      color: const Color(0xFF1E1E1E), 
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    ),

    // Pengaturan Tombol Floating Gelap
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.white,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}