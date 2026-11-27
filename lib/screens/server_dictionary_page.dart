import 'package:flutter/material.dart';

import '../data/remote_dictionary_api.dart';
import '../domain/game_word.dart';

class ServerDictionaryPage extends StatefulWidget {
  const ServerDictionaryPage({super.key, this.api});

  final RemoteDictionaryApi? api;

  @override
  State<ServerDictionaryPage> createState() => _ServerDictionaryPageState();
}

class _ServerDictionaryPageState extends State<ServerDictionaryPage> {
  late final RemoteDictionaryApi? _api;
  var _isLoading = false;
  String? _error;
  List<RemoteCategory>? _categories;
  GameWord? _randomWord;

  @override
  void initState() {
    super.initState();
    try {
      _api = widget.api ?? RemoteDictionaryApi.fromEnvironment();
    } on FormatException catch (error) {
      _api = null;
      _error = error.message;
    }
  }

  @override
  void dispose() {
    if (widget.api == null) {
      _api?.close();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final api = _api;
    if (api == null) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final categories = await api.fetchCategories();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = 'Не вдалося отримати категорії: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadRandomWord() async {
    final api = _api;
    if (api == null) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final word = await api.fetchRandomWord();
      if (mounted) {
        setState(() => _randomWord = word);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() => _error = 'Не вдалося отримати слово: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = _api;
    return Scaffold(
      appBar: AppBar(title: const Text('Серверний словник')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Підключення до API',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            if (api == null)
              const _ApiSetupGuide()
            else ...[
              Text('Адреса: ${api.baseUri}'),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadCategories,
                icon: const Icon(Icons.category_rounded),
                label: const Text('Отримати категорії'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isLoading ? null : _loadRandomWord,
                icon: const Icon(Icons.casino_rounded),
                label: const Text('Отримати випадкове слово'),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ],
              if (_error != null) ...[
                const SizedBox(height: 24),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_categories != null) ...[
                const SizedBox(height: 28),
                Text(
                  'Категорії',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                for (final category in _categories!)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(category.displayName),
                    trailing: Text('${category.wordCount} слів'),
                  ),
              ],
              if (_randomWord != null) ...[
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Випадкове слово',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _randomWord!.term,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_randomWord!.difficulty.label} • '
                          '${_randomWord!.category.label}',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _ApiSetupGuide extends StatelessWidget {
  const _ApiSetupGuide();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Адресу API ще не задано. Для локальної перевірки запустіть сервер на ПК, '
      'а Flutter — з параметром:\n\n'
      'flutter run --dart-define=DEVALIAS_API_BASE_URL=http://192.168.x.x:8000\n\n'
      'На телефоні використовуйте локальну IP-адресу ПК у вашій Wi-Fi мережі, '
      'а не localhost. Повна синхронізація словника в офлайн-кеш буде в Уроці 31.',
    );
  }
}
