import 'package:flutter/material.dart';

import '../../application/setup_controller.dart';
import '../app_routes.dart';

final class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final SetupController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.visibility_outlined, size: 64),
                const SizedBox(height: 24),
                Text(
                  'IMPOSTER',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displaySmall
                      ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 5),
                ),
                const SizedBox(height: 10),
                Text(
                  'One phone. One hidden role. Trust nobody.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 44),
                FilledButton.icon(
                  key: const Key('new-game-button'),
                  onPressed: () {
                    controller.startNewGame();
                    Navigator.pushNamed(context, AppRoutes.players);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('New Game'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(58),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('How to Play'),
                      content: const Text(
                        'Everyone except the imposter receives the same secret word. Take turns giving clues, then discuss and vote outside the app. The imposter tries to blend in.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('How to Play'),
                ),
                TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Settings'),
                      content: const Text(
                        'Imposter works offline. Recent words are remembered on this device to help reduce repeats.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Settings'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
