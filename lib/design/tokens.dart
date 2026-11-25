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

/// Raios de canto: controlos 10, cartões 14, folhas e diálogos 20.
class Radii {
  Radii._();
  static const double s = 8;
  static const double control = 10;
  static const double card = 14;
  static const double sheet = 20;
}

/// Algarismos de largura fixa para pesos, horas e contagens.
const List<FontFeature> kTabular = [FontFeature.tabularFigures()];

/// Tokens de cor. Neutros cinzentos (papel do boletim de vacinas), um único
/// acento índigo e duas cores semânticas suaves.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.primary,
    required this.onPrimary,
    required this.primarySoft,
    required this.danger,
    required this.success,
    required this.ink,
    required this.muted,
    required this.faint,
    required this.background,
    required this.surface,
    required this.raised,
    required this.border,
  });

  /// Acento: ação principal, seleção e o valor que importa.
  final Color primary;
  /// Texto/ícones sobre o acento.
  final Color onPrimary;
  /// Fundo muito suave do acento (estado ativo da navegação).
  final Color primarySoft;
  /// Erros e remoção confirmada.
  final Color danger;
  /// Concluído.
  final Color success;
  /// Texto principal.
  final Color ink;
  /// Texto secundário (contraste ≥ 4.5:1).
  final Color muted;
  /// Texto terciário, metadados e ícones discretos.
  final Color faint;
  /// Fundo do ecrã.
  final Color background;
  /// Superfície de cartões.
  final Color surface;
  /// Um degrau acima da superfície (avatares, carimbos, trilhos).
  final Color raised;
  /// Linha fina de contorno.
  final Color border;

  static const light = AppPalette(
    primary: Color(0xFF3D3A8C),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFECECF6),
    danger: Color(0xFFB0433D),
    success: Color(0xFF2F7A57),
    ink: Color(0xFF1C1C1F),
    muted: Color(0xFF5C5C63),
    faint: Color(0xFF75757C),
    background: Color(0xFFF6F6F4),
    surface: Color(0xFFFFFFFF),
    raised: Color(0xFFEFEFEC),
    border: Color(0xFFE4E4E0),
  );

  static const dark = AppPalette(
    primary: Color(0xFFAFACF2),
    onPrimary: Color(0xFF17162E),
    primarySoft: Color(0xFF26263A),
    danger: Color(0xFFE2867E),
    success: Color(0xFF79C29C),
    ink: Color(0xFFEDEDEF),
    muted: Color(0xFFA6A6AD),
    faint: Color(0xFF85858C),
    background: Color(0xFF141415),
    surface: Color(0xFF1C1C1E),
    raised: Color(0xFF262628),
    border: Color(0xFF2C2C2F),
  );

  @override
  AppPalette copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primarySoft,
    Color? danger,
    Color? success,
    Color? ink,
    Color? muted,
    Color? faint,
    Color? background,
    Color? surface,
    Color? raised,
    Color? border,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primarySoft: primarySoft ?? this.primarySoft,
      danger: danger ?? this.danger,
      success: success ?? this.success,
      ink: ink ?? this.ink,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      raised: raised ?? this.raised,
      border: border ?? this.border,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      danger: l(danger, other.danger),
      success: l(success, other.success),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      faint: l(faint, other.faint),
      background: l(background, other.background),
      surface: l(surface, other.surface),
      raised: l(raised, other.raised),
      border: l(border, other.border),
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
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 240);
  static const Curve curve = Curves.easeOutCubic;
}
