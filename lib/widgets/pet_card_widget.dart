import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../utils/formatters.dart';

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
    final scheme = Theme.of(context).colorScheme;
    final anos = pet.age == 1 ? 'ano' : 'anos';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: onTap,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.pets_rounded, color: scheme.primary),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${pet.species} • ${pet.breed}'),
              const SizedBox(height: 4),
              Text(
                '${pet.gender} • ${pet.age} $anos • '
                '${formatWeight(pet.weight)} kg',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        trailing: onDelete == null
            ? null
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Remover',
                onPressed: onDelete,
              ),
      ),
    );
  }
}
