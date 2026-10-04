import '../../domain/services/word_history_repository.dart';

final class InMemoryWordHistoryRepository implements WordHistoryRepository {
  final List<String> _wordIds = [];

  @override
  Future<List<String>> recentWordIds({required int limit}) async {
    if (limit <= 0) return const [];
    return List.unmodifiable(_wordIds.reversed.take(limit));
  }

  @override
  Future<void> recordWord(String wordId, {required int limit}) async {
    if (limit <= 0) return;

    _wordIds.add(wordId);
    if (_wordIds.length > limit) {
      _wordIds.removeRange(0, _wordIds.length - limit);
    }
  }
}
