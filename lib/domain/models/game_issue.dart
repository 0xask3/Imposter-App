enum GameIssueCode {
  playerCountOutOfRange,
  emptyPlayerId,
  duplicatePlayerId,
  emptyPlayerName,
  playerNameTooLong,
  duplicatePlayerName,
  invalidImposterCount,
  emptyCategoryId,
  emptyCategoryName,
  duplicateCategoryId,
  noCategoriesSelected,
  unknownCategory,
  emptyWordId,
  emptyWord,
  duplicateWordId,
  duplicateWord,
  wordHasNoCategories,
  emptyHint,
  hintMatchesWord,
  hintRequired,
  wordHistoryUnavailable,
  noUsableWords,
}

final class GameIssue {
  const GameIssue(this.code, this.message);

  final GameIssueCode code;
  final String message;
}
