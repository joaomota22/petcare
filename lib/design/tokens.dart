import 'package:flutter/material.dart';

/// Escala de espaçamento (múltiplos de 4).
class Space {
  Space._();
  static const double xxs = 4;
  static const double xs = 8;
  static const double s = 12;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
}

/// Raios de canto refinados.
class Radii {
  Radii._();
  static const double s = 12;
  static const double m = 16;
  static const double l = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Tokens de cor. Três cores principais (primária, secundária/accent e sucesso)
/// mais neutros, com variantes para modo claro e escuro.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.accent,
    required this.success,
    required this.ink,
    required this.muted,
    required this.background,
    required this.surface,
    required this.border,
    required this.shadow,
    required this.gradient,
  });

  /// Cor principal (ações, seleção, destaque).
  final Color primary;
  /// Texto/ícones sobre a cor principal.
  final Color onPrimary;
  /// Fundo suave da cor principal (caixas de ícone, etiquetas).
  final Color primarySoft;
  /// Cor secundária (alertas, remoção).
  final Color accent;
  /// Cor de sucesso (concluído, progresso).
  final Color success;
  /// Texto principal.
  final Color ink;
  /// Texto secundário (com contraste ≥ 4.5:1 sobre o fundo).
  final Color muted;
  /// Fundo do ecrã.
  final Color background;
  /// Superfície de cartões.
  final Color surface;
  /// Contornos subtis.
  final Color border;
  /// Sombra difusa (nunca preta chapada).
  final Color shadow;
  /// Gradiente de cartões de destaque.
  final List<Color> gradient;

  LinearGradient get brandGradient => LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  List<BoxShadow> get softShadow => [
        BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 10)),
        BoxShadow(
          color: shadow.withValues(alpha: shadow.a * 0.5),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static const light = AppPalette(
    primary: Color(0xFF3D3A8C),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE6E7F8),
    accent: Color(0xFFE5566B),
    success: Color(0xFF13A393),
    ink: Color(0xFF1B1A3A),
    muted: Color(0xFF5F6283),
    background: Color(0xFFEEF1FB),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE4E7F3),
    shadow: Color(0x1F2A2766),
    gradient: [Color(0xFF4A47A3), Color(0xFF2A2766)],
  );

  static const dark = AppPalette(
    primary: Color(0xFF8F8BF0),
    onPrimary: Color(0xFF12112A),
    primarySoft: Color(0xFF2A2950),
    accent: Color(0xFFFF8A99),
    success: Color(0xFF3DD6C7),
    ink: Color(0xFFF2F2FA),
    muted: Color(0xFFA7AAC6),
    background: Color(0xFF0E0D1E),
    surface: Color(0xFF191830),
    border: Color(0xFF2A2945),
    shadow: Color(0x66000000),
    gradient: [Color(0xFF3B38A0), Color(0xFF1F1D4F)],
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primarySoft,
    Color? accent,
    Color? success,
    Color? ink,
    Color? muted,
    Color? background,
    Color? surface,
    Color? border,
    Color? shadow,
    List<Color>? gradient,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      gradient: gradient ?? this.gradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      gradient: t < 0.5 ? gradient : other.gradient,
    );
  }
}

/// Acesso rápido aos tokens: `context.palette.ink`.
extension PaletteContext on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}

/// Duração e curva padrão para micro-interações.
class Motion {
  Motion._();
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 280);
  static const Curve curve = Curves.easeOutCubic;
}
