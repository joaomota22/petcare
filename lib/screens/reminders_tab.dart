import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../services/database_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/reminder_tile.dart';
import 'reminder_form_screen.dart';

/// Lista de lembretes/tarefas (vacinas, banhos, desparasitações, etc.).
class RemindersTab extends StatefulWidget {
  const RemindersTab({super.key});

  @override
  State<RemindersTab> createState() => _RemindersTabState();
}

class _RemindersTabState extends State<RemindersTab> {
  final _db = DatabaseService.instance;

  /// null = a carregar
  List<Reminder>? _reminders;

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

  Future<void> _openForm([Reminder? reminder]) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ReminderFormScreen(reminder: reminder)),
    );
  }

  Future<void> _confirmDelete(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover "${reminder.title}"?'),
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
    if (confirmed == true && reminder.id != null) {
      await _db.deleteReminder(reminder.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lembretes')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_alarm_rounded),
        label: const Text('Novo lembrete'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final reminders = _reminders;

    if (reminders == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (reminders.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'Sem lembretes',
        message:
            'Crie lembretes para vacinas, banhos, desparasitações e passeios.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return ReminderTile(
            reminder: reminder,
            onToggle: (done) => _db.setReminderDone(reminder.id!, done),
            onTap: () => _openForm(reminder),
            onDelete: () => _confirmDelete(reminder),
          );
        },
      ),
    );
  }
}
