import 'package:flutter/material.dart';

import '../data/completed_game_store.dart';
import '../domain/game_statistics.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final _store = createCompletedGameStore();
  late Future<GameStatistics> _statistics;

  @override
  void initState() {
    super.initState();
    _statistics = _loadStatistics();
  }

  Future<GameStatistics> _loadStatistics() async {
    final games = await _store.loadAll();
    return GameStatisticsCalculator.calculate(games);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: FutureBuilder<GameStatistics>(
        future: _statistics,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Не вдалося обчислити статистику.'),
              ),
            );
          }

          final statistics = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Ваш прогрес',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatisticTile(
                    label: 'Партій',
                    value: '${statistics.gamesPlayed}',
                  ),
                  _StatisticTile(
                    label: 'Вгадано',
                    value: '${statistics.guessedWords}',
                  ),
                  _StatisticTile(
                    label: 'Пропущено',
                    value: '${statistics.skippedWords}',
                  ),
                  _StatisticTile(
                    label: 'Точність',
                    value: '${statistics.accuracyPercent}%',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Рекорд партії: ${statistics.bestSingleGameScore}'),
                      const SizedBox(height: 8),
                      Text(
                        statistics.bestTeamName == null
                            ? 'Найрезультативніша команда з’явиться після першої партії.'
                            : 'Найрезультативніша команда: ${statistics.bestTeamName}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text('Досягнення', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                '${statistics.unlockedAchievementCount} із ${statistics.achievements.length} відкрито',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final achievement in statistics.achievements)
                _AchievementTile(achievement: achievement),
            ],
          );
        },
      ),
    );
  }
}

class _StatisticTile extends StatelessWidget {
  const _StatisticTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 60) / 2,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final AchievementProgress achievement;

  IconData get _icon => switch (achievement.id) {
    AchievementId.firstGame => Icons.rocket_launch_rounded,
    AchievementId.tenTerms => Icons.bolt_rounded,
    AchievementId.threeGames => Icons.groups_rounded,
    AchievementId.perfectRound => Icons.verified_rounded,
    AchievementId.fiftyTerms => Icons.menu_book_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = achievement.isUnlocked
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
    return Opacity(
      opacity: achievement.isUnlocked ? 1 : 0.55,
      child: Card(
        child: ListTile(
          leading: Icon(_icon, color: color),
          title: Text(achievement.title),
          subtitle: Text(achievement.description),
          trailing: Icon(
            achievement.isUnlocked
                ? Icons.lock_open_rounded
                : Icons.lock_rounded,
            color: color,
          ),
        ),
      ),
    );
  }
}
