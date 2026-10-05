import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/data/local/in_memory_word_history_repository.dart';
import 'package:imposter/domain/models/category.dart';
import 'package:imposter/domain/models/difficulty.dart';
import 'package:imposter/domain/models/game_issue.dart';
import 'package:imposter/domain/models/game_settings.dart';
import 'package:imposter/domain/models/player.dart';
import 'package:imposter/domain/models/reveal_payload.dart';
import 'package:imposter/domain/models/word_entry.dart';
import 'package:imposter/domain/random/random_source.dart';
import 'package:imposter/domain/services/round_generation_result.dart';
import 'package:imposter/domain/services/round_generator.dart';
import 'package:imposter/domain/services/word_history_repository.dart';

const category = Category(id: 'food', name: 'Food');

final players = List.generate(
  5,
  (index) => Player(id: 'player-$index', name: 'Player $index'),
);

final words = [
  WordEntry(
    id: 'pizza',
    word: 'Pizza',
    hint: 'Cuisine',
    categoryIds: const {'food'},
    difficulty: Difficulty.easy,
  ),
  WordEntry(
    id: 'sushi',
    word: 'Sushi',
    hint: 'Grain',
    categoryIds: const {'food'},
    difficulty: Difficulty.medium,
  ),
  WordEntry(
    id: 'waffle',
    word: 'Waffle',
    hint: 'Grid',
    categoryIds: const {'food'},
    difficulty: Difficulty.hard,
  ),
];

GameSettings settings({
  int imposters = 2,
  bool hints = true,
  bool noRepeat = false,
}) => GameSettings(
  imposterCount: imposters,
  selectedCategoryIds: const {'food'},
  hintsEnabled: hints,
  noRepeatEnabled: noRepeat,
);

Future<RoundCreated> createRound({
  required RoundGenerator generator,
  required GameSettings gameSettings,
  List<WordEntry>? content,
  List<Player>? group,
}) async {
  final result = await generator.createRound(
    players: group ?? players,
    categories: const [category],
    words: content ?? words,
    settings: gameSettings,
  );
  expect(result, isA<RoundCreated>());
  return result as RoundCreated;
}

void main() {
  test(
    'creates valid assignments and reveal payloads over repeated rounds',
    () async {
      for (var seed = 0; seed < 100; seed++) {
        final generator = RoundGenerator(
          random: SeededRandomSource(seed),
          wordHistory: InMemoryWordHistoryRepository(),
        );
        final round = (await createRound(
          generator: generator,
          gameSettings: settings(),
        )).round;

        expect(round.imposterIds, hasLength(2));
        expect(round.imposterIds.length, 2);
        expect(
          players.map((player) => player.id),
          containsAll(round.imposterIds),
        );
        expect(
          players.map((player) => player.id),
          contains(round.startingPlayerId),
        );
        expect(round.phoneOrder, hasLength(players.length));
        expect(
          round.phoneOrder.toSet(),
          players.map((player) => player.id).toSet(),
        );

        for (final player in players) {
          final payload = round.revealPayloadFor(player.id)!;
          if (round.imposterIds.contains(player.id)) {
            expect(payload.role, PlayerRole.imposter);
            expect(payload.secretWord, isNull);
            expect(payload.hint, isNotEmpty);
            expect(payload.hint, isNot(round.secretWord));
          } else {
            expect(payload.role, PlayerRole.normal);
            expect(payload.secretWord, round.secretWord);
            expect(payload.hint, isNull);
          }
        }
      }
    },
  );

  test('imposters do not receive a word when hints are disabled', () async {
    final round = (await createRound(
      generator: RoundGenerator(
        random: SeededRandomSource(11),
        wordHistory: InMemoryWordHistoryRepository(),
      ),
      gameSettings: settings(hints: false),
    )).round;

    for (final playerId in round.imposterIds) {
      final payload = round.revealPayloadFor(playerId)!;
      expect(payload.role, PlayerRole.imposter);
      expect(payload.secretWord, isNull);
      expect(payload.hint, isNull);
    }
    expect(round.revealPayloadFor('unknown-player'), isNull);
  });

  test(
    'avoids recent words and falls back when a small pool is exhausted',
    () async {
      final history = InMemoryWordHistoryRepository();
      final generator = RoundGenerator(
        random: SeededRandomSource(4),
        wordHistory: history,
        recentWordWindow: 20,
      );

      final selectedIds = <String>{};
      for (var index = 0; index < words.length; index++) {
        final round = (await createRound(
          generator: generator,
          gameSettings: settings(noRepeat: true),
        )).round;
        selectedIds.add(round.secretWordId);
      }
      expect(selectedIds, hasLength(words.length));

      final exhaustedPoolRound = (await createRound(
        generator: generator,
        gameSettings: settings(noRepeat: true),
      )).round;
      expect(
        words.map((word) => word.id),
        contains(exhaustedPoolRound.secretWordId),
      );
    },
  );

  test(
    'play again creates a fresh word assignment with the same setup',
    () async {
      final generator = RoundGenerator(
        random: SeededRandomSource(7),
        wordHistory: InMemoryWordHistoryRepository(),
      );
      final first = (await createRound(
        generator: generator,
        gameSettings: settings(noRepeat: true),
      )).round;
      final replay = (await createRound(
        generator: generator,
        gameSettings: settings(noRepeat: true),
      )).round;

      expect(identical(first, replay), isFalse);
      expect(replay.secretWordId, isNot(first.secretWordId));
      expect(replay.players, players);
      expect(replay.imposterIds, hasLength(2));
    },
  );

  test(
    'rejects an empty effective pool and incomplete hint-enabled content',
    () async {
      final generator = RoundGenerator(
        random: SeededRandomSource(3),
        wordHistory: InMemoryWordHistoryRepository(),
      );
      final noWords = await generator.createRound(
        players: players,
        categories: const [category],
        words: const [],
        settings: settings(),
      );
      expect(noWords, isA<RoundRejected>());
      expect(
        (noWords as RoundRejected).issues.map((issue) => issue.code),
        contains(GameIssueCode.noUsableWords),
      );

      final missingHint = await generator.createRound(
        players: players,
        categories: const [category],
        words: [
          WordEntry(
            id: 'plain',
            word: 'Bread',
            categoryIds: const {'food'},
            difficulty: Difficulty.easy,
          ),
        ],
        settings: settings(),
      );
      expect(missingHint, isA<RoundRejected>());
      expect(
        (missingHint as RoundRejected).issues.map((issue) => issue.code),
        contains(GameIssueCode.hintRequired),
      );
    },
  );

  test('returns an actionable issue when local word history fails', () async {
    final result =
        await RoundGenerator(
          random: SeededRandomSource(19),
          wordHistory: FailingWordHistoryRepository(),
        ).createRound(
          players: players,
          categories: const [category],
          words: words,
          settings: settings(),
        );

    expect(result, isA<RoundRejected>());
    expect(
      (result as RoundRejected).issues.map((issue) => issue.code),
      contains(GameIssueCode.wordHistoryUnavailable),
    );
  });
}

final class SeededRandomSource implements RandomSource {
  SeededRandomSource(int seed) : _random = Random(seed);

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}

final class FailingWordHistoryRepository implements WordHistoryRepository {
  @override
  Future<List<String>> recentWordIds({required int limit}) async =>
      throw StateError('Storage unavailable');

  @override
  Future<void> recordWord(String wordId, {required int limit}) async =>
      throw StateError('Storage unavailable');
}
