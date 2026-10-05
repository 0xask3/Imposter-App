import 'package:flutter/foundation.dart' hide Category;

import '../data/builtin/builtin_content.dart';
import '../data/local/shared_preferences_word_history_repository.dart';
import '../domain/models/category.dart';
import '../domain/models/difficulty.dart';
import '../domain/models/game_issue.dart';
import '../domain/models/game_settings.dart';
import '../domain/models/player.dart';
import '../domain/models/round.dart';
import '../domain/random/random_source.dart';
import '../domain/random/system_random_source.dart';
import '../domain/services/round_generation_result.dart';
import '../domain/services/round_generator.dart';
import '../domain/services/word_history_repository.dart';
import '../domain/validation/game_validator.dart';

final class SetupController extends ChangeNotifier {
  SetupController({RandomSource? random, WordHistoryRepository? wordHistory})
    : _roundGenerator = RoundGenerator(
        random: random ?? SystemRandomSource(),
        wordHistory: wordHistory ?? SharedPreferencesWordHistoryRepository(),
      );

  final RoundGenerator _roundGenerator;
  final List<Player> _players = [];
  final Set<String> _selectedCategoryIds = builtinCategories
      .map((category) => category.id)
      .toSet();

  int _nextPlayerId = 1;
  int? _imposterCount;
  DifficultyFilter _difficulty = DifficultyFilter.any;
  bool _hintsEnabled = false;
  Round? _currentRound;
  int _revealIndex = 0;
  bool _identityConfirmed = false;
  bool _payloadVisible = false;
  bool _revealComplete = false;

  List<Player> get players => List.unmodifiable(_players);
  List<Category> get categories => builtinCategories;
  Set<String> get selectedCategoryIds => Set.unmodifiable(_selectedCategoryIds);
  DifficultyFilter get difficulty => _difficulty;
  bool get hintsEnabled => _hintsEnabled;
  Round? get currentRound => _currentRound;
  bool get identityConfirmed => _identityConfirmed;
  bool get payloadVisible => _payloadVisible;
  bool get revealComplete => _revealComplete;
  Player? get startingPlayer {
    final round = _currentRound;
    if (round == null) return null;
    for (final player in round.players) {
      if (player.id == round.startingPlayerId) return player;
    }
    return null;
  }

  List<Player> get imposterPlayers {
    final round = _currentRound;
    if (round == null) return const [];
    return List.unmodifiable(
      round.players.where((player) => round.imposterIds.contains(player.id)),
    );
  }

  String? get secretWord => _currentRound?.secretWord;
  Player? get currentRevealPlayer {
    final round = _currentRound;
    if (round == null ||
        _revealComplete ||
        _revealIndex >= round.phoneOrder.length) {
      return null;
    }
    final playerId = round.phoneOrder[_revealIndex];
    for (final player in round.players) {
      if (player.id == playerId) return player;
    }
    return null;
  }

  int get imposterCount {
    final maximum = (_players.length - 1).clamp(1, 19);
    return (_imposterCount ?? (_players.length >= 8 ? 2 : 1)).clamp(1, maximum);
  }

  bool get canContinue =>
      _players.length >= GameValidator.minPlayers &&
      _players.length <= GameValidator.maxPlayers &&
      _players.every((player) => playerNameIssue(player.id) == null);

  GameSettings get gameSettings => GameSettings(
    imposterCount: imposterCount,
    selectedCategoryIds: _selectedCategoryIds,
    difficulty: _difficulty,
    hintsEnabled: _hintsEnabled,
  );

  GameIssue? playerNameIssue(String id) {
    final playerIndex = _players.indexWhere((player) => player.id == id);
    if (playerIndex == -1) return null;
    final issues = GameValidator.validatePlayerName(
      _players[playerIndex].name,
      existingPlayers: _players,
      excludingPlayerId: id,
    );
    return issues.isEmpty ? null : issues.first;
  }

  void addPlayerDraft() {
    if (_players.length >= GameValidator.maxPlayers) return;
    _players.add(Player(id: 'player-${_nextPlayerId++}', name: ''));
    notifyListeners();
  }

  void updatePlayerDraft(String id, String name) {
    final playerIndex = _players.indexWhere((player) => player.id == id);
    if (playerIndex == -1) return;
    _players[playerIndex] = Player(id: id, name: name);
    notifyListeners();
  }

