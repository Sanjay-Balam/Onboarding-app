import 'package:flutter/material.dart';

/// "Why So Creamy" design tokens (from Stitch design system).
class AppColors {
  AppColors._();

  static const primary = Color(0xFF321716);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF4A2C2A);
  static const onPrimaryContainer = Color(0xFFBD928F);
  static const primaryFixed = Color(0xFFFFDAD7);
  static const primaryFixedDim = Color(0xFFEABCB8);

  static const secondary = Color(0xFF7D562D);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFFFCA98);
  static const onSecondaryContainer = Color(0xFF7A532A);
  static const secondaryFixed = Color(0xFFFFDCBD);
  static const secondaryFixedDim = Color(0xFFF0BD8B);

  static const tertiaryFixed = Color(0xFFF2DFD0);
  static const onTertiaryFixed = Color(0xFF231A11);
  static const onTertiaryFixedVariant = Color(0xFF51453A);
  static const tertiaryFixedDim = Color(0xFFD5C3B5);
  static const onTertiaryContainer = Color(0xFFAA9A8C);

  static const background = Color(0xFFFBF9F5);
  static const surface = Color(0xFFFBF9F5);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF5F3EF);
  static const surfaceContainer = Color(0xFFEFEEEA);
  static const surfaceContainerHigh = Color(0xFFEAE8E4);
  static const surfaceContainerHighest = Color(0xFFE4E2DE);
  static const surfaceVariant = Color(0xFFE4E2DE);
  static const surfaceDim = Color(0xFFDBDAD6);
  static const surfaceBright = Color(0xFFFBF9F5);

  static const onSurface = Color(0xFF1B1C1A);
  static const onSurfaceVariant = Color(0xFF504443);
  static const outline = Color(0xFF827472);
  static const outlineVariant = Color(0xFFD4C3C1);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // Named brand accents
  static const burntCaramel = Color(0xFFBC6C25);
  static const clottedCream = Color(0xFFF9F3E8);
  static const darkGanache = Color(0xFF2B1716);
  static const whey = Color(0xFFE5E0D8); // whey-gray, subtle card borders

  static const success = Color(0xFF2E7D32); // green-700-ish for positive deltas

  /// Soft ambient card shadow used across the design.
  static const cardShadow = [
    BoxShadow(color: Color(0x0A0F172A), blurRadius: 20, offset: Offset(0, 4)),
  ];
}
