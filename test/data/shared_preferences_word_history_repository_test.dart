import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/data/local/shared_preferences_word_history_repository.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late InMemorySharedPreferencesAsync store;

  setUp(() {
    store = InMemorySharedPreferencesAsync.empty();
    SharedPreferencesAsyncPlatform.instance = store;
  });

  tearDown(() {
    SharedPreferencesAsyncPlatform.instance = null;
  });

  test('persists only the configured recent-word window', () async {
    final firstRepository = SharedPreferencesWordHistoryRepository();
    await firstRepository.recordWord('word-one', limit: 2);
    await firstRepository.recordWord('word-two', limit: 2);
    await firstRepository.recordWord('word-three', limit: 2);

    final reopenedRepository = SharedPreferencesWordHistoryRepository();
    expect(await reopenedRepository.recentWordIds(limit: 20), [
      'word-three',
      'word-two',
    ]);
  });

  test('does not store anything when the window is disabled', () async {
    final repository = SharedPreferencesWordHistoryRepository();
    await repository.recordWord('word-one', limit: 0);

    expect(await repository.recentWordIds(limit: 20), isEmpty);
  });
}
