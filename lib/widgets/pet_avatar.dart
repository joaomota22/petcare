import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Avatar do animal: círculo neutro com a inicial do nome.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.name,
    required this.species,
    this.size = 48,
  });

  final String name;
  final String species;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: p.raised,
        shape: BoxShape.circle,
        border: Border.all(color: p.border),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: p.muted,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
