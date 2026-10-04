import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/setup_controller.dart';
import '../../domain/models/reveal_payload.dart';
import '../app_routes.dart';
import '../privacy_screen_guard.dart';

final class RevealFlowScreen extends StatefulWidget {
  const RevealFlowScreen({super.key, required this.controller});

  final SetupController controller;

  @override
  State<RevealFlowScreen> createState() => _RevealFlowScreenState();
}

final class _RevealFlowScreenState extends State<RevealFlowScreen>
    with WidgetsBindingObserver {
  SetupController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(PrivacyScreenGuard.setSecure(true));
    if (_controller.currentRound == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _returnHome();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(PrivacyScreenGuard.setSecure(false));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _controller.handleRevealInterruption();
    }
  }

  void _returnHome() {
    _controller.clearCurrentRound();
    unawaited(
      Navigator.of(context)
          .pushNamedAndRemoveUntil<void>(AppRoutes.home, (_) => false),
    );
  }

  Future<void> _confirmCancel() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this round?'),
        content: const Text(
          'The secret assignments will be cleared and everyone will return home.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel round'),
          ),
        ],
      ),
    );
    if (shouldCancel == true && mounted) _returnHome();
  }

  @override
  Widget build(BuildContext context) => PopScope<void>(
    canPop: false,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Private reveal'),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Cancel round',
              icon: const Icon(Icons.close),
              onPressed: _confirmCancel,
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildStage(context),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildStage(BuildContext context) {
    if (_controller.currentRound == null) {
      return const Text('This round is no longer available.');
    }
    if (_controller.revealComplete) return _buildCompleteStage(context);

    final player = _controller.currentRevealPlayer;
    if (player == null) return const Text('This round is no longer available.');

    if (_controller.payloadVisible) {
      final payload = _controller.currentRound!.revealPayloadFor(player.id);
      if (payload == null) return const Text('This assignment is unavailable.');
      return _buildPayloadStage(context, payload);
    }
    if (_controller.identityConfirmed) {
      return _buildReadyStage(context);
    }
    return _buildPassStage(context, player.name);
  }

  Widget _buildPassStage(BuildContext context, String playerName) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.phonelink_ring_outlined, size: 56),
      const SizedBox(height: 28),
      Text(
        'PASS THE PHONE',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2),
      ),
      const SizedBox(height: 20),
      Text(
        'Give the phone to',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          playerName.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall
              ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Make sure nobody else can see the screen.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 36),
      FilledButton(
        key: const Key('confirm-player-button'),
        onPressed: _controller.confirmCurrentPlayer,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        child: Text("I'm $playerName"),
      ),
    ],
  );

  Widget _buildReadyStage(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.lock_outline, size: 56),
      const SizedBox(height: 24),
      Text(
        'Your information is ready.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      const Text(
        'Check that you are alone before you reveal it.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      FilledButton(
        key: const Key('reveal-information-button'),
        onPressed: _controller.revealCurrentPayload,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        child: const Text('Reveal'),
      ),
    ],
  );

  Widget _buildPayloadStage(BuildContext context, RevealPayload payload) {
    final isImposter = payload.role == PlayerRole.imposter;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          isImposter
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 54,
        ),
        const SizedBox(height: 28),
        if (isImposter) ...[
          Text(
            'YOU ARE THE IMPOSTER',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 24),
          if (payload.hint case final hint?) ...[
            Text(
              'HINT',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ] else
            Text(
              'You do not know the word.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
        ] else ...[
          Text(
            'YOUR WORD',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              payload.secretWord ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text('Remember your information.', textAlign: TextAlign.center),
        const SizedBox(height: 32),
        FilledButton(
          key: const Key('hide-and-pass-button'),
          onPressed: _controller.hideAndAdvance,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: const Text('Hide & Pass'),
        ),
      ],
    );
  }

  Widget _buildCompleteStage(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.check_circle_outline, size: 56),
      const SizedBox(height: 24),
      Text(
        'Everyone has seen their role.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 12),
      const Text(
        'The starting-player and discussion screens are the next part of the game.',
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 32),
      FilledButton(
        key: const Key('finish-reveal-flow-button'),
        onPressed: _returnHome,
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
        child: const Text('Return Home'),
      ),
    ],
  );
}
