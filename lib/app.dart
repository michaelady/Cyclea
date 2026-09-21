import 'package:cyclea/screens/app_shell.dart';
import 'package:cyclea/screens/welcome_screen.dart';
import 'package:cyclea/state/cycle_controller.dart';
import 'package:cyclea/theme/cyclea_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CycleaApp extends StatelessWidget {
  const CycleaApp({super.key, required this.controller});

  final CycleController controller;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: controller,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return MaterialApp(
            title: 'Cyclea',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: const [Locale('en')],
            theme: CycleaTheme.light(),
            darkTheme: CycleaTheme.dark(),
            themeMode: controller.themeMode,
            home: controller.loading
                ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                : controller.disclaimerAccepted
                ? const AppShell()
                : const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
