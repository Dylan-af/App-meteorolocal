
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Contiene la configuración del tema para la aplicación, incluyendo esquemas de color
/// y estilos de texto para los modos claro y oscuro.
class AppTheme {
  // Paleta de colores principal
  static final Color _primaryColor = Colors.red[700]!;
  static const Color _lightBackgroundColor = Colors.white;
  static const Color _darkBackgroundColor = Colors.black;
  static final Color _lightTextColor = Colors.black87;
  static const Color _darkTextColor = Colors.white;

  /// Define la tipografía de la aplicación usando Google Fonts para un aspecto moderno.
  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.oswald(fontSize: 48, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.w600),
    bodyMedium: GoogleFonts.roboto(fontSize: 16),
    labelLarge: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
  );

  /// Tema para el modo claro.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _lightBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.light,
        primary: _primaryColor,
        onPrimary: _darkTextColor,
        surface: _lightBackgroundColor,
        onSurface: _lightTextColor,
      ),
      textTheme: _textTheme.apply(
        bodyColor: _lightTextColor,
        displayColor: _lightTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        elevation: 0,
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: _darkTextColor),
        iconTheme: const IconThemeData(color: _darkTextColor),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black.withAlpha(25), // ~10% opacity
      ),
      iconTheme: IconThemeData(color: _primaryColor),
    );
  }

  /// Tema para el modo oscuro.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _primaryColor,
      scaffoldBackgroundColor: _darkBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        brightness: Brightness.dark,
        primary: _primaryColor,
        onPrimary: _darkTextColor,
        surface: _darkBackgroundColor,
        onSurface: _darkTextColor,
      ),
      textTheme: _textTheme.apply(
        bodyColor: _darkTextColor,
        displayColor: _darkTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBackgroundColor,
        elevation: 0,
        titleTextStyle: _textTheme.headlineMedium?.copyWith(color: _darkTextColor),
        iconTheme: const IconThemeData(color: _darkTextColor),
      ),
      cardTheme: CardThemeData(
        color: Colors.grey[900],
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: Colors.black.withAlpha(128), // ~50% opacity
      ),
      iconTheme: IconThemeData(color: _primaryColor),
    );
  }
}
