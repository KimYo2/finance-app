import 'package:flutter/material.dart';

class AppTheme {
  static const primaryGreen = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFFE8F5E9);
  static const lightRed = Color(0xFFFFEBEE);
  static const cardBorder = Color(0xFFEEEEEE);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);

  static const darkBackground = Color(0xFF121212);
  static const darkCard = Color(0xFF1E1E1E);
  static const darkCardBorder = Color(0xFF2C2C2C);
  static const darkTextPrimary = Color(0xFFE0E0E0);
  static const darkTextSecondary = Color(0xFF9E9E9E);
  static const darkGreen = Color(0xFF66BB6A);
  static const darkRed = Color(0xFFEF5350);

  static const cardRadius = BorderRadius.all(Radius.circular(16));
  static const buttonRadius = BorderRadius.all(Radius.circular(16));
  static const pillRadius = BorderRadius.all(Radius.circular(50));

  static const pagePadding = EdgeInsets.all(16.0);
  static const cardPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

  static final cardShadow = BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCard : Colors.white;

  static Color cardBorderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardBorder : cardBorder;

  static Color incomeColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkGreen : primaryGreen;

  static Color expenseColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkRed : Colors.red;

  static Color textPrimaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : textPrimary;

  static Color textSecondaryColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : textSecondary;
}