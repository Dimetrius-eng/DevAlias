import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/difficulty.dart';
import '../domain/game_word.dart';
import '../domain/word_category.dart';

class RemoteCategory {
  const RemoteCategory({
    required this.slug,
    required this.displayName,
    required this.wordCount,
  });

  final String slug;
  final String displayName;
  final int wordCount;

  factory RemoteCategory.fromJson(Map<String, Object?> json) {
    final slug = json['slug'];
    final displayName = json['display_name_uk'];
    final wordCount = json['word_count'];
    if (slug is! String || displayName is! String || wordCount is! int) {
      throw const FormatException('API returned an invalid category.');
    }
    return RemoteCategory(
      slug: slug,
      displayName: displayName,
      wordCount: wordCount,
    );
  }
}

class RemoteDictionaryException implements Exception {
  const RemoteDictionaryException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class DictionaryRemoteSource {
  Future<List<GameWord>> fetchDictionary();
}

class RemoteDictionaryApi implements DictionaryRemoteSource {
  RemoteDictionaryApi({required this.baseUri, http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final Uri baseUri;
  final http.Client _client;
  final bool _ownsClient;

  static RemoteDictionaryApi? fromEnvironment({http.Client? client}) {
    const value = String.fromEnvironment('DEVALIAS_API_BASE_URL');
    final address = value.trim();
    if (address.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(address);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException('DEVALIAS_API_BASE_URL is not a valid URL.');
    }
    return RemoteDictionaryApi(baseUri: uri, client: client);
  }

  Future<List<RemoteCategory>> fetchCategories() async {
    final response = await _client.get(_endpoint('categories'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('API returned an invalid categories list.');
    }
    return decoded
        .map((item) => RemoteCategory.fromJson(_jsonObject(item)))
        .toList(growable: false);
  }

  Future<GameWord> fetchRandomWord({
    Difficulty? difficulty,
    WordCategory? category,
  }) async {
    final queryParameters = <String, String>{
      if (difficulty != null) 'difficulty': difficulty.name,
      if (category != null) 'category': category.storageValue,
    };
    final response = await _client.get(
      _endpoint('words/random', queryParameters: queryParameters),
    );
    _ensureSuccess(response);
    return _gameWordFromJson(jsonDecode(response.body));
  }

  @override
  Future<List<GameWord>> fetchDictionary() async {
    final response = await _client.get(_endpoint('words'));
    _ensureSuccess(response);
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('API returned an invalid dictionary list.');
    }
    return decoded.map(_gameWordFromJson).toList(growable: false);
  }

  GameWord _gameWordFromJson(Object? value) {
    final json = _jsonObject(value);
    final sourceId = json['source_id'];
    final term = json['term'];
    final apiDifficulty = json['difficulty'];
    final categories = json['categories'];
    if (sourceId is! String ||
        term is! String ||
        apiDifficulty is! String ||
        categories is! List ||
        categories.isEmpty ||
        categories.first is! String) {
      throw const FormatException('API returned an invalid word.');
    }
    return GameWord(
      id: sourceId,
      term: term,
      difficulty: Difficulty.fromStorageValue(apiDifficulty),
      category: WordCategory.fromStorageValue(categories.first as String),
    );
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }

  Uri _endpoint(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = baseUri.path.endsWith('/')
        ? '${baseUri.path}$path'
        : '${baseUri.path}/$path';
    return baseUri.replace(
      path: normalizedPath,
      queryParameters: queryParameters,
    );
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RemoteDictionaryException(
        'Server returned HTTP ${response.statusCode}.',
      );
    }
  }

  static Map<String, Object?> _jsonObject(Object? value) {
    if (value is! Map) {
      throw const FormatException('API returned an invalid JSON object.');
    }
    return Map<String, Object?>.from(value);
  }
}
