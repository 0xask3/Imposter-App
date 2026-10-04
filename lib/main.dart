import 'package:flutter/material.dart';

import 'application/setup_controller.dart';
import 'presentation/app_routes.dart';
import 'presentation/screens/game_settings_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/player_setup_screen.dart';

void main() {
  runApp(ImposterApp(controller: SetupController()));
}

final class ImposterApp extends StatelessWidget {
  const ImposterApp({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB7F36B);
    return MaterialApp(
      title: 'Imposter',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF16191C),
        ),
        scaffoldBackgroundColor: const Color(0xFF101214),
        cardTheme: const CardThemeData(
          color: Color(0xFF1B1F22),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => HomeScreen(controller: controller),
        AppRoutes.players: (_) => PlayerSetupScreen(controller: controller),
        AppRoutes.settings: (_) => GameSettingsScreen(controller: controller),
      },
    );
  }
}
