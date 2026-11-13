import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../design/tokens.dart';
import 'dashboard_tab.dart';
import 'pets_tab.dart';
import 'reminders_tab.dart';

/// Contentor principal com uma barra de navegação flutuante (Início, Animais, Lembretes).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // IndexedStack mantém os separadores vivos. Cada um recarrega ao ouvir DatabaseService.changes.
  static const _pages = [DashboardTab(), PetsTab(), RemindersTab()];

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Início'),
    _NavItem(icon: Icons.pets_outlined, activeIcon: Icons.pets, label: 'Animais'),
    _NavItem(
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_active_rounded,
      label: 'Lembretes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.l, 0, Space.l, Space.s),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: Space.xs),
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(Radii.xxl),
              boxShadow: context.palette.softShadow,
            ),
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: _items[i],
                      selected: i == _index,
                      onTap: () => setState(() => _index = i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tint = selected ? p.primary : p.muted;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cápsula do ícone: fundo suave quando ativo, animada.
            AnimatedContainer(
              duration: Motion.base,
              curve: Motion.curve,
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? p.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.l),
              ),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                size: 22,
                color: tint,
              ),
            ),
            const SizedBox(height: Space.xxs),
            AnimatedDefaultTextStyle(
              duration: Motion.fast,
              curve: Motion.curve,
              style: TextStyle(
                fontSize: 12,
                height: 1.1,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: tint,
              ),
              child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
