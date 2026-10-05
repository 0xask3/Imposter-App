import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/domain/models/category.dart';
import 'package:imposter/domain/models/game_issue.dart';
import 'package:imposter/domain/models/word_entry.dart';
import 'package:imposter/domain/models/difficulty.dart';
import 'package:imposter/domain/services/content_validator.dart';

void main() {
  const categories = [Category(id: 'animals', name: 'Animals')];

  test('accepts valid unique content with a distinct hint', () {
    final issues = ContentValidator.validate(
      categories: categories,
      words: [
        WordEntry(
          id: 'penguin',
          word: 'Penguin',
          hint: 'Arctic',
          categoryIds: const {'animals'},
          difficulty: Difficulty.easy,
        ),
      ],
    );

    expect(issues, isEmpty);
  });

  test('rejects duplicate or incomplete word content', () {
    final issues = ContentValidator.validate(
      categories: categories,
      words: [
        WordEntry(
          id: 'bird-one',
          word: 'Penguin',
          hint: '  ',
          categoryIds: const {'animals'},
          difficulty: Difficulty.easy,
        ),
        WordEntry(
          id: 'bird-two',
          word: ' penguin ',
          hint: 'Penguin',
          categoryIds: const {'missing'},
          difficulty: Difficulty.medium,
        ),
        WordEntry(
          id: 'empty',
          word: '',
          categoryIds: const {},
          difficulty: Difficulty.hard,
        ),
      ],
    );
    final codes = issues.map((issue) => issue.code);

    expect(codes, contains(GameIssueCode.duplicateWord));
    expect(codes, contains(GameIssueCode.emptyHint));
    expect(codes, contains(GameIssueCode.hintMatchesWord));
    expect(codes, contains(GameIssueCode.unknownCategory));
    expect(codes, contains(GameIssueCode.emptyWord));
    expect(codes, contains(GameIssueCode.wordHasNoCategories));
  });

  test('rejects hints with more than one word', () {
    final issues = ContentValidator.validate(
      categories: categories,
      words: [
        WordEntry(
          id: 'penguin',
          word: 'Penguin',
          hint: 'Cold climate',
          categoryIds: const {'animals'},
          difficulty: Difficulty.easy,
        ),
      ],
    );

    expect(
      issues.map((issue) => issue.code),
      contains(GameIssueCode.multiWordHint),
    );
  });
}
