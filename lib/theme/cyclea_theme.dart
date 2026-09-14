import 'package:flutter/material.dart';

class CycleaColors {
  static const rose = Color(0xFF9A5B6A);
  static const roseDeep = Color(0xFF7A4452);
  static const sage = Color(0xFF5F7F72);
  static const sageSoft = Color(0xFF8FA89C);
  static const sand = Color(0xFFC9A27A);
  static const cream = Color(0xFFF7F1ED);
  static const creamDark = Color(0xFF1C1918);
  static const ink = Color(0xFF2F2A2B);
  static const muted = Color(0xFF6F6567);
}

class CycleaTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CycleaColors.rose,
      brightness: Brightness.light,
      primary: CycleaColors.rose,
      secondary: CycleaColors.sage,
      tertiary: CycleaColors.sand,
      surface: CycleaColors.cream,
    );
    return _theme(scheme, dark: false);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: CycleaColors.rose,
      brightness: Brightness.dark,
      primary: const Color(0xFFE0A8B4),
      secondary: const Color(0xFFA8C4B6),
      tertiary: const Color(0xFFE0C4A0),
      surface: CycleaColors.creamDark,
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
        color: dark ? const Color(0xFF262220) : Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? const Color(0xFF221E1D) : Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        selectedColor: scheme.primary.withValues(alpha: 0.16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    const headline = TextStyle(
      fontFamily: 'serif',
      fontWeight: FontWeight.w600,
      color: CycleaColors.ink,
      height: 1.15,
    );
    const body = TextStyle(
      fontFamily: 'sans-serif',
      fontWeight: FontWeight.w400,
      height: 1.4,
    );
    return TextTheme(
      displaySmall: headline.copyWith(fontSize: 36, color: scheme.onSurface),
      headlineLarge: headline.copyWith(fontSize: 30, color: scheme.onSurface),
      headlineMedium: headline.copyWith(fontSize: 24, color: scheme.onSurface),
      headlineSmall: headline.copyWith(fontSize: 20, color: scheme.onSurface),
      titleLarge: body.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: scheme.onSurface),
      titleMedium: body.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: scheme.onSurface),
      titleSmall: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurface),
      bodyLarge: body.copyWith(fontSize: 16, color: scheme.onSurface),
      bodyMedium: body.copyWith(fontSize: 14, color: scheme.onSurface),
      bodySmall: body.copyWith(fontSize: 12, color: scheme.onSurfaceVariant),
      labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.onSurface),
      labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface),
    );
  }
}

bool isWideLayout(BuildContext context) => MediaQuery.sizeOf(context).width >= 840;

double contentWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= 920 ? 840 : width;
}
