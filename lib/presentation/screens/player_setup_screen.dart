import 'package:flutter/material.dart';

import '../../application/setup_controller.dart';
import '../../domain/models/player.dart';
import '../../domain/validation/game_validator.dart';
import '../app_routes.dart';

final class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key, required this.controller});

  final SetupController controller;

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

final class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _editedPlayerIds = {};

  SetupController get _controller => widget.controller;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_controller.players.length >= GameValidator.maxPlayers) return;
    _controller.addPlayerDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _reorderPlayers(int oldIndex, int newIndex, int playerCount) {
    if (oldIndex >= playerCount) return;
    final finalIndex = newIndex.clamp(0, playerCount - 1);
    final controllerIndex = finalIndex > oldIndex ? finalIndex + 1 : finalIndex;
    _controller.reorderPlayers(oldIndex, controllerIndex);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final players = _controller.players;
      final atLimit = players.length >= GameValidator.maxPlayers;
      final allNamesValid = players.every(
        (player) => _controller.playerNameIssue(player.id) == null,
      );
      final statusMessage = players.length < GameValidator.minPlayers
          ? 'Minimum 3 players to start'
          : !allNamesValid
          ? 'Enter a unique name for each player'
          : 'Players can be reordered with the drag handles';

      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Players'),
          centerTitle: true,
          actions: [
            IconButton(
              key: const Key('player-setup-settings-button'),
              tooltip: 'Game settings',
              onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary,
                        child: const Icon(Icons.groups_rounded),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BUILD YOUR LINEUP',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${players.length} of ${GameValidator.maxPlayers} players',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.edit_note_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  key: const Key('player-list'),
                  scrollController: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  itemCount: players.length + 1,
                  buildDefaultDragHandles: false,
                  onReorderItem: (oldIndex, newIndex) =>
                      _reorderPlayers(oldIndex, newIndex, players.length),
                  itemBuilder: (context, index) {
                    if (index == players.length) {
                      return _buildAddPlayerRow(atLimit);
                    }
                    return _buildPlayerRow(players[index], index);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      key: const Key('continue-to-settings-button'),
                      onPressed: _controller.canContinue
                          ? () =>
                                Navigator.pushNamed(context, AppRoutes.settings)
                          : null,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          players.length < GameValidator.minPlayers ||
                                  !allNamesValid
                              ? Icons.info_outline_rounded
                              : Icons.drag_indicator_rounded,
                          size: 17,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            statusMessage,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ],
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

  Widget _buildPlayerRow(Player player, int index) {
    final issue = _controller.playerNameIssue(player.id);
    final showError =
        _editedPlayerIds.contains(player.id) || player.name.isNotEmpty;
    return Padding(
      key: ValueKey(player.id),
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: Key('player-name-field-${player.id}'),
                  initialValue: player.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  maxLength: GameValidator.maxPlayerNameLength,
                  decoration: InputDecoration(
                    hintText: "Player ${index + 1}'s name",
                    errorText: showError ? issue?.message : null,
                    counterText: '',
                    isDense: true,
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 15,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (name) {
                    _editedPlayerIds.add(player.id);
                    _controller.updatePlayerDraft(player.id, name);
                  },
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Remove player ${index + 1}',
                onPressed: () {
                  _editedPlayerIds.remove(player.id);
                  _controller.removePlayer(player.id);
                },
                icon: const Icon(Icons.close_rounded, size: 19),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddPlayerRow(bool atLimit) => Padding(
    key: const ValueKey('add-player-row'),
    padding: const EdgeInsets.only(top: 14, bottom: 10),
    child: OutlinedButton.icon(
      key: const Key('add-player-button'),
      onPressed: atLimit ? null : _addPlayer,
      icon: const Icon(Icons.add),
      label: Text(atLimit ? 'Maximum players reached' : 'Add Player'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        side: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: Theme.of(context).textTheme.titleMedium
            ?.copyWith(fontWeight: FontWeight.w800),
      ),
    ),
  );
}
