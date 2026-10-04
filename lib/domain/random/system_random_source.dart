import 'dart:math';

import 'random_source.dart';

final class SystemRandomSource implements RandomSource {
  SystemRandomSource() : _random = Random.secure();

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}