  GameIssue? savePlayer({String? id, required String name}) {
    final validationIssues = GameValidator.validatePlayerName(
      name,
      existingPlayers: _players,
      excludingPlayerId: id,
    );
    if (validationIssues.isNotEmpty) return validationIssues.first;

    if (id == null) {
      if (_players.length >= GameValidator.maxPlayers) {
        return const GameIssue(
          GameIssueCode.playerCountOutOfRange,
          'A game can have at most 20 players.',
        );
      }
      _players.add(Player(id: 'player-${_nextPlayerId++}', name: name));
    } else {
      final playerIndex = _players.indexWhere((player) => player.id == id);
      if (playerIndex == -1) return null;
      _players[playerIndex] = Player(id: id, name: name);
    }
    notifyListeners();
    return null;
  }

  void removePlayer(String id) {
    _players.removeWhere((player) => player.id == id);
    notifyListeners();
  }

  void reorderPlayers(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _players.length) return;
    if (newIndex < 0 || newIndex > _players.length) return;
    if (newIndex > oldIndex) newIndex--;
    final player = _players.removeAt(oldIndex);
    _players.insert(newIndex, player);
    notifyListeners();
  }

  void selectImposterCount(int count) {
    _imposterCount = count;
    notifyListeners();
  }

  void toggleCategory(String categoryId, bool selected) {
    if (selected) {
      _selectedCategoryIds.add(categoryId);
    } else {
      _selectedCategoryIds.remove(categoryId);
    }
    notifyListeners();
  }

  void selectAllCategories() {
    _selectedCategoryIds
      ..clear()
      ..addAll(builtinCategories.map((category) => category.id));
    notifyListeners();
  }

  void clearAllCategories() {
    _selectedCategoryIds.clear();
    notifyListeners();
  }

  void selectDifficulty(DifficultyFilter difficulty) {
    _difficulty = difficulty;
    notifyListeners();
  }

  void setHintsEnabled(bool enabled) {
    _hintsEnabled = enabled;
    notifyListeners();
  }

  Future<RoundGenerationResult> createRound() async {
    final result = await _roundGenerator.createRound(
      players: _players,
      categories: builtinCategories,
      words: builtinWords,
      settings: gameSettings,
    );
    switch (result) {
      case RoundCreated(:final round):
        _currentRound = round;
        _resetRevealFlow();
      case RoundRejected():
        if (_currentRound == null) _resetRevealFlow();
    }
    notifyListeners();
    return result;
  }

  void confirmCurrentPlayer() {
    if (_currentRound == null ||
        _revealComplete ||
        currentRevealPlayer == null) {
      return;
    }
    _identityConfirmed = true;
    _payloadVisible = false;
    notifyListeners();
  }

  void revealCurrentPayload() {
    if (_currentRound == null ||
        _revealComplete ||
        !_identityConfirmed ||
        currentRevealPlayer == null) {
      return;
    }
    _payloadVisible = true;
    notifyListeners();
  }

  void hideAndAdvance() {
    final round = _currentRound;
    if (round == null || _revealComplete || !_payloadVisible) return;

    _payloadVisible = false;
    _identityConfirmed = false;
    if (_revealIndex == round.phoneOrder.length - 1) {
      _revealComplete = true;
    } else {
      _revealIndex++;
    }
    notifyListeners();
  }

  void handleRevealInterruption() {
    if (_currentRound == null || _revealComplete) return;
    if (!_identityConfirmed && !_payloadVisible) return;
    _payloadVisible = false;
    _identityConfirmed = false;
    notifyListeners();
  }

  void clearCurrentRound() {
    _currentRound = null;
    _resetRevealFlow();
    notifyListeners();
  }

  void _resetRevealFlow() {
    _revealIndex = 0;
    _identityConfirmed = false;
    _payloadVisible = false;
    _revealComplete = false;
  }

  void startNewGame() {
    _currentRound = null;
    _resetRevealFlow();
    while (_players.length < GameValidator.minPlayers) {
      _players.add(Player(id: 'player-${_nextPlayerId++}', name: ''));
    }
    notifyListeners();
  }
}
