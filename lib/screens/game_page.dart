import 'package:flutter/material.dart';

import '../domain/game_settings.dart';
import '../domain/game_word.dart';

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
  var _score = 0;

  GameWord get _currentWord => widget.words[_currentWordIndex];

  void _handleCard({required bool isGuessed}) {
    setState(() {
      if (isGuessed) {
        _score += 1;
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
        title: Text('Раунд 1 із ${widget.settings.roundCount}'),
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
                '${widget.settings.firstTeam.name} пояснює',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Рахунок: $_score',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GestureDetector(
                  key: const ValueKey('game-card'),
                  onHorizontalDragEnd: _handleHorizontalDrag,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Термін',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentWord.term,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontSize: 40),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Chip(label: Text(currentWord.category.label)),
                        ],
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
                      onPressed: () => _handleCard(isGuessed: false),
                      icon: const Icon(Icons.skip_next_rounded),
                      label: const Text('Пропущено'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _handleCard(isGuessed: true),
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
