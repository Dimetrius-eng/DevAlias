import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/game_settings.dart';
import '../domain/game_word.dart';
import '../platform/game_feedback.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.settings,
    required this.words,
    this.nativeCoreVersion,
  });

  final GameSettings settings;
  final List<GameWord> words;
  final int? nativeCoreVersion;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var _currentWordIndex = 0;
  var _roundIndex = 0;
  var _firstTeamScore = 0;
  var _secondTeamScore = 0;
  late int _secondsRemaining;
  Timer? _roundTimer;
  var _isPaused = false;
  var _isRoundFinished = false;
  var _isGameFinished = false;
  var _lastActionWasGuess = false;

  GameWord get _currentWord => widget.words[_currentWordIndex];
  bool get _isFirstTeamTurn => _roundIndex.isEven;
  bool get _isFinalRound => _roundIndex + 1 == widget.settings.roundCount;
  String get _activeTeamName => _isFirstTeamTurn
      ? widget.settings.firstTeam.name
      : widget.settings.secondTeam.name;
  int get _activeTeamScore =>
      _isFirstTeamTurn ? _firstTeamScore : _secondTeamScore;

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.settings.roundDuration.inSeconds;
    _startTimer();
  }

  @override
  void dispose() {
    _roundTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _roundTimer?.cancel();
    _roundTimer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (_isPaused || _isRoundFinished) {
      return;
    }

    if (_secondsRemaining <= 1) {
      setState(() {
        _secondsRemaining = 0;
        _isRoundFinished = true;
      });
      timer.cancel();
      return;
    }

    setState(() => _secondsRemaining -= 1);
  }

  void _togglePause() {
    if (_isRoundFinished) {
      return;
    }

    setState(() => _isPaused = !_isPaused);
  }

  void _startNextRound() {
    setState(() {
      _roundIndex += 1;
      _secondsRemaining = widget.settings.roundDuration.inSeconds;
      _isPaused = false;
      _isRoundFinished = false;
    });
    _startTimer();
  }

  void _showGameResult() {
    setState(() => _isGameFinished = true);
  }

  void _restartGame() {
    setState(() {
      _currentWordIndex = 0;
      _roundIndex = 0;
      _firstTeamScore = 0;
      _secondTeamScore = 0;
      _secondsRemaining = widget.settings.roundDuration.inSeconds;
      _isPaused = false;
      _isRoundFinished = false;
      _isGameFinished = false;
    });
    _startTimer();
  }

  void _handleCard({required bool isGuessed}) {
    if (_isPaused || _isRoundFinished) {
      return;
    }

    unawaited(isGuessed ? GameFeedback.guessed() : GameFeedback.skipped());

    setState(() {
      _lastActionWasGuess = isGuessed;
      if (isGuessed) {
        if (_isFirstTeamTurn) {
          _firstTeamScore += 1;
        } else {
          _secondTeamScore += 1;
        }
      }
      _currentWordIndex = (_currentWordIndex + 1) % widget.words.length;
    });
  }

  void _handleHorizontalDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity.abs() < 300) {
      return;
    }

    _handleCard(isGuessed: velocity > 0);
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _currentWord;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Вийти з гри',
        ),
        title: Text(
          'Раунд ${_roundIndex + 1} із ${widget.settings.roundCount}',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            ),
            onPressed: _isRoundFinished ? null : _togglePause,
            tooltip: _isPaused ? 'Продовжити' : 'Пауза',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Хід команди',
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '$_activeTeamName пояснює',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.settings.firstTeam.name}: $_firstTeamScore  •  '
                '${widget.settings.secondTeam.name}: $_secondTeamScore',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _formattedTime,
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              if (_isPaused)
                Text(
                  'Гра на паузі',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('game-card'),
                  onHorizontalDragEnd: _isPaused || _isRoundFinished
                      ? null
                      : _handleHorizontalDrag,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: _isRoundFinished
                            ? _isGameFinished
                                  ? _GameFinishedContent(
                                      firstTeamName:
                                          widget.settings.firstTeam.name,
                                      firstTeamScore: _firstTeamScore,
                                      secondTeamName:
                                          widget.settings.secondTeam.name,
                                      secondTeamScore: _secondTeamScore,
                                      onReplay: _restartGame,
                                      onReturnToSetup: () =>
                                          Navigator.of(context).pop(),
                                    )
                                  : _RoundFinishedContent(
                                      activeTeamName: _activeTeamName,
                                      activeTeamScore: _activeTeamScore,
                                      lastWord: currentWord.term,
                                      actionLabel: _isFinalRound
                                          ? 'Показати підсумок партії'
                                          : 'Наступний раунд',
                                      onAction: _isFinalRound
                                          ? _showGameResult
                                          : _startNextRound,
                                    )
                            : AnimatedSwitcher(
                                key: const ValueKey('word-transition'),
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, animation) {
                                  final offset =
                                      Tween<Offset>(
                                        begin: Offset(
                                          _lastActionWasGuess ? 0.12 : -0.12,
                                          0,
                                        ),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                      );

                                  return FadeTransition(
                                    opacity: animation,
                                    child: SlideTransition(
                                      position: offset,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Column(
                                  key: ValueKey(currentWord.id),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Термін',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      currentWord.term,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(fontSize: 40),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    Chip(
                                      label: Text(currentWord.category.label),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isPaused || _isRoundFinished
                          ? null
                          : () => _handleCard(isGuessed: false),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('Пропущено'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isPaused || _isRoundFinished
                          ? null
                          : () => _handleCard(isGuessed: true),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Вгадано'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.nativeCoreVersion != null)
                Text(
                  'C++ ядро v${widget.nativeCoreVersion} готове.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              if (widget.nativeCoreVersion != null) const SizedBox(height: 12),
              Text(
                'Свайп ліворуч — пропустити, праворуч — вгадано.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundFinishedContent extends StatelessWidget {
  const _RoundFinishedContent({
    required this.activeTeamName,
    required this.activeTeamScore,
    required this.lastWord,
    required this.actionLabel,
    required this.onAction,
  });

  final String activeTeamName;
  final int activeTeamScore;
  final String lastWord;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Час вийшов', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text('$activeTeamName: $activeTeamScore балів'),
        const SizedBox(height: 20),
        Text('Останній термін: $lastWord', textAlign: TextAlign.center),
        const SizedBox(height: 28),
        FilledButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _GameFinishedContent extends StatelessWidget {
  const _GameFinishedContent({
    required this.firstTeamName,
    required this.firstTeamScore,
    required this.secondTeamName,
    required this.secondTeamScore,
    required this.onReplay,
    required this.onReturnToSetup,
  });

  final String firstTeamName;
  final int firstTeamScore;
  final String secondTeamName;
  final int secondTeamScore;
  final VoidCallback onReplay;
  final VoidCallback onReturnToSetup;

  String get _winnerText {
    if (firstTeamScore == secondTeamScore) {
      return 'Нічия';
    }

    final winner = firstTeamScore > secondTeamScore
        ? firstTeamName
        : secondTeamName;
    return '$winner перемагає';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Партію завершено',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text('$firstTeamName: $firstTeamScore'),
        Text('$secondTeamName: $secondTeamScore'),
        const SizedBox(height: 20),
        Text(_winnerText, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 28),
        OutlinedButton(
          onPressed: onReplay,
          child: const Text('Зіграти ще раз'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onReturnToSetup,
          child: const Text('До налаштувань'),
        ),
      ],
    );
  }
}
