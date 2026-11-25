import 'package:flutter/material.dart';

import '../app_theme.dart';
import 'dashboard_tab.dart';
import 'pets_tab.dart';
import 'reminders_tab.dart';

/// Contentor principal com a barra de navegação (Início, Animais, Lembretes).
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
    _NavItem(icon: Icons.home_outlined, label: 'Início'),
    _NavItem(icon: Icons.pets_outlined, label: 'Animais'),
    _NavItem(icon: Icons.notifications_none, label: 'Lembretes'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
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
  const _NavItem({required this.icon, required this.label});

  final IconData icon;
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
    final tint = selected ? p.primary : p.faint;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.curve,
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? p.primarySoft : Colors.transparent,
                borderRadius: BorderRadius.circular(Radii.s),
              ),
              child: Icon(item.icon, size: 20, color: tint),
            ),
            const SizedBox(height: Space.xxs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w500,
                color: tint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
