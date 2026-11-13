import 'package:flutter/material.dart';

// Paleta: índigo (principal), coral (destaque), teal (sucesso) sobre fundo frio.
const Color kPrimaryColor = Color(0xFF4F46E5);
const Color kPrimaryLight = Color(0xFF8B85F7);
const Color kSecondaryColor = Color(0xFFFB7185); // coral (destaque)
const Color kTealColor = Color(0xFF14B8A6); // sucesso / concluído
const Color kInkColor = Color(0xFF0F172A);
const Color kMutedColor = Color(0xFF64748B);
const Color kBackgroundColor = Color(0xFFF3F5FB);
const Color kBorderColor = Color(0xFFE2E8F0);

const LinearGradient kBrandGradient = LinearGradient(
  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED), Color(0xFFA855F7)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Sombra suave usada nos cartões e destaques.
const List<BoxShadow> kSoftShadow = [
  BoxShadow(color: Color(0x140F172A), blurRadius: 18, offset: Offset(0, 6)),
  BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
];

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kPrimaryColor,
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    tertiary: kTealColor,
    surface: Colors.white,
    onSurface: kInkColor,
  );

  final fieldRadius = BorderRadius.circular(14);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBackgroundColor,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: kInkColor,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: kInkColor,
        letterSpacing: -0.4,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x140F172A),
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: kMutedColor),
      floatingLabelStyle: const TextStyle(
        color: kPrimaryColor,
        fontWeight: FontWeight.w600,
      ),
      prefixIconColor: kMutedColor,
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: kBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: kBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: kPrimaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: Color(0xFFF43F5E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: Color(0xFFF43F5E), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kPrimaryColor.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 3,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x140F172A),
      elevation: 8,
      height: 72,
      indicatorColor: kPrimaryColor.withValues(alpha: 0.12),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? kPrimaryColor : kMutedColor,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? kPrimaryColor : kMutedColor,
          size: 24,
        );
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kInkColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    chipTheme: ChipThemeData(
      side: const BorderSide(color: kBorderColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
  );
}

/// Cor associada a cada espécie (usada nos avatares e etiquetas).
Color speciesColor(String species) {
  switch (species) {
    case 'Cão':
      return const Color(0xFFF59E0B); // âmbar
    case 'Gato':
      return const Color(0xFF6366F1); // índigo
    case 'Pássaro':
      return const Color(0xFF14B8A6); // teal
    case 'Coelho':
      return const Color(0xFFEC4899); // rosa
    default:
      return kMutedColor;
  }
}
