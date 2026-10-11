import 'package:flutter/material.dart';

import '../domain/game_settings.dart';
import '../domain/game_word.dart';

class GamePage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final currentWord = words.first;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Вийти з гри',
        ),
        title: Text('Раунд 1 із ${settings.roundCount}'),
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
                '${settings.firstTeam.name} пояснює',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
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
              const SizedBox(height: 24),
              if (nativeCoreVersion != null)
                Text(
                  'C++ ядро v$nativeCoreVersion готове.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              if (nativeCoreVersion != null) const SizedBox(height: 12),
              Text(
                'Керування карткою додамо в Уроці 15.',
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
