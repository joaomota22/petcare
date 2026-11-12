import 'package:flutter/material.dart';

import 'dashboard_tab.dart';
import 'pets_tab.dart';
import 'reminders_tab.dart';

/// Contentor principal com a BottomNavigationBar (Início, Animais, Lembretes).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // IndexedStack mantém os separadores vivos. Cada um recarrega ao ouvir DatabaseService.changes.
  static const _pages = [DashboardTab(), PetsTab(), RemindersTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Animais',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_active_rounded),
            label: 'Lembretes',
          ),
        ],
      ),
    );
  }
}
