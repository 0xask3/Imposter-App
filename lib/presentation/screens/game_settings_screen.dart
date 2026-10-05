import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/setup_controller.dart';
import '../../domain/models/difficulty.dart';
import '../../domain/services/round_generation_result.dart';
import '../app_routes.dart';

const _categoryIcons = <String, IconData>{
  'pets': Icons.pets_outlined,
  'restaurant': Icons.restaurant_outlined,
  'forest': Icons.park_outlined,
  'inventory': Icons.inventory_2_outlined,
  'cafe': Icons.local_cafe_outlined,
  'public': Icons.public,
  'city': Icons.location_city_outlined,
  'sports': Icons.sports_soccer_outlined,
  'devices': Icons.devices_outlined,
  'vehicle': Icons.directions_car_outlined,
  'work': Icons.work_outline,
  'music': Icons.music_note_outlined,
};

enum _CategorySelectionAction { all, none }

final class GameSettingsScreen extends StatefulWidget {
  const GameSettingsScreen({super.key, required this.controller});

  final SetupController controller;

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

final class _GameSettingsScreenState extends State<GameSettingsScreen> {
  bool _starting = false;
  bool _showScrollHint = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_updateScrollHint);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollHint());
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollHint)
      ..dispose();
    super.dispose();
  }

  void _updateScrollHint() {
    if (!mounted || !_scrollController.hasClients) return;
    final hasMoreBelow = _scrollController.position.extentAfter > 24;
    if (hasMoreBelow != _showScrollHint) {
      setState(() => _showScrollHint = hasMoreBelow);
    }
  }

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

  Widget _sectionHeading(
    BuildContext context,
    IconData icon,
    String title, {
    String? subtitle,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle case final text?) ...[
              const SizedBox(height: 4),
              Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final controller = widget.controller;
      final maxImposters = controller.players.length - 1;
      final imposterCount = controller.imposterCount.clamp(1, maxImposters);
      final categorySelection =
          controller.selectedCategoryIds.length == controller.categories.length
          ? {_CategorySelectionAction.all}
          : controller.selectedCategoryIds.isEmpty
          ? {_CategorySelectionAction.none}
          : <_CategorySelectionAction>{};
      return Scaffold(
        appBar: AppBar(title: const Text('Game Settings'), centerTitle: true),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: FilledButton.icon(
              key: const Key('start-game-button'),
              onPressed: _starting || !controller.canContinue
                  ? null
                  : _startGame,
              icon: _starting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_arrow_rounded),
              label: Text(_starting ? 'Preparing…' : 'Start Game'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _updateScrollHint(),
              );
              return false;
            },
            child: Stack(
              children: [
                ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 64),
                  children: [
                    if (!controller.canContinue)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Enter at least 3 unique player names before starting.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeading(
                              context,
                              Icons.theater_comedy_outlined,
                              'Imposters',
                              subtitle: 'Choose how many players start without the word.',
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              key: const Key('imposter-count-dropdown'),
                              initialValue: imposterCount,
                              decoration: const InputDecoration(
                                labelText: 'Count',
                              ),
                              items: [
                                for (
                                  var count = 1;
                                  count <= maxImposters;
                                  count++
                                )
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
                      child: SwitchListTile(
                        key: const Key('hints-toggle'),
                        secondary: Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: const Text('Imposter hint'),
                        subtitle: const Text(
                          'Give the imposter a clue, not the word.',
                        ),
                        value: controller.hintsEnabled,
                        onChanged: controller.setHintsEnabled,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeading(
                              context,
                              Icons.grid_view_rounded,
                              'Categories',
                              subtitle: 'Choose the topics for this round.',
                            ),
                            const SizedBox(height: 10),
                            SegmentedButton<_CategorySelectionAction>(
                              key: const Key('category-selection-actions'),
                              showSelectedIcon: false,
                              emptySelectionAllowed: true,
                              segments: const [
                                ButtonSegment(
                                  value: _CategorySelectionAction.all,
                                  icon: Icon(Icons.select_all_rounded),
                                  label: Text('Select all'),
                                ),
                                ButtonSegment(
                                  value: _CategorySelectionAction.none,
                                  icon: Icon(Icons.deselect_rounded),
                                  label: Text('Clear all'),
                                ),
                              ],
                              selected: categorySelection,
                              onSelectionChanged: (selection) {
                                if (selection.isEmpty) return;
                                switch (selection.first) {
                                  case _CategorySelectionAction.all:
                                    controller.selectAllCategories();
                                  case _CategorySelectionAction.none:
                                    controller.clearAllCategories();
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                for (final category in controller.categories)
                                  FilterChip(
                                    key: Key('category-${category.id}'),
                                    label: Text(category.name),
                                    avatar: Icon(
                                      _categoryIcons[category.iconKey] ??
                                          Icons.category_outlined,
                                      size: 18,
                                    ),
                                    showCheckmark: false,
                                    selected: controller.selectedCategoryIds
                                        .contains(category.id),
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    checkmarkColor: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
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
                            _sectionHeading(
                              context,
                              Icons.bolt_outlined,
                              'Difficulty',
                              subtitle: 'Filters both the secret word and its one-word hint.',
                            ),
                            const SizedBox(height: 10),
                            SegmentedButton<DifficultyFilter>(
                              key: const Key('difficulty-selector'),
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment(
                                  value: DifficultyFilter.any,
                                  label: Text('Any'),
                                ),
                                ButtonSegment(
                                  value: DifficultyFilter.easy,
                                  label: Text(
                                    'Easy',
                                    maxLines: 1,
                                    softWrap: false,
                                  ),
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
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedSlide(
                        offset: _showScrollHint
                            ? Offset.zero
                            : const Offset(0, 0.35),
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: AnimatedOpacity(
                          opacity: _showScrollHint ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHigh
                                  .withValues(alpha: 0.96),
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Scroll for more',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
