import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/data/builtin/builtin_content.dart';
import 'package:imposter/domain/services/content_validator.dart';

void main() {
  test('the setup seed catalog passes domain content validation', () {
    expect(
      ContentValidator.validate(
        categories: builtinCategories,
        words: builtinWords,
      ),
      isEmpty,
    );
  });
}
