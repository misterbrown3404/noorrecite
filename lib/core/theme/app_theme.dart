import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_shadows.dart';
export 'app_spacing.dart';
export 'app_typography.dart';

abstract final class AppTheme {
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
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceDim: AppColors.surfaceDim,
      surfaceBright: AppColors.surfaceBright,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
    );
    return _build(scheme);
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF64DD91),
      onPrimary: Color(0xFF00391C),
      primaryContainer: Color(0xFF00522B),
      onPrimaryContainer: Color(0xFF82FAAB),
      secondary: Color(0xFF4DDAC8),
      onSecondary: Color(0xFF003731),
      secondaryContainer: Color(0xFF00504A),
      onSecondaryContainer: Color(0xFF6FF7E4),
      tertiary: Color(0xFF9ECAFF),
      onTertiary: Color(0xFF003258),
      tertiaryContainer: Color(0xFF00497D),
      onTertiaryContainer: Color(0xFFD1E4FF),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      surface: Color(0xFF0E1512),
      onSurface: Color(0xFFDEE4DC),
      surfaceDim: Color(0xFF0E1512),
      surfaceBright: Color(0xFF343B37),
      surfaceContainerLowest: Color(0xFF090F0D),
      surfaceContainerLow: Color(0xFF161D1A),
      surfaceContainer: Color(0xFF1A211E),
      surfaceContainerHigh: Color(0xFF252C28),
      surfaceContainerHighest: Color(0xFF303733),
      onSurfaceVariant: Color(0xFFBEC9C2),
      outline: Color(0xFF88938D),
      outlineVariant: Color(0xFF3D4944),
      inverseSurface: Color(0xFFDEE4DC),
      onInverseSurface: Color(0xFF2B322E),
      inversePrimary: Color(0xFF006A39),
      surfaceTint: Color(0xFF64DD91),
    );
    return _build(scheme);
  }

  static ThemeData _build(ColorScheme scheme) => ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        textTheme: AppTypography.textTheme(),
        splashFactory: InkRipple.splashFactory,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          foregroundColor: scheme.onSurface,
        ),
        dividerTheme: DividerThemeData(
          color: scheme.outlineVariant,
          thickness: 1,
          space: AppSpacing.lg,
        ),
      );
}
