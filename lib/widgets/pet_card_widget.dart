import 'package:flutter/material.dart';

import 'pressable.dart';

import '../app_theme.dart';
import '../models/pet.dart';
import '../utils/formatters.dart';
import 'pet_avatar.dart';

/// Cartão de animal: avatar, nome, etiqueta da raça e dados rápidos.
class PetCardWidget extends StatelessWidget {
  const PetCardWidget({
    super.key,
    required this.pet,
    this.onTap,
    this.onDelete,
  });

  final Pet pet;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = speciesColor(pet.species);
    final anos = pet.age == 1 ? 'ano' : 'anos';

    return Pressable(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PetAvatar(name: pet.name, species: pet.species, size: 58),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: context.palette.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _Tag(label: pet.breed, color: color),
                        const SizedBox(height: 8),
                        Text(
                          '${pet.age} $anos  •  ${formatWeight(pet.weight)} kg  •  ${pet.gender}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.palette.muted,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: context.palette.accent,
                      tooltip: 'Remover',
                      onPressed: onDelete,
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: context.palette.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: context.palette.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
