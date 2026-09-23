import 'package:flutter/material.dart';

const _availableCategories = [
  'Загальні IT',
  'Мови програмування',
  'Веброзробка',
  'Бази даних',
];

class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key});

  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  String _firstTeamName = 'Команда 1';
  String _secondTeamName = 'Команда 2';
  int _roundDuration = 60;
  int _roundCount = 3;
  String _difficulty = 'Середній';
  final Set<String> _selectedCategories = {'Загальні IT'};

  void _showSettingsSummary() {
    final categories = _selectedCategories.join(', ');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Партія готова: $_firstTeamName проти $_secondTeamName, '
          '$_roundCount раунди по $_roundDuration с. Категорії: $categories.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onChanged: (value) => _firstTeamName = value.trim(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _secondTeamName,
              decoration: const InputDecoration(
                labelText: 'Назва другої команди',
              ),
              onChanged: (value) => _secondTeamName = value.trim(),
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
              selected: {_roundDuration},
              onSelectionChanged: (selection) {
                setState(() => _roundDuration = selection.first);
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
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Легка', label: Text('Легка')),
                ButtonSegment(value: 'Середній', label: Text('Середня')),
                ButtonSegment(value: 'Важка', label: Text('Важка')),
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
              children: _availableCategories.map((category) {
                return FilterChip(
                  label: Text(category),
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
              onPressed: _selectedCategories.isEmpty
                  ? null
                  : _showSettingsSummary,
              child: const Text('Почати гру'),
            ),
          ],
        ),
      ),
    );
  }
}
