import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter/application/setup_controller.dart';
import 'package:imposter/data/local/in_memory_word_history_repository.dart';
import 'package:imposter/domain/random/random_source.dart';
import 'package:imposter/main.dart';

void main() {
  testWidgets('players can be configured and a round is prepared privately', (
    tester,
  ) async {
    final controller = SetupController(
      random: _SeededRandomSource(42),
      wordHistory: InMemoryWordHistoryRepository(),
    );
    await tester.pumpWidget(ImposterApp(controller: controller));

    await tester.tap(find.byKey(const Key('new-game-button')));
    await tester.pumpAndSettle();
    expect(find.text('Enter a unique name for each player'), findsOneWidget);

    for (var index = 0; index < 3; index++) {
      await tester.enterText(
        find.byKey(Key('player-name-field-player-${index + 1}')),
        ['Alex', 'Sam', 'Taylor'][index],
      );
    }

    expect(controller.canContinue, isTrue);
    controller.startNewGame();
    expect(controller.players.map((player) => player.name), [
      'Alex',
      'Sam',
      'Taylor',
    ]);
    await tester.tap(find.byKey(const Key('continue-to-settings-button')));
    await tester.pumpAndSettle();
    expect(find.text('Game Settings'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();
    final startButton = find.byKey(const Key('start-game-button'));
    await tester.ensureVisible(startButton);
    await tester.tap(startButton);
    await tester.pumpAndSettle();
    expect(controller.currentRound, isNotNull);
    expect(find.byKey(const Key('slide-to-reveal-cover')), findsOneWidget);
    expect(controller.payloadVisible, isFalse);
    expect(find.byKey(const Key('confirm-player-button')), findsNothing);
    for (final imposterId in controller.currentRound!.imposterIds) {
      expect(find.text(imposterId), findsNothing);
    }

    final firstPlayer = controller.currentRevealPlayer!;
    expect(find.text(firstPlayer.name.toUpperCase()), findsOneWidget);
    expect(find.text('SLIDE UP TO REVEAL'), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('slide-to-reveal-cover')),
      const Offset(0, -140),
    );
    await tester.pumpAndSettle();
    expect(controller.payloadVisible, isTrue);
    expect(find.text(controller.currentRound!.secretWord), findsOneWidget);

    await tester.tap(find.byKey(const Key('hide-and-pass-button')));
    await tester.pumpAndSettle();
    expect(find.text(controller.currentRound!.secretWord), findsNothing);
    expect(controller.currentRevealPlayer!.id, isNot(firstPlayer.id));
    expect(find.byKey(const Key('slide-to-reveal-cover')), findsOneWidget);
  });

  testWidgets('duplicate player names show an actionable validation message', (
    tester,
  ) async {
    final controller = SetupController(
      random: _SeededRandomSource(1),
      wordHistory: InMemoryWordHistoryRepository(),
    );
    await tester.pumpWidget(ImposterApp(controller: controller));
    await tester.tap(find.byKey(const Key('new-game-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('player-name-field-player-1')),
      'Alex',
    );
    await tester.enterText(
      find.byKey(const Key('player-name-field-player-2')),
      ' alex ',
    );

    expect(
      find.text(
        'Player names must be unique. Rename one of the duplicate players.',
      ),
      findsNWidgets(2),
    );
    expect(controller.players, hasLength(3));
    expect(controller.canContinue, isFalse);
  });
}

final class _SeededRandomSource implements RandomSource {
  _SeededRandomSource(int seed) : _random = Random(seed);

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}
