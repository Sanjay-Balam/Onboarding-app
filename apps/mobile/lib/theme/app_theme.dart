import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Fonts: DM Sans (display/headline), Hanken Grotesk (body), JetBrains Mono (labels).
class AppText {
  AppText._();

  static TextStyle displayLg = GoogleFonts.dmSans(
    fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w700, letterSpacing: -0.64,
    color: AppColors.primary,
  );
  static TextStyle headlineLg = GoogleFonts.dmSans(
    fontSize: 32, height: 40 / 32, fontWeight: FontWeight.w600, color: AppColors.primary,
  );
  static TextStyle headlineMd = GoogleFonts.dmSans(
    fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: AppColors.primary,
  );
  static TextStyle headlineSm = GoogleFonts.dmSans(
    fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: AppColors.primary,
  );
  static TextStyle bodyLg = GoogleFonts.hankenGrotesk(
    fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w400, color: AppColors.onSurface,
  );
  static TextStyle bodyMd = GoogleFonts.hankenGrotesk(
    fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: AppColors.onSurface,
  );
  static TextStyle labelSm = GoogleFonts.jetBrainsMono(
    fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, letterSpacing: 0.6,
    color: AppColors.onSurfaceVariant,
  );
}

class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.burntCaramel,
      onTertiary: AppColors.onPrimary,
      tertiaryContainer: AppColors.tertiaryFixed,
      onTertiaryContainer: AppColors.onTertiaryFixed,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: AppText.displayLg,
        headlineLarge: AppText.headlineLg,
        headlineMedium: AppText.headlineMd,
        headlineSmall: AppText.headlineSm,
        bodyLarge: AppText.bodyLg,
        bodyMedium: AppText.bodyMd,
        labelSmall: AppText.labelSm,
      ),
    );
  }
}
