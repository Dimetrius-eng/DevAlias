import 'package:flutter/material.dart';

import 'data/unfinished_game_store.dart';
import 'domain/saved_game.dart';
import 'screens/game_page.dart';
import 'screens/game_history_page.dart';
import 'screens/game_setup_page.dart';
import 'screens/how_to_play_page.dart';
import 'screens/profile_page.dart';
import 'screens/statistics_page.dart';
import 'screens/server_dictionary_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DevAliasApp());
}

class DevAliasApp extends StatelessWidget {
  const DevAliasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevAlias',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const DevAliasHomePage(),
    );
  }
}

class DevAliasHomePage extends StatefulWidget {
  const DevAliasHomePage({super.key});

  @override
  State<DevAliasHomePage> createState() => _DevAliasHomePageState();
}

class _DevAliasHomePageState extends State<DevAliasHomePage> {
  final _unfinishedGameStore = createUnfinishedGameStore();
  SavedGame? _savedGame;

  @override
  void initState() {
    super.initState();
    _loadSavedGame();
  }

  Future<void> _loadSavedGame() async {
    try {
      final savedGame = await _unfinishedGameStore.load();
      if (mounted) {
        setState(() => _savedGame = savedGame);
      }
    } on Object {
      // The normal "New game" path remains available if local data is bad.
    }
  }

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => page));
  }

  Future<void> _continueGame() async {
    final savedGame = _savedGame;
    if (savedGame == null) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => GamePage(
          settings: savedGame.settings,
          words: savedGame.words,
          initialGame: savedGame,
        ),
      ),
    );
    await _loadSavedGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0, end: 1),
          builder: (context, animationValue, child) {
            return Opacity(
              opacity: animationValue,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - animationValue)),
                child: child,
              ),
            );
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DevAliasLogo(),
                const SizedBox(height: 24),
                Text(
                  'DevAlias',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'IT-гра для команд і справжніх девелоперів',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.offline_bolt_rounded,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Працює без інтернету',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                FilledButton(
                  onPressed: () => _openPage(context, const GameSetupPage()),
                  child: const Text('Нова гра'),
                ),
                if (_savedGame != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _continueGame,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Продовжити гру'),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openPage(context, const ProfilePage()),
                  icon: const Icon(Icons.person_rounded),
                  label: const Text('Мій профіль'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openPage(context, const GameHistoryPage()),
                  icon: const Icon(Icons.history_rounded),
                  label: const Text('Історія ігор'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _openPage(context, const StatisticsPage()),
                  icon: const Icon(Icons.insights_rounded),
                  label: const Text('Статистика'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openPage(context, const ServerDictionaryPage()),
                  icon: const Icon(Icons.cloud_sync_rounded),
                  label: const Text('Серверний словник'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _openPage(context, const HowToPlayPage()),
                  child: const Text('Як грати'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DevAliasLogo extends StatelessWidget {
  const _DevAliasLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Icon(
          Icons.terminal_rounded,
          color: Colors.white,
          size: 64,
        ),
      ),
    );
  }
}
