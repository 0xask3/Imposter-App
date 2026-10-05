import '../models/category.dart';
import '../models/game_issue.dart';
import '../models/word_entry.dart';

final class ContentValidator {
  const ContentValidator._();

  static List<GameIssue> validate({
    required List<Category> categories,
    required List<WordEntry> words,
  }) {
    final issues = <GameIssue>[];
    final categoryIds = <String>{};

    for (final category in categories) {
      if (category.id.trim().isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.emptyCategoryId,
            'Every category needs an identifier.',
          ),
        );
      } else if (!categoryIds.add(category.id)) {
        issues.add(
          const GameIssue(
            GameIssueCode.duplicateCategoryId,
            'Category identifiers must be unique.',
          ),
        );
      }

      if (category.name.trim().isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.emptyCategoryName,
            'Every category needs a name.',
          ),
        );
      }
    }

    final wordIds = <String>{};
    final normalizedWords = <String>{};
    for (final entry in words) {
      if (entry.id.trim().isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.emptyWordId,
            'Every word needs an identifier.',
          ),
        );
      } else if (!wordIds.add(entry.id)) {
        issues.add(
          const GameIssue(
            GameIssueCode.duplicateWordId,
            'Word identifiers must be unique.',
          ),
        );
      }

      final normalizedWord = _normalize(entry.word);
      if (normalizedWord.isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.emptyWord,
            'Every word entry needs a word.',
          ),
        );
      } else if (!normalizedWords.add(normalizedWord)) {
        issues.add(
          const GameIssue(
            GameIssueCode.duplicateWord,
            'The content contains duplicate words. Keep one entry and assign it to all relevant categories.',
          ),
        );
      }

      if (entry.categoryIds.isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.wordHasNoCategories,
            'Assign every word to at least one category.',
          ),
        );
      } else if (!categoryIds.containsAll(entry.categoryIds)) {
        issues.add(
          const GameIssue(
            GameIssueCode.unknownCategory,
            'A word refers to a category that does not exist.',
          ),
        );
      }

      final hint = entry.hint;
      if (hint != null && hint.trim().isEmpty) {
        issues.add(
          const GameIssue(
            GameIssueCode.emptyHint,
            'Remove an empty hint or provide a useful hint.',
          ),
        );
      } else if (hint != null && hint.trim().contains(RegExp(r'\s'))) {
        issues.add(
          const GameIssue(
            GameIssueCode.multiWordHint,
            'Use a single-word hint.',
          ),
        );
      } else if (hint != null && _normalize(hint) == normalizedWord) {
        issues.add(
          const GameIssue(
            GameIssueCode.hintMatchesWord,
            'A hint must not be the secret word.',
          ),
        );
      }
    }

    return List.unmodifiable(issues);
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}
