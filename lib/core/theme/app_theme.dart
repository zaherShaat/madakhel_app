import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.green,
      onPrimary: Colors.white,
      secondary: AppColors.greenLight,
      onSecondary: AppColors.greenText,
      error: AppColors.red,
      onError: Colors.white,
      background: AppColors.lightBackground,
      onBackground: AppColors.lightOnBackground,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      outline: AppColors.lightBorder,
      surfaceVariant: AppColors.lightSurface2,
      onSurfaceVariant: AppColors.lightOnSurface,
    );
    return _build(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.green,
      onPrimary: Colors.white,
      secondary: AppColors.greenLight,
      onSecondary: AppColors.greenText,
      error: AppColors.red,
      onError: Colors.white,
      background: AppColors.darkBackground,
      onBackground: AppColors.darkOnBackground,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      outline: AppColors.darkBorder,
      surfaceVariant: AppColors.darkSurface2,
      onSurfaceVariant: AppColors.darkOnSurface,
    );
    return _build(scheme);
  }

  static ThemeData _build(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Cairo',

      scaffoldBackgroundColor: scheme.background,

      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        foregroundColor: scheme.onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: scheme.onBackground,
        ),
      ),

      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outline),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Cairo',
          color: scheme.onSurface,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 10),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.onBackground,
          foregroundColor: scheme.background,
          elevation: 0,
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 0.5,
        space: 0,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: scheme.onBackground,
        iconColor: scheme.onSurface,
      ),
    );
  }
}