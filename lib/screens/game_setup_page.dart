import 'package:flutter/material.dart';

import '../data/asset_word_repository.dart';
import '../domain/difficulty.dart';
import '../domain/game_settings.dart';
import '../domain/team.dart';
import '../domain/word_category.dart';
import '../platform/native_game_core.dart';
import 'game_page.dart';

class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key});

  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  final _wordRepository = const AssetWordRepository();
  String _firstTeamName = 'Команда 1';
  String _secondTeamName = 'Команда 2';
  int _roundDurationSeconds = 60;
  int _roundCount = 3;
  Difficulty _difficulty = Difficulty.medium;
  final Set<WordCategory> _selectedCategories = {WordCategory.generalIt};

  GameSettings get _gameSettings {
    return GameSettings(
      firstTeam: Team(name: _firstTeamName),
      secondTeam: Team(name: _secondTeamName),
      roundDuration: Duration(seconds: _roundDurationSeconds),
      roundCount: _roundCount,
      difficulty: _difficulty,
      categories: _selectedCategories,
    );
  }

  Future<void> _startGame() async {
    final settings = _gameSettings;
    final words = await _wordRepository.loadForSettings(settings);

    if (!mounted) {
      return;
    }

    if (words.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Для вибраних налаштувань поки немає слів.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GamePage(
          settings: settings,
          words: words,
          nativeCoreVersion: NativeGameCore.instance.apiVersion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _gameSettings;

    return Scaffold(
      appBar: AppBar(title: const Text('Нова гра')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Налаштування гри',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Text('Команди', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _firstTeamName,
              decoration: const InputDecoration(
                labelText: 'Назва першої команди',
              ),
              textInputAction: TextInputAction.next,
              onChanged: (value) {
                setState(() => _firstTeamName = value.trim());
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _secondTeamName,
              decoration: const InputDecoration(
                labelText: 'Назва другої команди',
              ),
              onChanged: (value) {
                setState(() => _secondTeamName = value.trim());
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Тривалість раунду',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 30, label: Text('30 с')),
                ButtonSegment(value: 60, label: Text('60 с')),
                ButtonSegment(value: 90, label: Text('90 с')),
              ],
              selected: {_roundDurationSeconds},
              onSelectionChanged: (selection) {
                setState(() => _roundDurationSeconds = selection.first);
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Кількість раундів',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('1')),
                ButtonSegment(value: 3, label: Text('3')),
                ButtonSegment(value: 5, label: Text('5')),
              ],
              selected: {_roundCount},
              onSelectionChanged: (selection) {
                setState(() => _roundCount = selection.first);
              },
            ),
            const SizedBox(height: 32),
            Text('Складність', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SegmentedButton<Difficulty>(
              segments: const [
                ButtonSegment(value: Difficulty.easy, label: Text('Легка')),
                ButtonSegment(value: Difficulty.medium, label: Text('Середня')),
                ButtonSegment(value: Difficulty.hard, label: Text('Важка')),
              ],
              selected: {_difficulty},
              onSelectionChanged: (selection) {
                setState(() => _difficulty = selection.first);
              },
            ),
            const SizedBox(height: 32),
            Text('Категорії', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WordCategory.values.map((category) {
                return FilterChip(
                  label: Text(category.label),
                  selected: _selectedCategories.contains(category),
                  onSelected: (isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: settings.canStart ? _startGame : null,
              child: const Text('Почати гру'),
            ),
          ],
        ),
      ),
    );
  }
}
