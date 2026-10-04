import '../models/game_issue.dart';
import '../models/round.dart';

sealed class RoundGenerationResult {
  const RoundGenerationResult();
}

final class RoundCreated extends RoundGenerationResult {
  const RoundCreated(this.round);

  final Round round;
}

final class RoundRejected extends RoundGenerationResult {
  RoundRejected(List<GameIssue> issues) : issues = List.unmodifiable(issues);

  final List<GameIssue> issues;
}
