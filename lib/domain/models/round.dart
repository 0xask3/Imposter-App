import 'player.dart';
import 'reveal_payload.dart';

final class Round {
  Round({
    required this.secretWordId,
    required this.secretWord,
    required this.hint,
    required List<Player> players,
    required Set<String> impostorIds,
    required this.hintsEnabled,
    required this.startingPlayerId,
    required List<String> phoneOrder,
  }) : players = List.unmodifiable(players),
       impostorIds = Set.unmodifiable(impostorIds),
       phoneOrder = List.unmodifiable(phoneOrder);

  final String secretWordId;
  final String secretWord;
  final String? hint;
  final List<Player> players;
  final Set<String> impostorIds;
  final bool hintsEnabled;
  final String startingPlayerId;
  final List<String> phoneOrder;

  RevealPayload? revealPayloadFor(String playerId) {
    if (!players.any((player) => player.id == playerId)) return null;

    if (impostorIds.contains(playerId)) {
      return RevealPayload(
        playerId: playerId,
        role: PlayerRole.impostor,
        hint: hintsEnabled ? hint : null,
      );
    }

    return RevealPayload(
      playerId: playerId,
      role: PlayerRole.normal,
      secretWord: secretWord,
    );
  }
}
