import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/services/word_history_repository.dart';

final class SharedPreferencesWordHistoryRepository
    implements WordHistoryRepository {
  SharedPreferencesWordHistoryRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _storageKey = 'impostor.recentWordIds';

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<String>> recentWordIds({required int limit}) async {
    if (limit <= 0) return const [];

    final wordIds = await _preferences.getStringList(_storageKey) ?? const [];
    return List.unmodifiable(wordIds.reversed.take(limit));
  }

  @override
  Future<void> recordWord(String wordId, {required int limit}) async {
    if (limit <= 0) return;

    final wordIds = await _preferences.getStringList(_storageKey) ?? <String>[];
    wordIds.add(wordId);
    if (wordIds.length > limit) {
      wordIds.removeRange(0, wordIds.length - limit);
    }
    await _preferences.setStringList(_storageKey, wordIds);
  }
}
