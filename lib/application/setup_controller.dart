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

  List<Player> get players => List.unmodifiable(_players);
  List<Category> get categories => builtinCategories;
  Set<String> get selectedCategoryIds => Set.unmodifiable(_selectedCategoryIds);
  DifficultyFilter get difficulty => _difficulty;
  bool get hintsEnabled => _hintsEnabled;
  Round? get currentRound => _currentRound;

  int get imposterCount {
    final maximum = (_players.length - 1).clamp(1, 19);
    return (_imposterCount ?? (_players.length >= 8 ? 2 : 1)).clamp(1, maximum);
  }

  bool get canContinue =>
      _players.length >= GameValidator.minPlayers &&
      _players.length <= GameValidator.maxPlayers;

  GameSettings get gameSettings => GameSettings(
    imposterCount: imposterCount,
    selectedCategoryIds: _selectedCategoryIds,
    difficulty: _difficulty,
    hintsEnabled: _hintsEnabled,
  );

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
    _currentRound = switch (result) {
      RoundCreated(:final round) => round,
      RoundRejected() => null,
    };
    notifyListeners();
    return result;
  }

  void startNewGame() {
    _players.clear();
    _selectedCategoryIds
      ..clear()
      ..addAll(builtinCategories.map((category) => category.id));
    _imposterCount = null;
    _difficulty = DifficultyFilter.any;
    _hintsEnabled = false;
    _currentRound = null;
    notifyListeners();
  }
}
