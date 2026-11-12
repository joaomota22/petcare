import 'package:flutter/material.dart';

import '../models/pet.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

/// Adicionar ou editar um animal (com validações).
class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.pet});

  final Pet? pet;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService.instance;

  late final _nameCtrl = TextEditingController(text: widget.pet?.name ?? '');
  late final _breedCtrl = TextEditingController(text: widget.pet?.breed ?? '');
  late final _ageCtrl = TextEditingController(
    text: widget.pet == null ? '' : '${widget.pet!.age}',
  );
  late final _weightCtrl = TextEditingController(
    text: widget.pet == null ? '' : formatWeight(widget.pet!.weight),
  );
  late final _notesCtrl = TextEditingController(
    text: widget.pet?.medicalNotes ?? '',
  );

  late String _species = widget.pet?.species ?? petSpecies.first;
  late String _gender = widget.pet?.gender ?? petGenders.first;

  bool _saving = false;

  bool get _isEditing => widget.pet != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _breedCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final pet = Pet(
      id: widget.pet?.id,
      name: _nameCtrl.text.trim(),
      species: _species,
      breed: _breedCtrl.text.trim(),
      age: int.parse(_ageCtrl.text.trim()),
      weight: Validators.parseDecimal(_weightCtrl.text)!,
      gender: _gender,
      medicalNotes: _notesCtrl.text.trim(),
    );

    try {
      if (_isEditing) {
        await _db.updatePet(pet);
      } else {
        await _db.insertPet(pet);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível guardar. Tente novamente.')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final pet = widget.pet;
    if (pet?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover ${pet!.name}?'),
        content: const Text('Esta ação não pode ser desfeita.'),
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
    if (confirmed != true) return;

    await _db.deletePet(pet!.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar animal' : 'Novo animal'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remover',
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameCtrl,
                label: 'Nome do animal',
                icon: Icons.pets,
                textInputAction: TextInputAction.next,
                validator: Validators.petName,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _species,
                decoration: const InputDecoration(
                  labelText: 'Espécie',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: petSpecies
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _species = value!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _breedCtrl,
                label: 'Raça',
                icon: Icons.auto_awesome_outlined,
                textInputAction: TextInputAction.next,
                validator: Validators.breed,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _ageCtrl,
                      label: 'Idade (anos)',
                      icon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: Validators.age,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _weightCtrl,
                      label: 'Peso (kg)',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: Validators.weight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'Género',
                  prefixIcon: Icon(Icons.male_outlined),
                ),
                items: petGenders
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value!),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _notesCtrl,
                label: 'Notas / condições de saúde',
                icon: Icons.medical_information_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
