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
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.danger,
              foregroundColor: context.palette.surface,
            ),
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
        // O nome já aparece no cabeçalho do perfil.
        title: pet == null ? const Text('Animal') : null,
        actions: [
          if (pet != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: _edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
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
        icon: Icons.search_off,
        title: 'Animal não encontrado',
        message: 'Pode ter sido removido.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.m, Space.xs, Space.m, Space.xl),
        children: [
          _ProfileHeader(pet: pet),
          const SizedBox(height: Space.l),
          _FactsCard(pet: pet),
          const SizedBox(height: Space.s),
          _WeightCard(
            weights: _weights,
            currentWeight: pet.weight,
            onAdd: _addWeight,
          ),
          if (pet.medicalNotes.isNotEmpty) ...[
            const SizedBox(height: Space.s),
            _NotesCard(notes: pet.medicalNotes),
          ],
          const SizedBox(height: Space.l),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Próximos lembretes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 17),
                ),
              ),
              TextButton.icon(
                onPressed: _addReminder,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Novo'),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          if (_reminders.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Space.m),
                child: Text(
                  'Sem lembretes pendentes para ${pet.name}',
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
    final p = context.palette;
    return Row(
      children: [
        PetAvatar(name: pet.name, species: pet.species, size: 64),
        const SizedBox(width: Space.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pet.name, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: Space.xxs),
              Text(
                '${pet.species} · ${pet.breed}',
                style: TextStyle(color: p.muted, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Idade, peso e género numa só linha de ficha, separados por linhas finas.
class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final divider = VerticalDivider(width: 1, thickness: 1, color: context.palette.border);
    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: [
            _Fact(label: 'Idade', value: '${pet.age} ${pet.age == 1 ? 'ano' : 'anos'}'),
            divider,
            _Fact(label: 'Peso', value: '${formatWeight(pet.weight)} kg'),
            divider,
            _Fact(label: 'Género', value: pet.gender),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.m, vertical: Space.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: p.faint, fontSize: 13)),
            const SizedBox(height: 2),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: p.ink,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFeatures: kTabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Peso atual, variação desde o primeiro registo e a curva ao longo do tempo.
class _WeightCard extends StatelessWidget {
  const _WeightCard({
    required this.weights,
    required this.currentWeight,
    required this.onAdd,
  });

  final List<WeightEntry> weights;
  final double currentWeight;
  final VoidCallback onAdd;

  String? _changeLabel() {
    if (weights.length < 2) return null;
    final first = weights.first;
    final delta = weights.last.weight - first.weight;
    final since = formatDate(first.recordedAt).substring(0, 5);
    if (delta.abs() < 0.05) return 'Sem alteração desde $since';
    final sign = delta > 0 ? '+' : '−';
    return '$sign${formatWeight(delta.abs())} kg desde $since';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final latest = weights.isEmpty ? currentWeight : weights.last.weight;
    final change = _changeLabel();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.m, Space.m, Space.xs, Space.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Evolução do peso', style: TextStyle(color: p.muted, fontSize: 14)),
                      const SizedBox(height: Space.xxs),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: formatWeight(latest),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w500,
                                color: p.ink,
                              ),
                            ),
                            TextSpan(
                              text: ' kg',
                              style: TextStyle(fontSize: 16, color: p.muted),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontFeatures: kTabular),
                      ),
                      if (change != null)
                        Text(
                          change,
                          style: TextStyle(
                            color: p.muted,
                            fontSize: 13,
                            fontFeatures: kTabular,
                          ),
                        ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Registar'),
                ),
              ],
            ),
            const SizedBox(height: Space.l),
            SizedBox(
              height: 168,
              child: weights.length < 2
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: Space.xs),
                        child: Text(
                          'Registe pelo menos dois pesos para ver a evolução',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: p.faint),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: Space.xs),
                      child: _WeightChart(weights: weights),
                    ),
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

  /// Passo "redondo" (0.5, 1, 2, 5…) que divide o intervalo em ~3 linhas.
  static double _niceStep(double range) {
    final raw = range / 3;
    for (final s in [0.1, 0.2, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0, 50.0]) {
      if (raw <= s) return s;
    }
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final values = weights.map((w) => w.weight).toList();
    final lo = values.reduce((a, b) => a < b ? a : b);
    final hi = values.reduce((a, b) => a > b ? a : b);
    final step = _niceStep((hi - lo) < 1 ? 1 : hi - lo);
    final minY = lo - step / 4;
    final maxY = hi + step / 4;
    final last = weights.length - 1;
    final spots = [
      for (var i = 0; i < weights.length; i++)
        FlSpot(i.toDouble(), weights[i].weight),
    ];
    final labelStyle = TextStyle(color: p.faint, fontSize: 11, fontFeatures: kTabular);

    return LineChart(
      LineChartData(
        minY: minY < 0 ? 0 : minY,
        maxY: maxY,
        minX: 0,
        maxX: last.toDouble(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) => FlLine(color: p.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => p.ink,
            getTooltipItems: (spots) => [
              for (final s in spots)
                LineTooltipItem(
                  '${formatWeight(s.y)} kg',
                  TextStyle(color: p.surface, fontSize: 12, fontFeatures: kTabular),
                ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: step,
              getTitlesWidget: (value, meta) {
                // Só os valores redondos da grelha, não os limites do eixo.
                final onGrid = (value / step - (value / step).round()).abs() < 1e-6;
                if (!onGrid) return const SizedBox.shrink();
                return Text(formatWeight(value), style: labelStyle);
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                // Só o primeiro e o último registo, para não amontoar datas.
                if (i != 0 && i != last) return const SizedBox.shrink();
                return SideTitleWidget(
                  meta: meta,
                  space: Space.xs,
                  fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                  child: Text(
                    formatDate(weights[i].recordedAt).substring(0, 5),
                    style: labelStyle,
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
            preventCurveOverShooting: true,
            color: p.primary,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              // Só o registo mais recente fica marcado.
              checkToShowDot: (spot, _) => spot.x == last,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 4,
                color: p.primary,
                strokeWidth: 2,
                strokeColor: p.surface,
              ),
            ),
            belowBarData: BarAreaData(show: false),
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
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notas de saúde', style: TextStyle(color: p.faint, fontSize: 13)),
            const SizedBox(height: Space.xxs),
            Text(notes, style: TextStyle(color: p.ink, height: 1.45)),
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
