import 'difficulty.dart';

final class WordEntry {
  WordEntry({
    required this.id,
    required this.word,
    required Set<String> categoryIds,
    required this.difficulty,
    this.hint,
  }) : categoryIds = Set.unmodifiable(categoryIds);

  final String id;
  final String word;
  final String? hint;
  final Set<String> categoryIds;
  final Difficulty difficulty;
}
