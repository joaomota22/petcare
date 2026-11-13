import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/reminder_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/skeleton_list.dart';
import 'reminder_form_screen.dart';

enum _ReminderFilter { todos, porFazer, concluidos }

/// Lista de lembretes/tarefas (vacinas, banhos, desparasitações, etc.) com filtros.
class RemindersTab extends StatefulWidget {
  const RemindersTab({super.key});

  @override
  State<RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends State<RemindersTab> {
  final _db = DatabaseService.instance;

  /// null = a carregar
  List<Reminder>? _reminders;
  _ReminderFilter _filter = _ReminderFilter.todos;

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
    final reminders = await _db.getReminders();
    if (!mounted) return;
    setState(() => _reminders = reminders);
  }

  void _openForm([Reminder? reminder]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReminderFormScreen(reminder: reminder)),
    );
  }

  Future<void> _confirmDelete(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover "${reminder.title}"?'),
        content: const Text('A notificação deste lembrete também será cancelada.'),
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
    if (confirmed == true) {
      await ReminderService.delete(reminder);
    }
  }

  List<Reminder> _applyFilter(List<Reminder> all) {
    switch (_filter) {
      case _ReminderFilter.todos:
        return all;
      case _ReminderFilter.porFazer:
        return all.where((r) => !r.done).toList();
      case _ReminderFilter.concluidos:
        return all.where((r) => r.done).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null, // ver pets_tab.dart
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Novo lembrete'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final all = _reminders;

    if (all == null) {
      return const SkeletonList(itemHeight: 76);
    }

    if (all.isEmpty) {
      return EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Sem lembretes',
        message:
            'Crie lembretes para vacinas, banhos, desparasitações, medicação e passeios. Recebe uma notificação à hora marcada.',
        actionLabel: 'Criar lembrete',
        onAction: () => _openForm(),
      );
    }

    final visible = _applyFilter(all);

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _FilterChip(
                label: 'Todos',
                selected: _filter == _ReminderFilter.todos,
                onTap: () => setState(() => _filter = _ReminderFilter.todos),
              ),
              _FilterChip(
                label: 'Por fazer',
                selected: _filter == _ReminderFilter.porFazer,
                onTap: () => setState(() => _filter = _ReminderFilter.porFazer),
              ),
              _FilterChip(
                label: 'Concluídos',
                selected: _filter == _ReminderFilter.concluidos,
                onTap: () => setState(() => _filter = _ReminderFilter.concluidos),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const EmptyState(
                  icon: Icons.task_alt_rounded,
                  title: 'Nada por aqui',
                  message: 'Não há lembretes neste filtro.',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final reminder = visible[index];
                      return ReminderTile(
                        reminder: reminder,
                        onToggle: (done) =>
                            ReminderService.setDone(reminder, done),
                        onTap: () => _openForm(reminder),
                        onDelete: () => _confirmDelete(reminder),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: kPrimaryColor,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? kPrimaryColor : const Color(0xFFE3E1EE),
        ),
        labelStyle: TextStyle(
          color: selected ? Colors.white : kInkColor,
          fontWeight: FontWeight.w700,
        ),
        showCheckmark: false,
      ),
    );
  }
}
