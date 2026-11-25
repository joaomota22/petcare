import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/pet.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/reminder_service.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/form_scaffold.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state.dart';

/// Criar ou editar um lembrete associado a um animal.
class ReminderFormScreen extends StatefulWidget {
  const ReminderFormScreen({super.key, this.reminder, this.initialPetId});

  /// Se null, cria um lembrete novo.
  final Reminder? reminder;

  /// Animal pré-selecionado ao criar (ex.: vindo do perfil do animal).
  final int? initialPetId;

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService.instance;

  late final _titleCtrl = TextEditingController(
    text: widget.reminder?.title ?? '',
  );
  late final _notesCtrl = TextEditingController(
    text: widget.reminder?.notes ?? '',
  );

  late ReminderCategory _category =
      widget.reminder?.category ?? ReminderCategory.vacina;
  late DateTime _dateTime = widget.reminder?.dateTime ?? _defaultDateTime();

  /// null = a carregar
  List<Pet>? _pets;
  int? _petId;
  bool _saving = false;

  bool get _isEditing => widget.reminder != null;

  static DateTime _defaultDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, now.hour + 1);
  }

  @override
  void initState() {
    super.initState();
    _petId = widget.reminder?.petId ?? widget.initialPetId;
    _loadPets();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    final pets = await _db.getPets();
    if (!mounted) return;
    setState(() {
      _pets = pets;
      final exists = pets.any((p) => p.id == _petId);
      if (!exists) _petId = pets.isNotEmpty ? pets.first.id : null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked == null) return;
    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    // Pede permissão para notificações (o sistema só mostra o diálogo uma vez).
    await NotificationService.instance.requestPermission();

    final reminder = Reminder(
      id: widget.reminder?.id,
      petId: _petId!,
      title: _titleCtrl.text.trim(),
      category: _category,
      dateTime: _dateTime,
      done: widget.reminder?.done ?? false,
      notes: _notesCtrl.text.trim(),
    );

    try {
      await ReminderService.save(reminder);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível guardar. Tente novamente')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FormScaffold(
      title: _isEditing ? 'Editar lembrete' : 'Novo lembrete',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final pets = _pets;

    if (pets == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pets.isEmpty) {
      return const EmptyState(
        icon: Icons.pets_outlined,
        title: 'Ainda não há animais',
        message: 'Registe primeiro um animal para lhe criar lembretes.',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(Space.m, Space.xs, Space.m, Space.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              style: TextStyle(fontSize: 16, color: context.palette.ink),
              initialValue: _petId,
              decoration: const InputDecoration(
                labelText: 'Animal',
                prefixIcon: Icon(Icons.pets_outlined),
              ),
              items: pets
                  .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
                  .toList(),
              validator: (value) => value == null ? 'Escolha um animal' : null,
              onChanged: (value) => setState(() => _petId = value),
            ),
            const SizedBox(height: Space.s),
            DropdownButtonFormField<ReminderCategory>(
              style: TextStyle(fontSize: 16, color: context.palette.ink),
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Tipo de cuidado',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ReminderCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: Space.s),
            CustomTextField(
              controller: _titleCtrl,
              label: 'Título',
              hint: 'Ex.: Vacina da raiva',
              icon: Icons.title,
              textInputAction: TextInputAction.next,
              validator: Validators.reminderTitle,
            ),
            const SizedBox(height: Space.s),
            Row(
              children: [
                Expanded(
                  child: _PickerField(
                    icon: Icons.calendar_today_outlined,
                    label: 'Data',
                    value: formatDate(_dateTime),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: Space.s),
                Expanded(
                  child: _PickerField(
                    icon: Icons.access_time,
                    label: 'Hora',
                    value: formatTime(_dateTime),
                    onTap: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.s),
            CustomTextField(
              controller: _notesCtrl,
              label: 'Notas (opcional)',
              icon: Icons.notes,
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.palette.onPrimary,
                      ),
                    )
                  : Text(_isEditing ? 'Guardar alterações' : 'Criar lembrete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.control),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: context.palette.ink,
            fontFeatures: kTabular,
          ),
        ),
      ),
    );
  }
}
