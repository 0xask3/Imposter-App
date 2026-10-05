import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/data/builtin/builtin_content.dart';
import 'package:imposter/domain/services/content_validator.dart';

void main() {
  test('the built-in catalog has 50 valid words per category', () {
    expect(
      ContentValidator.validate(
        categories: builtinCategories,
        words: builtinWords,
      ),
      isEmpty,
    );

    for (final category in builtinCategories) {
      expect(
        builtinWords
            .where((word) => word.categoryIds.contains(category.id))
            .length,
        50,
        reason: '${category.name} should have 50 words',
      );
    }
  });
}
