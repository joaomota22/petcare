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

  // IndexedStack mantém os ecrãs vivos; cada um recarrega ao ouvir DatabaseService.changes.
  static const _pages = [DashboardTab(), PetsTab(), RemindersTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Animais',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none_rounded),
            activeIcon: Icon(Icons.notifications_active_rounded),
            label: 'Lembretes',
          ),
        ],
      ),
    );
  }
}
