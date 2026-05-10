import 'package:flutter/widgets.dart';

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
