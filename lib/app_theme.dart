import 'package:flutter/material.dart';

// Paleta inspirada em UI moderna: índigo escuro (principal) sobre fundo lavanda.
const Color kPrimaryColor = Color(0xFF3D3A8C);
const Color kPrimaryDark = Color(0xFF2A2766);
const Color kPrimaryLight = Color(0xFF6F6BC4);
const Color kSecondaryColor = Color(0xFFFF7A8A); // coral (alertas e remoção)
const Color kTealColor = Color(0xFF2EC4B6); // sucesso / concluído
const Color kInkColor = Color(0xFF1B1A3A);
const Color kMutedColor = Color(0xFF8E90A8);
const Color kBackgroundColor = Color(0xFFEEF1FB);
const Color kBorderColor = Color(0xFFE4E7F3);
const Color kSurfaceTint = Color(0xFFE6E7F8); // fundo suave de ícones

const LinearGradient kBrandGradient = LinearGradient(
  colors: [Color(0xFF4A47A3), Color(0xFF2A2766)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// Sombra suave usada nos cartões e destaques.
const List<BoxShadow> kSoftShadow = [
  BoxShadow(color: Color(0x1A2A2766), blurRadius: 24, offset: Offset(0, 10)),
  BoxShadow(color: Color(0x0D2A2766), blurRadius: 4, offset: Offset(0, 2)),
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

  final fieldRadius = BorderRadius.circular(18);

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
      shadowColor: const Color(0x1A2A2766),
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
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
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: kSecondaryColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: const BorderSide(color: kSecondaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: kPrimaryColor.withValues(alpha: 0.35),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      extendedTextStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x1A2A2766),
      elevation: 8,
      height: 74,
      indicatorColor: kPrimaryColor,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
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
          color: selected ? Colors.white : kMutedColor,
          size: 24,
        );
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kPrimaryDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      return const Color(0xFF6F6BC4); // índigo claro
    case 'Pássaro':
      return const Color(0xFF2EC4B6); // teal
    case 'Coelho':
      return const Color(0xFFEC4899); // rosa
    default:
      return kMutedColor;
  }
}
