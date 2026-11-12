import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/reminder_service.dart';
import '../utils/formatters.dart';
import '../widgets/reminder_tile.dart';
import '../widgets/stat_card.dart';
import 'login_screen.dart';

/// Dashboard: resumo do dia, estatísticas e próximos lembretes.
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
  List<Reminder> _upcoming = [];

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
    final todayStart = startOfDay(DateTime.now());
    final tomorrow = todayStart.add(const Duration(days: 1));

    final pets = await _db.getPets();
    final today = await _db.getRemindersBetween(todayStart, tomorrow);
    final upcoming = await _db.getUpcomingReminders(tomorrow, limit: 3);

    if (!mounted) return;
    setState(() {
      _petCount = pets.length;
      _today = today;
      _upcoming = upcoming;
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
    final now = DateTime.now();
    final doneToday = _today.where((r) => r.done).length;

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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Text(
                    greetingFor(now),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: kInkColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatLongDate(now),
                    style: const TextStyle(color: kMutedColor, fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  _TodaySummary(total: _today.length, done: doneToday),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: _petCount,
                          label: 'Animais',
                          icon: Icons.pets_rounded,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          value: _today.length,
                          label: 'Hoje',
                          icon: Icons.today_rounded,
                          color: kSecondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          value: doneToday,
                          label: 'Concluídos',
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF2EC4B6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle('Hoje'),
                  const SizedBox(height: 12),
                  if (_petCount == 0)
                    const _HintCard(
                      icon: Icons.pets_rounded,
                      text:
                          'Ainda não tem animais. Registe o primeiro no separador "Animais".',
                    )
                  else if (_today.isEmpty)
                    const _HintCard(
                      icon: Icons.event_available_rounded,
                      text: 'Nada agendado para hoje. Aproveite o dia!',
                    )
                  else
                    ..._today.map(
                      (r) => ReminderTile(
                        reminder: r,
                        showDate: false,
                        onToggle: (done) => ReminderService.setDone(r, done),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const _SectionTitle('Próximos lembretes'),
                  const SizedBox(height: 12),
                  if (_upcoming.isEmpty)
                    const _HintCard(
                      icon: Icons.notifications_none_rounded,
                      text: 'Sem lembretes futuros. Crie um no separador "Lembretes".',
                    )
                  else
                    ..._upcoming.map(
                      (r) => ReminderTile(
                        reminder: r,
                        onToggle: (done) => ReminderService.setDone(r, done),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary({required this.total, required this.done});

  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final pending = total - done;

    final title = total == 0
        ? 'Dia tranquilo'
        : pending == 0
            ? 'Tudo concluído!'
            : pending == 1
                ? '1 cuidado por fazer'
                : '$pending cuidados por fazer';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: kBrandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            total == 0
                ? 'Não há lembretes agendados para hoje.'
                : '$done de $total lembretes concluídos',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: kInkColor,
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: const TextStyle(color: kMutedColor, height: 1.4)),
            ),
          ],
        ),
      ),
    );
  }
}
