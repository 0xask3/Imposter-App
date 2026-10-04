enum PlayerRole { normal, impostor }

final class RevealPayload {
  const RevealPayload({
    required this.playerId,
    required this.role,
    this.secretWord,
    this.hint,
  });

  final String playerId;
  final PlayerRole role;
  final String? secretWord;
  final String? hint;
}
