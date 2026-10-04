import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/setup_controller.dart';
import '../../domain/models/difficulty.dart';
import '../../domain/services/round_generation_result.dart';
import '../app_routes.dart';

final class GameSettingsScreen extends StatefulWidget {
  const GameSettingsScreen({super.key, required this.controller});

  final SetupController controller;

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

final class _GameSettingsScreenState extends State<GameSettingsScreen> {
  bool _starting = false;

  Future<void> _startGame() async {
    setState(() => _starting = true);
    final result = await widget.controller.createRound();
    if (!mounted) return;
    setState(() => _starting = false);
    switch (result) {
      case RoundCreated():
        unawaited(Navigator.pushNamed<void>(context, AppRoutes.reveal));
      case RoundRejected(:final issues):
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Could not start'),
            content: Text(issues.first.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Review settings'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final maxImposters = controller.players.length - 1;
      final imposterCount = controller.imposterCount.clamp(1, maxImposters);
      return Scaffold(
        appBar: AppBar(title: const Text('Game Settings'), centerTitle: true),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                '${controller.players.length} players',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Imposters',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Choose how many players start without the word.',
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        key: const Key('imposter-count-dropdown'),
                        initialValue: imposterCount,
                        decoration: const InputDecoration(labelText: 'Count'),
                        items: [
                          for (var count = 1; count <= maxImposters; count++)
                            DropdownMenuItem(
                              value: count,
                              child: Text(
                                '$count ${count == 1 ? 'imposter' : 'imposters'}',
                              ),
                            ),
                        ],
                        onChanged: (count) {
                          if (count != null) {
                            controller.selectImposterCount(count);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Categories',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      const Text('Pick at least one category.'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final category in controller.categories)
                            FilterChip(
                              key: Key('category-${category.id}'),
                              label: Text(category.name),
                              selected: controller.selectedCategoryIds.contains(
                                category.id,
                              ),
                              onSelected: (selected) => controller
                                  .toggleCategory(category.id, selected),
                            ),
                        ],
                      ),
                      if (controller.selectedCategoryIds.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Select at least one category to continue.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Difficulty',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<DifficultyFilter>(
                        key: const Key('difficulty-selector'),
                        segments: const [
                          ButtonSegment(
                            value: DifficultyFilter.any,
                            label: Text('Any'),
                          ),
                          ButtonSegment(
                            value: DifficultyFilter.easy,
                            label: Text('Easy'),
                          ),
                          ButtonSegment(
                            value: DifficultyFilter.medium,
                            label: Text('Med'),
                          ),
                          ButtonSegment(
                            value: DifficultyFilter.hard,
                            label: Text('Hard'),
                          ),
                        ],
                        selected: {controller.difficulty},
                        onSelectionChanged: (selection) =>
                            controller.selectDifficulty(selection.first),
                      ),
                    ],
                  ),
                ),
              ),
              SwitchListTile(
                key: const Key('hints-toggle'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                title: const Text('Imposter hint'),
                subtitle: const Text('Give the imposter a clue, not the word.'),
                value: controller.hintsEnabled,
                onChanged: controller.setHintsEnabled,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('start-game-button'),
                onPressed: _starting ? null : _startGame,
                icon: _starting
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_starting ? 'Preparing…' : 'Start Game'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
