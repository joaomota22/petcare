import 'package:flutter/material.dart';

import 'pressable.dart';

import '../app_theme.dart';
import '../models/pet.dart';
import '../utils/formatters.dart';
import 'pet_avatar.dart';

/// Cartão de animal: avatar, nome, raça e dados rápidos.
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
    final p = context.palette;
    final anos = pet.age == 1 ? 'ano' : 'anos';

    return Pressable(
      child: Padding(
        padding: const EdgeInsets.only(bottom: Space.xs),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.m, Space.m, Space.xxs, Space.m),
              child: Row(
                children: [
                  PetAvatar(name: pet.name, species: pet.species, size: 48),
                  const SizedBox(width: Space.s),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: p.ink,
                          ),
                        ),
                        const SizedBox(height: Space.xxs),
                        Text(
                          '${pet.species} · ${pet.breed}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: p.muted, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${pet.age} $anos · ${formatWeight(pet.weight)} kg · ${pet.gender}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: p.faint,
                            fontSize: 13,
                            fontFeatures: kTabular,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      color: p.faint,
                      tooltip: 'Remover',
                      onPressed: onDelete,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(right: Space.s),
                      child: Icon(Icons.chevron_right, size: 20, color: p.faint),
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
