import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/setup_controller.dart';
import '../../domain/services/round_generation_result.dart';
import '../app_routes.dart';
import '../privacy_screen_guard.dart';

final class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, required this.controller});

  final SetupController controller;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

final class _ResultsScreenState extends State<ResultsScreen>
    with WidgetsBindingObserver {
  bool _resultRevealed = true;
  bool _replaying = false;

  SetupController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(PrivacyScreenGuard.enterSensitiveScreen());
    if (_controller.currentRound == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _returnHome();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(PrivacyScreenGuard.leaveSensitiveScreen());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if ((state == AppLifecycleState.inactive ||
            state == AppLifecycleState.paused ||
            state == AppLifecycleState.hidden ||
            state == AppLifecycleState.detached) &&
        _resultRevealed) {
      setState(() => _resultRevealed = false);
    }
  }

  void _returnHome() {
    _controller.clearCurrentRound();
    unawaited(
      Navigator.of(context)
          .pushNamedAndRemoveUntil<void>(AppRoutes.home, (_) => false),
    );
  }

  void _startNewGame() {
    _controller.startNewGame();
    unawaited(
      Navigator.of(context).pushNamedAndRemoveUntil<void>(
        AppRoutes.players,
        ModalRoute.withName(AppRoutes.home),
      ),
    );
  }

  Future<void> _playAgain() async {
    // createRound notifies the still-visible results route before navigation.
    // Hide the old result first so it cannot briefly render the new imposters.
    setState(() {
      _replaying = true;
      _resultRevealed = false;
    });
    final result = await _controller.createRound();
    if (!mounted) return;
    setState(() {
      _replaying = false;
      if (result is RoundRejected) _resultRevealed = true;
    });

    switch (result) {
      case RoundCreated():
        unawaited(
          Navigator.of(context).pushNamedAndRemoveUntil<void>(
            AppRoutes.reveal,
            ModalRoute.withName(AppRoutes.home),
          ),
        );
      case RoundRejected(:final issues):
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Could not start another round'),
            content: Text(issues.first.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: false,
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Round Result'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _controller.currentRound == null
                        ? const Text('This round is no longer available.')
                        : _resultRevealed
                        ? _buildRevealedResult(context)
                        : _buildRevealPrompt(context),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildRevealPrompt(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.how_to_vote_rounded, size: 38),
              ),
              const SizedBox(height: 22),
              Text(
                'Results hidden',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap below to show the answer again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        key: const Key('show-round-result-button'),
        onPressed: () => setState(() => _resultRevealed = true),
        icon: const Icon(Icons.visibility_rounded),
        label: const Text('Show Results'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
      ),
    ],
  );

  Widget _buildRevealedResult(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.error.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
                child: const Icon(Icons.person_search_rounded, size: 30),
              ),
              const SizedBox(height: 16),
              Text(
                'THE IMPOSTER${_controller.imposterPlayers.length == 1 ? '' : 'S'}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final imposter in _controller.imposterPlayers)
                    Chip(
                      avatar: Icon(Icons.person, size: 18, color: colors.error),
                      label: Text(imposter.name),
                      labelStyle: TextStyle(
                        color: colors.onErrorContainer,
                        fontWeight: FontWeight.w800,
                      ),
                      backgroundColor: colors.errorContainer,
                      side: BorderSide(
                        color: colors.error.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: colors.primaryContainer.withValues(alpha: 0.7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              children: [
                Icon(Icons.key_rounded, color: colors.primary, size: 28),
                const SizedBox(height: 8),
                Text(
                  'THE SECRET WORD',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _controller.secretWord ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          key: const Key('play-again-button'),
          onPressed: _replaying ? null : _playAgain,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          child: Text(_replaying ? 'Preparing…' : 'Play Again'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const Key('new-game-from-results-button'),
          onPressed: _replaying ? null : _startNewGame,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
          ),
          child: const Text('New Game'),
        ),
      ],
    );
  }
}
