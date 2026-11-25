import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/reminder_service.dart';
import '../utils/formatters.dart';
import '../widgets/reminder_tile.dart';
import 'login_screen.dart';

/// Dashboard: data de hoje, resumo do dia e próximos lembretes.
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
    final total = _today.length;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(Space.m, Space.m, Space.m, Space.xl),
                  children: [
                    _Header(date: now, onLogout: _logout),
                    const SizedBox(height: Space.l),
                    _TodaySummary(done: doneToday, total: total, pets: _petCount),
                    const SizedBox(height: Space.xl),
                    const _SectionTitle('Hoje'),
                    const SizedBox(height: Space.s),
                    if (_petCount == 0)
                      const _HintCard(
                        icon: Icons.pets_outlined,
                        text:
                            'Ainda não tem animais. Registe o primeiro no separador Animais.',
                      )
                    else if (_today.isEmpty)
                      const _HintCard(
                        icon: Icons.event_available_outlined,
                        text: 'Nada agendado para hoje',
                      )
                    else
                      ..._today.map(
                        (r) => ReminderTile(
                          reminder: r,
                          onToggle: (done) => ReminderService.setDone(r, done),
                        ),
                      ),
                    const SizedBox(height: Space.l),
                    const _SectionTitle('Próximos lembretes'),
                    const SizedBox(height: Space.s),
                    if (_upcoming.isEmpty)
                      const _HintCard(
                        icon: Icons.notifications_none,
                        text:
                            'Sem lembretes futuros. Crie um no separador Lembretes.',
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
      ),
    );
  }
}

/// Cabeçalho: o dia de hoje e a saída da conta.
class _Header extends StatelessWidget {
  const _Header({required this.date, required this.onLogout});

  final DateTime date;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatWeekday(date),
                style: TextStyle(color: p.muted, fontSize: 14),
              ),
              const SizedBox(height: Space.xxs),
              Text(
                formatDayMonth(date),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.logout, size: 20, color: p.faint),
          tooltip: 'Sair',
          onPressed: onLogout,
        ),
      ],
    );
  }
}

/// Resumo do dia, como uma página do boletim: o que falta e o progresso.
class _TodaySummary extends StatelessWidget {
  const _TodaySummary({
    required this.done,
    required this.total,
    required this.pets,
  });

  final int done;
  final int total;
  final int pets;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final progress = total == 0 ? 0.0 : done / total;
    final pending = total - done;
    final title = total == 0
        ? 'Dia tranquilo'
        : pending == 0
            ? 'Tudo concluído'
            : pending == 1
                ? '1 cuidado por fazer'
                : '$pending cuidados por fazer';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.l - Space.xxs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Resumo de hoje',
                    style: TextStyle(color: p.muted, fontSize: 14),
                  ),
                ),
                Text(
                  '$pets ${pets == 1 ? 'animal' : 'animais'}',
                  style: TextStyle(
                    color: p.faint,
                    fontSize: 13,
                    fontFeatures: kTabular,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
            Text(
              title,
              style: TextStyle(
                color: p.ink,
                fontSize: 22,
                height: 1.25,
                fontWeight: FontWeight.w500,
                fontFeatures: kTabular,
              ),
            ),
            const SizedBox(height: Space.m),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: progress),
                duration: Motion.base,
                curve: Motion.curve,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: p.raised,
                  color: p.primary,
                ),
              ),
            ),
            const SizedBox(height: Space.xs),
            Text(
              total == 0
                  ? 'Não há lembretes agendados para hoje'
                  : '$done de $total ${total == 1 ? 'lembrete concluído' : 'lembretes concluídos'}',
              style: TextStyle(color: p.muted, fontSize: 13, fontFeatures: kTabular),
            ),
          ],
        ),
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 17),
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.m),
        child: Row(
          children: [
            Icon(icon, size: 20, color: p.faint),
            const SizedBox(width: Space.s),
            Expanded(
              child: Text(text, style: TextStyle(color: p.muted, height: 1.45)),
            ),
          ],
        ),
      ),
    );
  }
}
