import 'package:flutter/material.dart';

/// Visual identity: deep Haram teal with warm sand and a touch of Kiswa gold.
class HajjColors {
  static const teal = Color(0xFF0D3B33);
  static const tealMid = Color(0xFF14594C);
  static const tealLight = Color(0xFF2E8C77);
  static const sand = Color(0xFFF6F1E6);
  static const gold = Color(0xFFC9A44C);
  static const goldDeep = Color(0xFF9C7A2A);
  static const ink = Color(0xFF17241F);
  static const night = Color(0xFF07130F);
  static const nightSurface = Color(0xFF0E201B);
  static const nightHigh = Color(0xFF15302A);
  static const nightInk = Color(0xFFE9EFEA);
  static const rukn = Color(0xFFB4452F);
  static const wajib = Color(0xFF1F6FB2);
  static const sunnah = Color(0xFF2E8C77);
}

class HajjTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: HajjColors.teal, brightness: Brightness.light).copyWith(
      primary: HajjColors.tealMid,
      onPrimary: Colors.white,
      secondary: HajjColors.gold,
      onSecondary: HajjColors.ink,
      surface: Colors.white,
      onSurface: HajjColors.ink,
      surfaceContainerHighest: const Color(0xFFE9E4D6),
      surfaceContainerHigh: const Color(0xFFEFEADD),
      surfaceContainer: const Color(0xFFF2EEE3),
      surfaceContainerLow: const Color(0xFFFBF9F4),
      outlineVariant: const Color(0xFFE0D9C7),
    );
    return _base(scheme, HajjColors.sand);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: HajjColors.teal, brightness: Brightness.dark).copyWith(
      primary: const Color(0xFF5CC7A8),
      onPrimary: const Color(0xFF00281F),
      secondary: HajjColors.gold,
      onSecondary: HajjColors.ink,
      surface: HajjColors.nightSurface,
      onSurface: HajjColors.nightInk,
      surfaceContainerHighest: const Color(0xFF1D3B33),
      surfaceContainerHigh: HajjColors.nightHigh,
      surfaceContainer: const Color(0xFF122722),
      surfaceContainerLow: const Color(0xFF0B1A16),
      outlineVariant: const Color(0xFF22413A),
    );
    return _base(scheme, HajjColors.night);
  }

  static ThemeData _base(ColorScheme scheme, Color bg) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true, fontFamily: 'Cairo');
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: .18),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w600, color: scheme.onSurface),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
