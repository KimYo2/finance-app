import 'package:flutter/material.dart';

class AppTheme {
  static const primaryGreen = Color(0xFF4CAF50);
  static const lightGreen = Color(0xFFE8F5E9);
  static const lightRed = Color(0xFFFFEBEE);
  static const cardBorder = Color(0xFFEEEEEE);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF757575);

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
}