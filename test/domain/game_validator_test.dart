import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/domain/models/category.dart';
import 'package:imposter/domain/models/game_issue.dart';
import 'package:imposter/domain/models/game_settings.dart';
import 'package:imposter/domain/models/player.dart';
import 'package:imposter/domain/validation/game_validator.dart';

void main() {
  const categories = [Category(id: 'food', name: 'Food')];

  GameSettings settings(int imposterCount) => GameSettings(
    imposterCount: imposterCount,
    selectedCategoryIds: const {'food'},
  );

  List<Player> players(int count) => List.generate(
    count,
    (index) => Player(id: 'player-$index', name: 'Player $index'),
  );

  test('accepts the supported player-count boundaries', () {
    expect(
      GameValidator.validateSetup(
        players: players(3),
        categories: categories,
        settings: settings(1),
      ),
      isEmpty,
    );
    expect(
      GameValidator.validateSetup(
        players: players(20),
        categories: categories,
        settings: settings(1),
      ),
      isEmpty,
    );
  });

  test('rejects player counts outside 3 through 20', () {
    for (final count in [2, 21]) {
      final issues = GameValidator.validateSetup(
        players: players(count),
        categories: categories,
        settings: settings(1),
      );
      expect(
        issues.map((issue) => issue.code),
        contains(GameIssueCode.playerCountOutOfRange),
      );
    }
  });

  test('rejects invalid imposter counts and duplicate player names', () {
    for (final count in [0, 3]) {
      final issues = GameValidator.validateSetup(
        players: players(3),
        categories: categories,
        settings: settings(count),
      );
      expect(
        issues.map((issue) => issue.code),
        contains(GameIssueCode.invalidImposterCount),
      );
    }

    final duplicateNames = [
      Player(id: 'one', name: 'Alex'),
      Player(id: 'two', name: ' alex '),
      Player(id: 'three', name: 'Sam'),
    ];
    final issues = GameValidator.validateSetup(
      players: duplicateNames,
      categories: categories,
      settings: settings(1),
    );
    expect(
      issues.map((issue) => issue.code),
      contains(GameIssueCode.duplicatePlayerName),
    );
    expect(duplicateNames[1].name, 'alex');
  });

  test('rejects missing and duplicate player identifiers', () {
    final issues = GameValidator.validateSetup(
      players: [
        Player(id: '', name: 'Alex'),
        Player(id: 'same-id', name: 'Sam'),
        Player(id: 'same-id', name: 'Jordan'),
      ],
      categories: categories,
      settings: settings(1),
    );
    final codes = issues.map((issue) => issue.code);

    expect(codes, contains(GameIssueCode.emptyPlayerId));
    expect(codes, contains(GameIssueCode.duplicatePlayerId));
  });

  test('rejects blank and overlong names and empty category selection', () {
    final issues = GameValidator.validateSetup(
      players: [
        Player(id: 'one', name: '  '),
        Player(id: 'two', name: List.filled(25, 'B').join()),
        Player(id: 'three', name: 'C'),
      ],
      categories: categories,
      settings: GameSettings(imposterCount: 1, selectedCategoryIds: const {}),
    );

    final codes = issues.map((issue) => issue.code);
    expect(codes, contains(GameIssueCode.emptyPlayerName));
    expect(codes, contains(GameIssueCode.playerNameTooLong));
    expect(codes, contains(GameIssueCode.noCategoriesSelected));
  });
}
