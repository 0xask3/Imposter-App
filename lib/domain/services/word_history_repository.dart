abstract interface class WordHistoryRepository {
  Future<List<String>> recentWordIds({required int limit});

  Future<void> recordWord(String wordId, {required int limit});
}
