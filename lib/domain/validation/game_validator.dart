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

      issues.addAll(
        validatePlayerName(
          player.name,
          existingPlayers: players,
          excludingPlayerId: player.id,
        ),
      );
    }

    if (settings.imposterCount < 1 ||
        settings.imposterCount >= players.length) {
      issues.add(
        const GameIssue(
          GameIssueCode.invalidImposterCount,
          'Choose at least one imposter and fewer imposters than players.',
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

  static List<GameIssue> validatePlayerName(
    String name, {
    required List<Player> existingPlayers,
    String? excludingPlayerId,
  }) {
    final normalizedName = name.trim().toLowerCase();
    if (normalizedName.isEmpty) {
      return const [
        GameIssue(
          GameIssueCode.emptyPlayerName,
          'Enter a name for this player.',
        ),
      ];
    }
    if (normalizedName.length > maxPlayerNameLength) {
      return const [
        GameIssue(
          GameIssueCode.playerNameTooLong,
          'Player names must be 24 characters or fewer.',
        ),
      ];
    }
    if (existingPlayers.any(
      (player) =>
          player.id != excludingPlayerId &&
          player.name.toLowerCase() == normalizedName,
    )) {
      return const [
        GameIssue(
          GameIssueCode.duplicatePlayerName,
          'Player names must be unique. Rename one of the duplicate players.',
        ),
      ];
    }
    return const [];
  }
}
