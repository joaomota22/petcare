import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Avatar do animal: círculo com a cor da espécie e a inicial do nome.
class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.name,
    required this.species,
    this.size = 56,
  });

  final String name;
  final String species;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = speciesColor(species);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: color,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
