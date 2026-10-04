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
    expect(find.text('Add at least 3 players to continue.'), findsOneWidget);

    for (final name in ['Alex', 'Sam', 'Taylor']) {
      await tester.tap(find.byKey(const Key('add-player-button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('player-name-field')), name);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Alex'), findsOneWidget);
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
    expect(find.text('PASS THE PHONE'), findsOneWidget);
    expect(find.text(controller.currentRound!.secretWord), findsNothing);
    for (final imposterId in controller.currentRound!.imposterIds) {
      expect(find.text(imposterId), findsNothing);
    }

    final firstPlayer = controller.currentRevealPlayer!;
    await tester.tap(find.byKey(const Key('confirm-player-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('reveal-information-button')), findsOneWidget);
    expect(find.text(controller.currentRound!.secretWord), findsNothing);

    await tester.tap(find.byKey(const Key('reveal-information-button')));
    await tester.pumpAndSettle();
    expect(find.text(controller.currentRound!.secretWord), findsOneWidget);

    await tester.tap(find.byKey(const Key('hide-and-pass-button')));
    await tester.pumpAndSettle();
    expect(find.text(controller.currentRound!.secretWord), findsNothing);
    expect(controller.currentRevealPlayer!.id, isNot(firstPlayer.id));
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

    await tester.tap(find.byKey(const Key('add-player-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('player-name-field')), 'Alex');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('add-player-button')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('player-name-field')),
      ' alex ',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Player names must be unique. Rename one of the duplicate players.',
      ),
      findsOneWidget,
    );
    expect(controller.players, hasLength(1));
  });
}

final class _SeededRandomSource implements RandomSource {
  _SeededRandomSource(int seed) : _random = Random(seed);

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}
