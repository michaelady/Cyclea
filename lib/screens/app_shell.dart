import 'package:cyclea/screens/calendar_screen.dart';
import 'package:cyclea/screens/home_screen.dart';
import 'package:cyclea/screens/insights_screen.dart';
import 'package:cyclea/screens/settings_screen.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_icons.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  static const _pages = [
    HomeScreen(),
    CalendarScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: CycleaIcon(CycleaGlyph.blossom, semanticLabel: 'Home'),
      selectedIcon: CycleaIcon(
        CycleaGlyph.blossom,
        filled: true,
        semanticLabel: 'Home',
      ),
      label: 'Home',
    ),
    NavigationDestination(
      icon: CycleaIcon(CycleaGlyph.calendarBloom, semanticLabel: 'Calendar'),
      selectedIcon: CycleaIcon(
        CycleaGlyph.calendarBloom,
        filled: true,
        semanticLabel: 'Calendar',
      ),
      label: 'Calendar',
    ),
    NavigationDestination(
      icon: CycleaIcon(CycleaGlyph.sprout, semanticLabel: 'Insights'),
      selectedIcon: CycleaIcon(
        CycleaGlyph.sprout,
        filled: true,
        semanticLabel: 'Insights',
      ),
      label: 'Insights',
    ),
    NavigationDestination(
      icon: CycleaIcon(CycleaGlyph.moon, semanticLabel: 'Settings'),
      selectedIcon: CycleaIcon(
        CycleaGlyph.moon,
        filled: true,
        semanticLabel: 'Settings',
      ),
      label: 'Settings',
    ),
  ];

  static const _rail = [
    NavigationRailDestination(
      icon: CycleaIcon(CycleaGlyph.blossom),
      selectedIcon: CycleaIcon(CycleaGlyph.blossom, filled: true),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: CycleaIcon(CycleaGlyph.calendarBloom),
      selectedIcon: CycleaIcon(CycleaGlyph.calendarBloom, filled: true),
      label: Text('Calendar'),
    ),
    NavigationRailDestination(
      icon: CycleaIcon(CycleaGlyph.sprout),
      selectedIcon: CycleaIcon(CycleaGlyph.sprout, filled: true),
      label: Text('Insights'),
    ),
    NavigationRailDestination(
      icon: CycleaIcon(CycleaGlyph.moon),
      selectedIcon: CycleaIcon(CycleaGlyph.moon, filled: true),
      label: Text('Settings'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final index = controller.tabIndex;
    final wide = isWideLayout(context);
    // Swap tabs immediately. A fade leaves the incoming page at opacity 0,
    // which drops the first tap during the transition.
    final body = _pages[index];
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: controller.setTabIndex,
              labelType: NavigationRailLabelType.all,
              destinations: _rail,
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
        selectedIndex: index,
        destinations: _destinations,
        onDestinationSelected: controller.setTabIndex,
      ),
    );
  }
}
