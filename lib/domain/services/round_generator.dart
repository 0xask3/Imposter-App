import '../models/category.dart';
import '../models/difficulty.dart';
import '../models/game_issue.dart';
import '../models/game_settings.dart';
import '../models/player.dart';
import '../models/round.dart';
import '../models/word_entry.dart';
import '../random/random_source.dart';
import '../validation/game_validator.dart';
import 'content_validator.dart';
import 'round_generation_result.dart';
import 'word_history_repository.dart';

final class RoundGenerator {
  RoundGenerator({
    required this.random,
    required this.wordHistory,
    this.recentWordWindow = 20,
  }) {
    if (recentWordWindow < 1) {
      throw ArgumentError.value(
        recentWordWindow,
        'recentWordWindow',
        'Must be greater than zero.',
      );
    }
  }

  final RandomSource random;
  final WordHistoryRepository wordHistory;
  final int recentWordWindow;

  Future<RoundGenerationResult> createRound({
    required List<Player> players,
    required List<Category> categories,
    required List<WordEntry> words,
    required GameSettings settings,
  }) async {
    final setupIssues = GameValidator.validateSetup(
      players: players,
      categories: categories,
      settings: settings,
    );
    if (setupIssues.isNotEmpty) return RoundRejected(setupIssues);

    final contentIssues = ContentValidator.validate(
      categories: categories,
      words: words,
    );
    if (contentIssues.isNotEmpty) return RoundRejected(contentIssues);

    final effectiveWords = words
        .where(
          (word) =>
              word.categoryIds.any(settings.selectedCategoryIds.contains) &&
              settings.difficulty.includes(word.difficulty),
        )
        .toList();

    if (effectiveWords.isEmpty) {
      return RoundRejected([
        GameIssue(
          GameIssueCode.noUsableWords,
          'These categories do not contain words for the selected difficulty. Choose another category or difficulty.',
        ),
      ]);
    }

    if (settings.hintsEnabled &&
        effectiveWords.any(
          (word) => word.hint == null || word.hint!.trim().isEmpty,
        )) {
      return RoundRejected([
        GameIssue(
          GameIssueCode.hintRequired,
          'Every word in the selected categories and difficulty needs a hint. Turn hints off or choose another category.',
        ),
      ]);
    }

    var wordPool = effectiveWords;
    if (settings.noRepeatEnabled) {
      late final Set<String> recentIds;
      try {
        recentIds = (await wordHistory.recentWordIds(limit: recentWordWindow))
            .toSet();
      } on Object {
        return RoundRejected([
          GameIssue(
            GameIssueCode.wordHistoryUnavailable,
            'Unable to read recent word history. Check device storage and try again.',
          ),
        ]);
      }
      final wordsNotRecentlyUsed = effectiveWords
          .where((word) => !recentIds.contains(word.id))
          .toList();

      if (wordsNotRecentlyUsed.isNotEmpty) {
        wordPool = wordsNotRecentlyUsed;
      }
    }

    final selectedWord = wordPool[random.nextInt(wordPool.length)];
    final playerIds = players.map((player) => player.id).toList();
    final imposterIds = _selectImposters(playerIds, settings.imposterCount);
    final startingPlayerId = playerIds[random.nextInt(playerIds.length)];
    final phoneOrder = _shuffle(playerIds);

    try {
      await wordHistory.recordWord(selectedWord.id, limit: recentWordWindow);
    } on Object {
      return RoundRejected([
        GameIssue(
          GameIssueCode.wordHistoryUnavailable,
          'Unable to save recent word history. Check device storage and try again.',
        ),
      ]);
    }

    return RoundCreated(
      Round(
        secretWordId: selectedWord.id,
        secretWord: selectedWord.word.trim(),
        hint: selectedWord.hint?.trim(),
        players: players,
        imposterIds: imposterIds,
        hintsEnabled: settings.hintsEnabled,
        startingPlayerId: startingPlayerId,
        phoneOrder: phoneOrder,
      ),
    );
  }

  Set<String> _selectImposters(List<String> playerIds, int count) {
    final candidates = List<String>.of(playerIds);
    for (var index = 0; index < count; index++) {
      final selectedIndex = index + random.nextInt(candidates.length - index);
      final selectedId = candidates[index];
      candidates[index] = candidates[selectedIndex];
      candidates[selectedIndex] = selectedId;
    }
    return Set.unmodifiable(candidates.take(count));
  }

  List<String> _shuffle(List<String> values) {
    final shuffled = List<String>.of(values);
    for (var index = shuffled.length - 1; index > 0; index--) {
      final swapIndex = random.nextInt(index + 1);
      final value = shuffled[index];
      shuffled[index] = shuffled[swapIndex];
      shuffled[swapIndex] = value;
    }
    return List.unmodifiable(shuffled);
  }
}
