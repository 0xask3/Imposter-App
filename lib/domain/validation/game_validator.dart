import '../models/category.dart';
import '../models/game_issue.dart';
import '../models/game_settings.dart';
import '../models/player.dart';

final class GameValidator {
  const GameValidator._();

  static const int minPlayers = 3;
  static const int maxPlayers = 20;
  static const int maxPlayerNameLength = 24;

  static List<GameIssue> validateSetup({
    required List<Player> players,
    required List<Category> categories,
    required GameSettings settings,
  }) {
    final issues = <GameIssue>[];

    if (players.length < minPlayers || players.length > maxPlayers) {
      issues.add(
        const GameIssue(
          GameIssueCode.playerCountOutOfRange,
          'Add between 3 and 20 players to start a round.',
        ),
      );
    }

    final seenIds = <String>{};
    final seenNames = <String>{};
    for (final player in players) {
      if (player.id.isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.emptyPlayerId,
            'Each player needs a valid identifier.',
          ),
        );
      } else if (!seenIds.add(player.id)) {
        issues.add(
          const GameIssue(
            GameIssueCode.duplicatePlayerId,
            'Player identifiers must be unique.',
          ),
        );
      }

      if (player.name.isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.emptyPlayerName,
            'Enter a name for every player.',
          ),
        );
      } else if (player.name.length > maxPlayerNameLength) {
        issues.add(
          GameIssue(
            GameIssueCode.playerNameTooLong,
            'Player names must be $maxPlayerNameLength characters or fewer.',
          ),
        );
      }

      final normalizedName = player.name.toLowerCase();
      if (normalizedName.isNotEmpty && !seenNames.add(normalizedName)) {
        issues.add(
          const GameIssue(
            GameIssueCode.duplicatePlayerName,
            'Player names must be unique. Rename one of the duplicate players.',
          ),
        );
      }
    }

    if (settings.impostorCount < 1 ||
        settings.impostorCount >= players.length) {
      issues.add(
        const GameIssue(
          GameIssueCode.invalidImpostorCount,
          'Choose at least one impostor and fewer impostors than players.',
        ),
      );
    }

    if (settings.selectedCategoryIds.isEmpty) {
      issues.add(
        const GameIssue(
          GameIssueCode.noCategoriesSelected,
          'Choose at least one category.',
        ),
      );
    }

    final categoryIds = categories.map((category) => category.id).toSet();
    if (!categoryIds.containsAll(settings.selectedCategoryIds)) {
      issues.add(
        const GameIssue(
          GameIssueCode.unknownCategory,
          'One or more selected categories are unavailable. Choose another category.',
        ),
      );
    }

    return List.unmodifiable(issues);
  }
}
