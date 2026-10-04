import 'difficulty.dart';

final class GameSettings {
  GameSettings({
    required this.impostorCount,
    required Set<String> selectedCategoryIds,
    this.difficulty = DifficultyFilter.any,
    this.hintsEnabled = false,
    this.noRepeatEnabled = true,
  }) : selectedCategoryIds = Set.unmodifiable(selectedCategoryIds);

  final int impostorCount;
  final Set<String> selectedCategoryIds;
  final DifficultyFilter difficulty;
  final bool hintsEnabled;
  final bool noRepeatEnabled;
}
