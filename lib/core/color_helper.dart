import 'package:flutter/material.dart';

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
