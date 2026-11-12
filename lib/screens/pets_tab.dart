import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/pet.dart';
import '../services/database_service.dart';
import '../services/reminder_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/pet_card_widget.dart';
import '../widgets/skeleton_list.dart';
import 'pet_form_screen.dart';
import 'pet_profile_screen.dart';

/// Lista dinâmica de animais, com estados "a carregar" e "lista vazia".
class PetsTab extends StatefulWidget {
  const PetsTab({super.key});

  @override
  State<PetsTab> createState() => _PetsTabState();
}

class _PetsTabState extends State<PetsTab> {
  final _db = DatabaseService.instance;

  /// null = a carregar
  List<Pet>? _pets;

  @override
  void initState() {
    super.initState();
    DatabaseService.changes.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    DatabaseService.changes.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final pets = await _db.getPets();
    if (!mounted) return;
    setState(() => _pets = pets);
  }

  void _openForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PetFormScreen()),
    );
  }

  void _openProfile(Pet pet) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetProfileScreen(petId: pet.id!)),
    );
  }

  Future<void> _confirmDelete(Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover ${pet.name}?'),
        content: const Text(
          'Os lembretes e o histórico de peso deste animal também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true && pet.id != null) {
      await ReminderService.deletePet(pet.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pets = _pets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Os meus animais'),
        actions: [
          if (pets != null && pets.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${pets.length}',
                    style: const TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Adicionar'),
      ),
      body: _buildBody(pets),
    );
  }

  Widget _buildBody(List<Pet>? pets) {
    if (pets == null) {
      return const SkeletonList();
    }

    if (pets.isEmpty) {
      return EmptyState(
        icon: Icons.pets_rounded,
        title: 'Nenhum animal registado',
        message:
            'Registe o seu primeiro amigo para começar a acompanhar a saúde, o peso e os cuidados.',
        actionLabel: 'Adicionar animal',
        onAction: _openForm,
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          return PetCardWidget(
            pet: pet,
            onTap: () => _openProfile(pet),
            onDelete: () => _confirmDelete(pet),
          );
        },
      ),
    );
  }
}
