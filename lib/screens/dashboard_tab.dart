import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/reminder_tile.dart';
import 'login_screen.dart';

/// Dashboard: resumo do dia e lembretes de hoje.
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final _db = DatabaseService.instance;

  bool _loading = true;
  int _petCount = 0;
  List<Reminder> _today = [];

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
    final start = startOfDay(DateTime.now());
    final end = start.add(const Duration(days: 1));

    final pets = await _db.getPets();
    final today = await _db.getRemindersBetween(start, end);

    if (!mounted) return;
    setState(() {
      _petCount = pets.length;
      _today = today;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = _today.where((r) => r.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetCare 360'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _GreetingCard(date: DateTime.now()),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          value: _petCount,
                          label: 'Animais',
                          icon: Icons.pets_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: _today.length,
                          label: 'Hoje',
                          icon: Icons.today_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          value: doneCount,
                          label: 'Concluídos',
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lembretes de hoje',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_today.isEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const EmptyState(
                        icon: Icons.event_available_rounded,
                        title: 'Sem lembretes para hoje',
                        message:
                            'Aproveite o dia! Adicione lembretes no separador "Lembretes".',
                      ),
                    )
                  else
                    ..._today.map(
                      (reminder) => ReminderTile(
                        reminder: reminder,
                        showDate: false,
                        onToggle: (done) =>
                            _db.setReminderDone(reminder.id!, done),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryColor, Color(0xFF9D94FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Olá!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatLongDate(date),
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final int value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: kPrimaryColor),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
