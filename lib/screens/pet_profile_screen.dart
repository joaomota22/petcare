import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/pet.dart';
import '../models/reminder.dart';
import '../models/weight_entry.dart';
import '../services/database_service.dart';
import '../services/reminder_service.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/reminder_tile.dart';
import 'pet_form_screen.dart';
import 'reminder_form_screen.dart';

/// Perfil do animal: dados, gráfico da evolução do peso e próximos lembretes.
class PetProfileScreen extends StatefulWidget {
  const PetProfileScreen({super.key, required this.petId});

  final int petId;

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final _db = DatabaseService.instance;

  bool _loading = true;
  bool _notFound = false;
  Pet? _pet;
  List<WeightEntry> _weights = [];
  List<Reminder> _reminders = [];

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
    final matches = pets.where((p) => p.id == widget.petId);

    if (matches.isEmpty) {
      if (!mounted) return;
      setState(() {
        _notFound = true;
        _loading = false;
      });
      return;
    }

    final pet = matches.first;
    final weights = await _db.getWeightHistory(widget.petId);
    final reminders = (await _db.getReminders())
        .where((r) => r.petId == widget.petId && !r.done)
        .take(3)
        .toList();

    if (!mounted) return;
    setState(() {
      _pet = pet;
      _weights = weights;
      _reminders = reminders;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final pet = _pet;
    if (pet == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PetFormScreen(pet: pet)),
    );
  }

  Future<void> _delete() async {
    final pet = _pet;
    if (pet == null || pet.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover ${pet.name}?'),
        content: const Text('Esta ação não pode ser desfeita.'),
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
    if (confirmed != true) return;

    await ReminderService.deletePet(pet.id!);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _addWeight() async {
    final pet = _pet;
    if (pet == null) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _WeightDialog(petId: pet.id!, currentWeight: pet.weight),
    );
  }

  void _addReminder() {
    final pet = _pet;
    if (pet == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReminderFormScreen(initialPetId: pet.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = _pet;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet?.name ?? 'Animal'),
        actions: [
          if (pet != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: _edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Remover',
              onPressed: _delete,
            ),
          ],
        ],
      ),
      body: _buildBody(pet),
    );
  }

  Widget _buildBody(Pet? pet) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_notFound || pet == null) {
      return const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Animal não encontrado',
        message: 'Pode ter sido removido.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _ProfileHeader(pet: pet),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.cake_outlined,
                  label: 'Idade',
                  value: '${pet.age} ${pet.age == 1 ? 'ano' : 'anos'}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Peso',
                  value: '${formatWeight(pet.weight)} kg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.male_rounded,
                  label: 'Género',
                  value: pet.gender,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _WeightCard(weights: _weights, onAdd: _addWeight),
          if (pet.medicalNotes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _NotesCard(notes: pet.medicalNotes),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Próximos lembretes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.palette.ink,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: _addReminder,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Novo'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_reminders.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  'Sem lembretes pendentes para ${pet.name}.',
                  style: TextStyle(color: context.palette.muted),
                ),
              ),
            )
          else
            ..._reminders.map(
              (r) => ReminderTile(
                reminder: r,
                onToggle: (done) => ReminderService.setDone(r, done),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: context.palette.brandGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: PetAvatar(name: pet.name, species: pet.species, size: 76),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.species} • ${pet.breed}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: context.palette.primary),
            const SizedBox(height: 6),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, color: context.palette.ink),
            ),
            Text(label, style: TextStyle(color: context.palette.muted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.weights, required this.onAdd});

  final List<WeightEntry> weights;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Evolução do peso',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Registar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: weights.length < 2
                  ? Center(
                      child: Text(
                        'Registe pelo menos dois pesos para ver o gráfico.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.palette.muted),
                      ),
                    )
                  : _WeightChart(weights: weights),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.weights});

  final List<WeightEntry> weights;

  @override
  Widget build(BuildContext context) {
    final values = weights.map((w) => w.weight).toList();
    final minY = values.reduce((a, b) => a < b ? a : b) - 1;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 1;
    final spots = [
      for (var i = 0; i < weights.length; i++)
        FlSpot(i.toDouble(), weights[i].weight),
    ];

    return LineChart(
      LineChartData(
        minY: minY < 0 ? 0 : minY,
        maxY: maxY,
        gridData: const FlGridData(drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                formatWeight(value),
                style: TextStyle(color: context.palette.muted, fontSize: 11),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= weights.length) return const SizedBox.shrink();
                final d = weights[i].recordedAt;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    formatDate(d).substring(0, 5),
                    style: TextStyle(color: context.palette.muted, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: context.palette.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: context.palette.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotesCard extends StatelessWidget {
  const _NotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.medical_information_outlined, color: context.palette.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notes,
                style: TextStyle(color: context.palette.ink, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightDialog extends StatefulWidget {
  const _WeightDialog({required this.petId, required this.currentWeight});

  final int petId;
  final double currentWeight;

  @override
  State<_WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<_WeightDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _ctrl = TextEditingController(
    text: formatWeight(widget.currentWeight),
  );
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await DatabaseService.instance.addWeight(
      widget.petId,
      Validators.parseDecimal(_ctrl.text)!,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registar peso'),
      content: Form(
        key: _formKey,
        child: CustomTextField(
          controller: _ctrl,
          label: 'Peso (kg)',
          icon: Icons.monitor_weight_outlined,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: Validators.weight,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
