import 'package:flutter/material.dart';

class CycleaColors {
  static const rose = Color(0xFF8F4B5A);
  static const roseDeep = Color(0xFF6F3543);
  static const roseSoft = Color(0xFFE0A8B4);
  static const blush = Color(0xFFF6E1E4);
  static const petal = Color(0xFFE8B4BC);
  static const sage = Color(0xFF4F7A68);
  static const sageSoft = Color(0xFF8FA89C);
  static const sageMist = Color(0xFFD7E6DC);
  static const sand = Color(0xFFC9956A);
  static const honey = Color(0xFFE6C9A0);
  static const cream = Color(0xFFFBF4EE);
  static const creamDark = Color(0xFF171412);
  static const ink = Color(0xFF2C2426);
  static const muted = Color(0xFF6E5F62);
  static const lilac = Color(0xFF9A6B84);
}

class CycleaTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CycleaColors.rose,
      brightness: Brightness.light,
      primary: CycleaColors.rose,
      onPrimary: Colors.white,
      secondary: CycleaColors.sage,
      onSecondary: Colors.white,
      tertiary: CycleaColors.sand,
      surface: CycleaColors.cream,
      onSurface: CycleaColors.ink,
      primaryContainer: CycleaColors.blush,
      secondaryContainer: CycleaColors.sageMist,
      tertiaryContainer: const Color(0xFFF3E4D4),
    );
    return _theme(scheme, dark: false);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CycleaColors.rose,
      brightness: Brightness.dark,
      primary: CycleaColors.roseSoft,
      secondary: const Color(0xFFA8C4B6),
      tertiary: CycleaColors.honey,
      surface: CycleaColors.creamDark,
      primaryContainer: const Color(0xFF3A2A2E),
      secondaryContainer: const Color(0xFF24332C),
      tertiaryContainer: const Color(0xFF3A3228),
    );
    return _theme(scheme, dark: true);
  }

  static ThemeData _theme(ColorScheme scheme, {required bool dark}) {
    final textTheme = _textTheme(scheme);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xFF26211F) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.55)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF1F1A19) : Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: dark ? 0.24 : 0.14),
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: dark ? const Color(0xFF1F1A19) : Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        selectedColor: scheme.primary.withValues(alpha: 0.16),
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.7)),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF201C1B) : const Color(0xFFFFFBF8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    const headline = TextStyle(
      fontFamily: 'Fraunces',
      fontWeight: FontWeight.w600,
      height: 1.12,
      letterSpacing: -0.3,
    );
    const body = TextStyle(
      fontFamily: 'Figtree',
      fontWeight: FontWeight.w400,
      height: 1.45,
    );
    return TextTheme(
      displaySmall: headline.copyWith(fontSize: 38, color: scheme.onSurface),
      headlineLarge: headline.copyWith(fontSize: 32, color: scheme.onSurface),
      headlineMedium: headline.copyWith(fontSize: 26, color: scheme.onSurface),
      headlineSmall: headline.copyWith(fontSize: 21, color: scheme.onSurface),
      titleLarge: body.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface),
      titleMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface),
      titleSmall: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface),
      bodyLarge: body.copyWith(fontSize: 16, color: scheme.onSurface),
      bodyMedium: body.copyWith(fontSize: 14, color: scheme.onSurface),
      bodySmall: body.copyWith(fontSize: 12.5, color: scheme.onSurfaceVariant, height: 1.4),
      labelLarge: body.copyWith(fontSize: 14.5, fontWeight: FontWeight.w700, color: scheme.onSurface),
      labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface),
    );
  }
}

bool isWideLayout(BuildContext context) => MediaQuery.sizeOf(context).width >= 840;

double contentWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= 920 ? 840 : width;
}
