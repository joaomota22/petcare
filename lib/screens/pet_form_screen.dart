import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/pet.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';

/// Adicionar ou editar um animal (com validações).
class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.pet});

  /// Se null, cria um animal novo.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar animal' : 'Novo animal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _FormSection(title: 'Identificação'),
              CustomTextField(
                controller: _nameCtrl,
                label: 'Nome do animal',
                icon: Icons.pets_rounded,
                textInputAction: TextInputAction.next,
                validator: Validators.petName,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
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
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(
                        labelText: 'Género',
                        prefixIcon: Icon(Icons.male_rounded),
                      ),
                      items: petGenders
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (value) => setState(() => _gender = value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _breedCtrl,
                label: 'Raça',
                icon: Icons.auto_awesome_outlined,
                textInputAction: TextInputAction.next,
                validator: Validators.breed,
              ),
              const SizedBox(height: 24),
              const _FormSection(title: 'Medidas'),
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
                  const SizedBox(width: 14),
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
              const SizedBox(height: 24),
              const _FormSection(title: 'Saúde'),
              CustomTextField(
                controller: _notesCtrl,
                label: 'Notas / condições de saúde',
                hint: 'Ex.: alergias, medicação habitual, cirurgias…',
                icon: Icons.medical_information_outlined,
                maxLines: 4,
                maxLength: 300,
              ),
              const SizedBox(height: 28),
              FilledButton(
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
                    : Text(_isEditing ? 'Guardar alterações' : 'Guardar animal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
