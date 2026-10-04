import 'player.dart';
import 'reveal_payload.dart';

final class Round {
  Round({
    required this.secretWordId,
    required this.secretWord,
    required this.hint,
    required List<Player> players,
    required Set<String> imposterIds,
    required this.hintsEnabled,
    required this.startingPlayerId,
    required List<String> phoneOrder,
  }) : players = List.unmodifiable(players),
       imposterIds = Set.unmodifiable(imposterIds),
       phoneOrder = List.unmodifiable(phoneOrder);

  final String secretWordId;
  final String secretWord;
  final String? hint;
  final List<Player> players;
  final Set<String> imposterIds;
  final bool hintsEnabled;
  final String startingPlayerId;
  final List<String> phoneOrder;

  RevealPayload? revealPayloadFor(String playerId) {
    if (!players.any((player) => player.id == playerId)) return null;

    if (imposterIds.contains(playerId)) {
      return RevealPayload(
        playerId: playerId,
        role: PlayerRole.imposter,
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
