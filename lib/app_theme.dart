import 'package:flutter/material.dart';

import 'design/tokens.dart';

export 'design/tokens.dart';

/// Tema claro ou escuro, ambos construídos a partir dos mesmos tokens.
ThemeData buildAppTheme({required bool dark}) {
  final p = dark ? AppPalette.dark : AppPalette.light;
  final brightness = dark ? Brightness.dark : Brightness.light;

  final scheme = ColorScheme.fromSeed(
    seedColor: p.primary,
    brightness: brightness,
    primary: p.primary,
    onPrimary: p.onPrimary,
    secondary: p.accent,
    tertiary: p.success,
    surface: p.surface,
    onSurface: p.ink,
  );

  final fieldRadius = BorderRadius.circular(Radii.m);
  final buttonRadius = BorderRadius.circular(Radii.m);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    splashFactory: InkSparkle.splashFactory,
    extensions: [p],
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        height: 1.15,
        letterSpacing: -0.8,
        color: p.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.25,
        letterSpacing: -0.4,
        color: p.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: p.ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: p.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: p.muted),
      labelLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.muted),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.ink,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: p.ink,
        letterSpacing: -0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: p.shadow,
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.xl),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      labelStyle: TextStyle(color: p.muted),
      floatingLabelStyle: TextStyle(
        color: p.primary,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: p.muted,
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: p.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: p.accent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: p.accent, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.m,
        vertical: 18,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        disabledBackgroundColor: p.primary.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: Space.l),
        shape: RoundedRectangleBorder(borderRadius: buttonRadius),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: Space.l),
        shape: RoundedRectangleBorder(borderRadius: buttonRadius),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      elevation: 4,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.l)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.xxl)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? p.surface : p.ink,
      contentTextStyle: TextStyle(color: dark ? p.ink : Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.m)),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: p.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    dividerColor: p.border,
  );
}

/// Cor associada a cada espécie (usada nos avatares e etiquetas).
Color speciesColor(String species) {
  switch (species) {
    case 'Cão':
      return const Color(0xFFF59E0B); // âmbar
    case 'Gato':
      return const Color(0xFF8F8BF0); // índigo claro
    case 'Pássaro':
      return const Color(0xFF13A393); // teal
    case 'Coelho':
      return const Color(0xFFEC4899); // rosa
    default:
      return const Color(0xFF8E90A8);
  }
}
