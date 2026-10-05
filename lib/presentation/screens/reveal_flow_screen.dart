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
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _choosingStartingPlayer = false;
  bool _startingPlayerRevealed = false;
  late final AnimationController _coverController;
  bool _assignmentRevealed = false;

  SetupController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _coverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
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
    _coverController.dispose();
    unawaited(PrivacyScreenGuard.leaveSensitiveScreen());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _coverController.stop();
      _coverController.value = 0;
      setState(() => _assignmentRevealed = false);
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

  Future<void> _revealStartingPlayer() async {
    setState(() => _choosingStartingPlayer = true);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _choosingStartingPlayer = false;
      _startingPlayerRevealed = true;
    });
  }

  void _continueToDiscussion() {
    unawaited(
      Navigator.of(context).pushNamedAndRemoveUntil<void>(
        AppRoutes.discussion,
        ModalRoute.withName(AppRoutes.home),
      ),
    );
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
    if (_controller.revealComplete) return _buildStartingPlayerStage(context);

    final player = _controller.currentRevealPlayer;
    if (player == null) return const Text('This round is no longer available.');

    final payload = _controller.currentRound!.revealPayloadFor(player.id);
    if (payload == null) return const Text('This assignment is unavailable.');
    return _buildPayloadStage(context, payload, player.name);
  }

  void _dragRevealCover(DragUpdateDetails details) {
    _coverController.value = (_coverController.value - details.delta.dy / 252)
        .clamp(0, 1);
  }

  void _finishRevealCover(DragEndDetails details) {
    if (_coverController.value > 0.2 || (details.primaryVelocity ?? 0) < -320) {
      _openAssignment();
    } else {
      _animateCoverTo(0);
    }
  }

  void _openAssignment() {
    if (_assignmentRevealed) return;
    _controller.confirmCurrentPlayer();
    _controller.revealCurrentPayload();
    setState(() => _assignmentRevealed = true);
    _animateCoverTo(1);
  }

  void _animateCoverTo(double value) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _coverController.value = value;
    } else {
      unawaited(
        _coverController.animateTo(value, curve: Curves.easeInOutCubic),
      );
    }
  }

  void _hideAndPass() {
    _coverController.value = 0;
    setState(() => _assignmentRevealed = false);
    _controller.hideAndAdvance();
  }

  Widget _buildPayloadStage(
    BuildContext context,
    RevealPayload payload,
    String playerName,
  ) {
    final isImposter = payload.role == PlayerRole.imposter;
    final colors = Theme.of(context).colorScheme;
    final revealOrder = _controller.currentRound!.phoneOrder;
    final playerIndex = revealOrder.indexOf(
      _controller.currentRevealPlayer!.id,
    );
    final progress = (playerIndex + 1) / revealOrder.length;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'PLAYER ${playerIndex + 1}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              'OF ${revealOrder.length}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(value: progress, minHeight: 5),
        ),
        const SizedBox(height: 28),
        Text(
          playerName.toUpperCase(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 8),
        Text(
          'PRIVATE ASSIGNMENT',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 14),
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surfaceContainerHigh,
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Icon(
            _assignmentRevealed
                ? (isImposter ? Icons.visibility_off : Icons.visibility)
                : Icons.lock_outline,
            color: _assignmentRevealed
                ? (isImposter ? colors.error : colors.primary)
                : colors.onSurfaceVariant,
            size: 38,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 210,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(
                child: Center(
                  child: ExcludeSemantics(
                    excluding: !_assignmentRevealed,
                    child: _buildAssignmentContent(
                      context,
                      payload,
                      isImposter,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _coverController,
                  child: Semantics(
                    button: true,
                    label: 'Slide up to reveal assignment',
                    onTap: _openAssignment,
                    child: GestureDetector(
                      key: const Key('slide-to-reveal-cover'),
                      onTap: _openAssignment,
                      onVerticalDragUpdate: _dragRevealCover,
                      onVerticalDragEnd: _finishRevealCover,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: BorderSide(color: colors.outlineVariant),
                        ),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHigh,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 44,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Icon(Icons.lock_outline, size: 30),
                              const SizedBox(height: 8),
                              Text(
                                'SLIDE UP TO REVEAL',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              const Icon(Icons.keyboard_arrow_up),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, -252 * _coverController.value),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: 18,
              color: colors.primary,
            ),
            const SizedBox(width: 8),
            const Text('Keep your assignment secret.'),
          ],
        ),
        const SizedBox(height: 32),
        FilledButton(
          key: const Key('hide-and-pass-button'),
          onPressed: _assignmentRevealed ? _hideAndPass : null,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: const Text('Hide & Pass'),
        ),
      ],
    );
  }

  Widget _buildAssignmentContent(
    BuildContext context,
    RevealPayload payload,
    bool isImposter,
  ) {
    final roleColor = isImposter
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    if (isImposter) {
      final hint = payload.hint;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'YOU ARE THE IMPOSTER',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: roleColor, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          if (hint != null) ...[
            Text(
              'HINT',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(color: roleColor),
            ),
            const SizedBox(height: 8),
            Text(
              hint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: roleColor, fontWeight: FontWeight.bold),
            ),
          ] else
            Text(
              'You do not know the word.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(color: roleColor),
            ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'YOUR WORD',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: roleColor,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            payload.secretWord ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayMedium
                ?.copyWith(color: roleColor, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }

  Widget _buildStartingPlayerStage(BuildContext context) {
    final startingPlayer = _controller.startingPlayer;
    if (startingPlayer == null) {
      return const Text('Starting player unavailable.');
    }

    if (_choosingStartingPlayer) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CHOOSING STARTING PLAYER…',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 28),
          const CircularProgressIndicator(),
        ],
      );
    }

    if (_startingPlayerRevealed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${startingPlayer.name.toUpperCase()} STARTS',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Give clues, discuss, and find the imposter.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton(
            key: const Key('continue-to-discussion-button'),
            onPressed: _continueToDiscussion,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            child: const Text('Continue'),
          ),
        ],
      );
    }

    return Column(
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
        const SizedBox(height: 32),
        FilledButton(
          key: const Key('reveal-starting-player-button'),
          onPressed: _revealStartingPlayer,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          child: const Text('Reveal Starting Player'),
        ),
      ],
    );
  }
}
