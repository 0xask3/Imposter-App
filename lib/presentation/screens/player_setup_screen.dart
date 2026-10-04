import 'package:flutter/material.dart';

import '../../application/setup_controller.dart';
import '../../domain/models/player.dart';
import '../../domain/validation/game_validator.dart';
import '../app_routes.dart';

final class PlayerSetupScreen extends StatelessWidget {
  const PlayerSetupScreen({super.key, required this.controller});

  final SetupController controller;

  Future<void> _editPlayer(BuildContext context, {Player? player}) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _PlayerNameDialog(controller: controller, player: player),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final players = controller.players;
      final canAdd = players.length < GameValidator.maxPlayers;
      return Scaffold(
        appBar: AppBar(title: const Text('Players'), centerTitle: true),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  'Add 3–20 players, then arrange the list in phone-passing order.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: players.isEmpty
                    ? const Center(
                        child: Text('Add your first player to begin.'),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: players.length,
                        onReorderItem: (oldIndex, newIndex) =>
                            controller.reorderPlayers(
                              oldIndex,
                              newIndex > oldIndex ? newIndex + 1 : newIndex,
                            ),
                        buildDefaultDragHandles: false,
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return Card(
                            key: ValueKey(player.id),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(player.name),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit ${player.name}',
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () =>
                                        _editPlayer(context, player: player),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove ${player.name}',
                                    icon: const Icon(Icons.close),
                                    onPressed: () =>
                                        controller.removePlayer(player.id),
                                  ),
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Icon(Icons.drag_handle),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('add-player-button'),
                      onPressed: canAdd ? () => _editPlayer(context) : null,
                      icon: const Icon(Icons.add),
                      label: Text(
                        canAdd ? 'Add Player' : 'Maximum of 20 players',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      key: const Key('continue-to-settings-button'),
                      onPressed: controller.canContinue
                          ? () =>
                                Navigator.pushNamed(context, AppRoutes.settings)
                          : null,
                      child: const Text('Continue'),
                    ),
                    if (!controller.canContinue)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Add at least 3 players to continue.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

final class _PlayerNameDialog extends StatefulWidget {
  const _PlayerNameDialog({required this.controller, this.player});

  final SetupController controller;
  final Player? player;

  @override
  State<_PlayerNameDialog> createState() => _PlayerNameDialogState();
}

final class _PlayerNameDialogState extends State<_PlayerNameDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.player?.name ?? '',
  );
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final issue = widget.controller.savePlayer(
      id: widget.player?.id,
      name: _nameController.text,
    );
    if (issue == null) {
      Navigator.pop(context);
    } else {
      setState(() => _error = issue.message);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.player == null ? 'Add player' : 'Edit player'),
    content: TextField(
      key: const Key('player-name-field'),
      controller: _nameController,
      autofocus: true,
      maxLength: GameValidator.maxPlayerNameLength,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _save(),
      decoration: InputDecoration(labelText: 'Player name', errorText: _error),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(onPressed: _save, child: const Text('Save')),
    ],
  );
}
