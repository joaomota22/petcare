import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/pet.dart';
import '../utils/formatters.dart';
import 'pet_avatar.dart';

/// Cartão reutilizável que apresenta um animal na lista.
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                PetAvatar(name: pet.name, species: pet.species),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: kInkColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Tag(label: pet.breed, color: color),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${pet.age} $anos  •  ${formatWeight(pet.weight)} kg  •  ${pet.gender}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kMutedColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: Colors.redAccent,
                    tooltip: 'Remover',
                    onPressed: onDelete,
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: kMutedColor),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
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
