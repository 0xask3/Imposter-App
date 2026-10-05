import 'package:flutter/material.dart';

import 'application/setup_controller.dart';
import 'presentation/app_routes.dart';
import 'presentation/screens/game_settings_screen.dart';
import 'presentation/screens/discussion_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/player_setup_screen.dart';
import 'presentation/screens/results_screen.dart';
import 'presentation/screens/reveal_flow_screen.dart';

void main() {
  runApp(ImposterApp(controller: SetupController()));
}

final class ImposterApp extends StatelessWidget {
  const ImposterApp({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFB7F36B);
    final pageBuilders = <String, WidgetBuilder>{
      AppRoutes.home: (_) => HomeScreen(controller: controller),
      AppRoutes.players: (_) => PlayerSetupScreen(controller: controller),
      AppRoutes.settings: (_) => GameSettingsScreen(controller: controller),
      AppRoutes.reveal: (_) => RevealFlowScreen(controller: controller),
      AppRoutes.discussion: (_) => DiscussionScreen(controller: controller),
      AppRoutes.results: (_) => ResultsScreen(controller: controller),
    };
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    return MaterialApp(
      title: 'Imposter',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF1D2727),
        ),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF242E2D),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: AppRoutes.home,
      builder: (context, child) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A3028),
              Color(0xFF1C252D),
              Color(0xFF29212D),
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      ),
      onGenerateRoute: (settings) {
        final pageBuilder = pageBuilders[settings.name];
        if (pageBuilder == null) return null;
        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              pageBuilder(context),
          transitionDuration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 260),
          reverseTransitionDuration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 210),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final position =
                Tween<Offset>(
                  begin: const Offset(.04, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: position, child: child),
            );
          },
        );
      },
    );
  }
}
