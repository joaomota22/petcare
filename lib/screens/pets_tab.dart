import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../services/database_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/pet_card_widget.dart';
import 'pet_form_screen.dart';

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

  Future<void> _openForm([Pet? pet]) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetFormScreen(pet: pet)),
    );
  }

  Future<void> _confirmDelete(Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover ${pet.name}?'),
        content: const Text(
          'Os lembretes associados a este animal também serão removidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmed == true && pet.id != null) {
      await _db.deletePet(pet.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Os meus animais')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final pets = _pets;

    if (pets == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pets.isEmpty) {
      return const EmptyState(
        icon: Icons.pets,
        title: 'Nenhum animal registado',
        message: 'Toque em "Adicionar" para registar o seu primeiro amigo.',
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
            onTap: () => _openForm(pet),
            onDelete: () => _confirmDelete(pet),
          );
        },
      ),
    );
  }
}
