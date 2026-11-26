import 'package:flutter/material.dart';

import '../data/completed_game_store.dart';
import '../domain/completed_game.dart';
import '../domain/round_word_result.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  final _store = createCompletedGameStore();
  late Future<List<CompletedGame>> _games;

  @override
  void initState() {
    super.initState();
    _games = _store.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Історія ігор')),
      body: FutureBuilder<List<CompletedGame>>(
        future: _games,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Не вдалося прочитати історію ігор.'),
              ),
            );
          }

          final games = snapshot.data ?? const <CompletedGame>[];
          if (games.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Тут з’являться завершені партії.\nЗіграйте першу гру до кінця.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _CompletedGameCard(game: games[index]),
          );
        },
      ),
    );
  }
}

class _CompletedGameCard extends StatelessWidget {
  const _CompletedGameCard({required this.game});

  final CompletedGame game;

  String get _dateLabel {
    final date = game.completedAt;
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year} $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final winner = game.winnerName == 'Нічия'
        ? 'Нічия'
        : 'Переможець: ${game.winnerName}';
    return Card(
      child: ExpansionTile(
        title: Text(
          '${game.firstTeamName} ${game.firstTeamScore} : '
          '${game.secondTeamScore} ${game.secondTeamName}',
        ),
        subtitle: Text('$_dateLabel • $winner'),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Слова партії'),
          ),
          const SizedBox(height: 8),
          if (game.history.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Жодне слово не було оцінено.'),
            )
          else
            for (final result in game.history)
              _HistoryWordEntry(result: result),
        ],
      ),
    );
  }
}

class _HistoryWordEntry extends StatelessWidget {
  const _HistoryWordEntry({required this.result});

  final RoundWordResult result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(
            result.wasGuessed ? Icons.check_rounded : Icons.skip_next_rounded,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('${result.word.term} — ${result.teamName}')),
        ],
      ),
    );
  }
}
