import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../models/reminder.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/reminder_service.dart';
import '../utils/formatters.dart';
import '../widgets/reminder_tile.dart';
import 'login_screen.dart';

/// Dashboard: saudação, resumo do dia e próximos lembretes.
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
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
                  children: [
                    _Header(onLogout: _logout),
                    const SizedBox(height: 24),
                    _HeroCard(
                      done: doneToday,
                      total: total,
                      pets: _petCount,
                      date: now,
                    ),
                    const SizedBox(height: 28),
                    const _SectionTitle('Hoje'),
                    const SizedBox(height: 14),
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
                    const SizedBox(height: 22),
                    const _SectionTitle('Próximos lembretes'),
                    const SizedBox(height: 14),
                    if (_upcoming.isEmpty)
                      const _HintCard(
                        icon: Icons.notifications_none_rounded,
                        text:
                            'Sem lembretes futuros. Crie um no separador "Lembretes".',
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

class _Header extends StatelessWidget {
  const _Header({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${greetingFor(now)}!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: context.palette.ink,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatLongDate(now),
                style: TextStyle(color: context.palette.muted, fontSize: 14),
              ),
            ],
          ),
        ),
        Material(
          color: context.palette.surface,
          shape: const CircleBorder(),
          elevation: 2,
          shadowColor: const Color(0x1A2A2766),
          child: IconButton(
            icon: Icon(Icons.logout_rounded, color: context.palette.primary),
            tooltip: 'Sair',
            onPressed: onLogout,
          ),
        ),
      ],
    );
  }
}

/// Cartão de destaque escuro com o progresso do dia (estilo "My tasks").
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.done,
    required this.total,
    required this.pets,
    required this.date,
  });

  final int done;
  final int total;
  final int pets;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : done / total;
    final pending = total - done;
    final title = total == 0
        ? 'Dia tranquilo'
        : pending == 0
            ? 'Tudo concluído'
            : pending == 1
                ? '1 cuidado por fazer'
                : '$pending cuidados por fazer';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: context.palette.brandGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: context.palette.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resumo de hoje',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$pets ${pets == 1 ? 'animal' : 'animais'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    color: context.palette.success,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                total == 0 ? '—' : '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            total == 0
                ? 'Não há lembretes agendados para hoje.'
                : '$done de $total lembretes concluídos',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
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
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: context.palette.ink,
        letterSpacing: -0.4,
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.palette.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: context.palette.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: context.palette.muted, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
