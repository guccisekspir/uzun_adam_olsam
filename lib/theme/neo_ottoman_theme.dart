import 'package:flutter/material.dart';

/// Neo-Ottoman theme class that provides colors, text styles, and decorations
/// for the Erdogan leadership decision game.
class NeoOttomanTheme {
  // Primary Colors
  static const Color deepRed = Color(0xFFC41E3A);
  static const Color royalBlue = Color(0xFF0F4C81);
  static const Color gold = Color(0xFFD4AF37);
  
  // Secondary Colors
  static const Color turquoise = Color(0xFF30D5C8);
  static const Color emeraldGreen = Color(0xFF50C878);
  static const Color ivory = Color(0xFFFFFFF0);
  
  // Accent Colors
  static const Color deepPurple = Color(0xFF4B0082);
  static const Color copper = Color(0xFFB87333);
  
  // Background gradients
  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepRed, Color(0xFF7D0A0A)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ivory, Color(0xFFF5F5DC)],
  );
  
  // Text styles
  static TextStyle get titleStyle => const TextStyle(
    fontFamily: 'Fondamento',
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: ivory,
    shadows: [
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color.fromRGBO(0, 0, 0, 0.5),
      ),
    ],
  );
  
  static TextStyle get subtitleStyle => const TextStyle(
    fontFamily: 'Fondamento',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: ivory,
  );
  
  static TextStyle get cardTitleStyle => const TextStyle(
    fontFamily: 'Fondamento',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: deepRed,
  );
  
  static TextStyle get cardTextStyle => const TextStyle(
    fontFamily: 'Fondamento',
    fontSize: 16,
    color: Colors.black87,
    height: 1.5,
  );
  
  static TextStyle get buttonTextStyle => const TextStyle(
    fontFamily: 'Fondamento',
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ivory,
  );
  
  // Button styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: deepRed,
    foregroundColor: ivory,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: gold, width: 2),
    ),
    elevation: 4,
    textStyle: const TextStyle(
      fontFamily: 'Fondamento',
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );
  
  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: royalBlue,
    foregroundColor: ivory,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: turquoise, width: 1.5),
    ),
    elevation: 3,
    textStyle: const TextStyle(
      fontFamily: 'Fondamento',
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
  
  // Card decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: ivory,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: gold, width: 2),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.3),
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
  );
  
  static BoxDecoration get ornateCardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: gold, width: 3),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.4),
        blurRadius: 12,
        offset: Offset(0, 6),
      ),
    ],
  );
  
  // Value indicator styles
  static BoxDecoration valueIndicatorDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.9),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: gold, width: 1.5),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.25),
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );
  
  // Background decorations for different eras
  static BoxDecoration backgroundDecoration(String era) {
    String patternAsset;
    Color overlayColor;
    
    switch (era) {
      case 'iktidara_yukselis':
        patternAsset = 'assets/images/ottoman_pattern_beige.jpeg';
        overlayColor = deepRed.withOpacity(0.7);
        break;
      case 'konsolidasyon':
        patternAsset = 'assets/images/ottoman_pattern_blue.jpeg';
        overlayColor = royalBlue.withOpacity(0.7);
        break;
      case 'kriz_ve_tepki':
        patternAsset = 'assets/images/ottoman_pattern_geometric.jpeg';
        overlayColor = deepPurple.withOpacity(0.7);
        break;
      case 'gec_donem':
        patternAsset = 'assets/images/ottoman_pattern_colorful.jpeg';
        overlayColor = emeraldGreen.withOpacity(0.7);
        break;
      default:
        patternAsset = 'assets/images/ottoman_pattern_beige.jpeg';
        overlayColor = deepRed.withOpacity(0.7);
    }
    
    return BoxDecoration(
      image: DecorationImage(
        image: AssetImage(patternAsset),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          overlayColor,
          BlendMode.overlay,
        ),
      ),
    );
  }
  
  // App bar theme
  static AppBarTheme get appBarTheme => const AppBarTheme(
    backgroundColor: deepRed,
    foregroundColor: ivory,
    centerTitle: true,
    elevation: 4,
    shadowColor: Colors.black54,
    titleTextStyle: TextStyle(
      fontFamily: 'Fondamento',
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: ivory,
    ),
  );
  
  // Theme data for the app
  static ThemeData get themeData => ThemeData(
    primaryColor: deepRed,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: 'Fondamento',
    appBarTheme: appBarTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: royalBlue,
        textStyle: const TextStyle(
          fontFamily: 'Fondamento',
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Fondamento'),
      displayMedium: TextStyle(fontFamily: 'Fondamento'),
      displaySmall: TextStyle(fontFamily: 'Fondamento'),
      headlineLarge: TextStyle(fontFamily: 'Fondamento'),
      headlineMedium: TextStyle(fontFamily: 'Fondamento'),
      headlineSmall: TextStyle(fontFamily: 'Fondamento'),
      titleLarge: TextStyle(fontFamily: 'Fondamento'),
      titleMedium: TextStyle(fontFamily: 'Fondamento'),
      titleSmall: TextStyle(fontFamily: 'Fondamento'),
      bodyLarge: TextStyle(fontFamily: 'Fondamento'),
      bodyMedium: TextStyle(fontFamily: 'Fondamento'),
      bodySmall: TextStyle(fontFamily: 'Fondamento'),
      labelLarge: TextStyle(fontFamily: 'Fondamento'),
      labelMedium: TextStyle(fontFamily: 'Fondamento'),
      labelSmall: TextStyle(fontFamily: 'Fondamento'),
    ),
    colorScheme: const ColorScheme.light(
      primary: deepRed,
      secondary: royalBlue,
      tertiary: gold,
      background: ivory,
    ),
    useMaterial3: true,
  );
}
