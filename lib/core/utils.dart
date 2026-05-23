import 'package:flutter/material.dart';

class SourceColor {
  SourceColor._();

  // Predefined palette — ordered from dark to light
  // Works on both light and dark themes
  static const _palette = [
    Color(0xFF1A1A1A), // 1 — near black
    Color(0xFF2E4057), // 2 — dark navy
    Color(0xFF1D6A5A), // 3 — dark teal
    Color(0xFF5C3D2E), // 4 — dark brown
    Color(0xFF4A3F6B), // 5 — dark purple
    Color(0xFF5C4A1A), // 6 — dark amber
    Color(0xFF1A4A3A), // 7 — dark green
    Color(0xFF3D2E4A), // 8 — dark plum
    Color(0xFF2E3D4A), // 9 — dark slate
    Color(0xFF4A2E2E), // 10 — dark rose
  ];

  /// Returns a color for a given income type ID.
  /// IDs beyond palette length wrap around with slight variation.
  static Color fromId(int id) {
    final index = (id - 1) % _palette.length;
    return _palette[index];
  }

  /// Returns a light background tint of the color (for cards, badges)
  static Color bgFromId(int id) {
    return fromId(id).withValues(alpha: 0.08);
  }
}

class FieldsValidator {
  FieldsValidator();

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل كلمة المرور';
    }
    if (value.length < 8) {
      return 'كلمة المرور 8 أحرف على الأقل';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل البريد الإلكتروني';
    }
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل اسمك الكامل';
    }
    if (value.trim().length < 3) {
      return 'الاسم قصير جداً';
    }
    if (value.trim().length > 50) {
      return 'الاسم طويل جداً';
    }
    return null;
  }

  // Password
  static String? validateSignupPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'أدخل كلمة المرور';
    }
    if (value.length < 8) {
      return 'كلمة المرور 8 أحرف على الأقل';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'يجب أن تحتوي على رقم واحد على الأقل';
    }
    return null;
  }

  // Confirm password — needs access to password controller
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'أعد كتابة كلمة المرور';
    }
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }
}

/// Helper class for consistent color management across the app
class ColorHelper {
  /// Get stat color based on transaction direction
  /// Returns green for income, red for expenses, and onSurfaceVariant for neutral
  static Color getStatColor(ColorScheme scheme, {required bool? isIncome}) {
    if (isIncome == true) return scheme.primary; // Green for income
    if (isIncome == false) return scheme.error; // Red for expense
    return scheme.onSurfaceVariant;
  }

  /// Get direction text color (in/out indicator)
  static Color getDirectionColor(ColorScheme scheme, String direction) {
    return direction.toLowerCase() == 'in' ? scheme.primary : scheme.error;
  }
}

/// Lightweight responsive helpers without global mutable state.
///
/// Baseline is optimized for mobile design mockups:
/// - width: 360
/// - height: 800
extension ContextExt on BuildContext {
  static const double _baseWidth = 360;
  static const double _baseHeight = 800;

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Scale a design width value from a 360px baseline.
  double scaleW(double designWidth) => (designWidth / _baseWidth) * screenWidth;

  /// Scale a design height value from an 800px baseline.
  double scaleH(double designHeight) =>
      (designHeight / _baseHeight) * screenHeight;

  /// Scale a design font size value from a 360px baseline (responsive text).
  double scaleSp(double designFontSize) =>
      (designFontSize / _baseWidth) * screenWidth;

  /// Percentage helpers
  double wPct(double percent) => screenWidth * percent;
  double hPct(double percent) => screenHeight * percent;
}
