import 'package:cyclea/screens/calendar_screen.dart';
import 'package:cyclea/screens/home_screen.dart';
import 'package:cyclea/screens/insights_screen.dart';
import 'package:cyclea/screens/settings_screen.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    CalendarScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.spa_outlined), selectedIcon: Icon(Icons.spa), label: 'Home'),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'Calendar',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Insights',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = isWideLayout(context);
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
    );
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (value) => setState(() => _index = value),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.spa_outlined), label: Text('Home')),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: Text('Calendar'),
                ),
                NavigationRailDestination(icon: Icon(Icons.insights_outlined), label: Text('Insights')),
                NavigationRailDestination(icon: Icon(Icons.settings_outlined), label: Text('Settings')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: _destinations,
        onDestinationSelected: (value) => setState(() => _index = value),
      ),
    );
  }
}
