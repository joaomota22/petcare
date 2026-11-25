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
    secondary: p.primary,
    error: p.danger,
    surface: p.surface,
    onSurface: p.ink,
    onSurfaceVariant: p.muted,
    outline: p.border,
    outlineVariant: p.border,
  );

  final controlRadius = BorderRadius.circular(Radii.control);
  OutlineInputBorder line(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: controlRadius,
        borderSide: BorderSide(color: c, width: w),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.background,
    splashFactory: InkRipple.splashFactory,
    extensions: [p],
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.2,
        letterSpacing: -0.4,
        color: p.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: p.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: p.ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: p.ink),
      bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: p.muted),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: p.faint),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: p.ink,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: p.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: p.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      labelStyle: TextStyle(color: p.muted),
      floatingLabelStyle: TextStyle(color: p.primary),
      hintStyle: TextStyle(color: p.faint),
      prefixIconColor: p.faint,
      border: line(p.border),
      enabledBorder: line(p.border),
      focusedBorder: line(p.primary, 1.5),
      errorBorder: line(p.danger),
      focusedErrorBorder: line(p.danger, 1.5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.m,
        vertical: Space.m,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        disabledBackgroundColor: p.primary.withValues(alpha: 0.35),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: Space.l),
        shape: RoundedRectangleBorder(borderRadius: controlRadius),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.primary,
        shape: RoundedRectangleBorder(borderRadius: controlRadius),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      elevation: 2,
      highlightElevation: 2,
      extendedTextStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.card)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.sheet)),
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: p.ink),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: dark ? p.raised : p.ink,
      contentTextStyle: TextStyle(color: dark ? p.ink : p.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.control)),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: p.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Radii.s)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: p.primary),
    dividerColor: p.border,
  );
}
