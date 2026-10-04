enum Difficulty { easy, medium, hard }

enum DifficultyFilter { any, easy, medium, hard }

extension DifficultyFilterMatching on DifficultyFilter {
  bool includes(Difficulty difficulty) =>
      this == DifficultyFilter.any || name == difficulty.name;
}
