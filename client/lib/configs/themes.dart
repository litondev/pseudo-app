import 'package:flutter/material.dart';

class AppThemes {
  // Custom colors
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color infoColor = Color(0xFF2196F3); // Blue

  // Light theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 1,
      centerTitle: true,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color.fromARGB(255, 4, 63, 94),
    ),
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ).copyWith(
      error: errorColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    dividerColor: Colors.grey[300],
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        color: Colors.black54,
      ),
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 1,
      centerTitle: true,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    cardColor: const Color(0xFF2C2C2C),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      error: errorColor,
      surface: const Color(0xFF1E1E1E),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFF2C2C2C),
    ),
    dividerColor: Colors.grey[700],
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        color: Colors.white70,
      ),
    ),
  );

  // Custom theme colors extension
  static ThemeData getThemeWithCustomColors(ThemeData baseTheme) {
    return baseTheme.copyWith(
      extensions: [
        CustomColors(
          success: successColor,
          error: errorColor,
          warning: warningColor,
          info: infoColor,
        ),
      ],
    );
  }

  // Get light theme with custom colors
  static ThemeData get lightThemeWithCustomColors {
    return getThemeWithCustomColors(lightTheme);
  }

  // Get dark theme with custom colors
  static ThemeData get darkThemeWithCustomColors {
    return getThemeWithCustomColors(darkTheme);
  }
}

// Custom colors extension
class CustomColors extends ThemeExtension<CustomColors> {
  final Color success;
  final Color error;
  final Color warning;
  final Color info;

  const CustomColors({
    required this.success,
    required this.error,
    required this.warning,
    required this.info,
  });

  @override
  CustomColors copyWith({
    Color? success,
    Color? error,
    Color? warning,
    Color? info,
  }) {
    return CustomColors(
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t) ?? success,
      error: Color.lerp(error, other.error, t) ?? error,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
    );
  }

  // Helper method to get custom colors from context
  static CustomColors of(BuildContext context) {
    return Theme.of(context).extension<CustomColors>() ??
        const CustomColors(
          success: AppThemes.successColor,
          error: AppThemes.errorColor,
          warning: AppThemes.warningColor,
          info: AppThemes.infoColor,
        );
  }
}

// Theme mode helper
class ThemeHelper {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static bool isLightMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light;
  }

  static Color getContrastColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  static Color getSuccessColor(BuildContext context) {
    return CustomColors.of(context).success;
  }

  static Color getErrorColor(BuildContext context) {
    return CustomColors.of(context).error;
  }

  static Color getWarningColor(BuildContext context) {
    return CustomColors.of(context).warning;
  }

  static Color getInfoColor(BuildContext context) {
    return CustomColors.of(context).info;
  }
}