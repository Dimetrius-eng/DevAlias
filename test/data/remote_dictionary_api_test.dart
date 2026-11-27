import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:devalias/data/remote_dictionary_api.dart';
import 'package:devalias/domain/difficulty.dart';
import 'package:devalias/domain/word_category.dart';

void main() {
  test('remote API reads categories from the server JSON', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'http://localhost:8000/categories');
      return http.Response.bytes(
        utf8.encode(
          '[{"slug":"databases","display_name_uk":"Бази даних","word_count":9}]',
        ),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final api = RemoteDictionaryApi(
      baseUri: Uri.parse('http://localhost:8000'),
      client: client,
    );

    final categories = await api.fetchCategories();

    expect(categories.single.slug, 'databases');
    expect(categories.single.displayName, 'Бази даних');
    expect(categories.single.wordCount, 9);
  });

  test('remote API sends random-word filters and maps the response', () async {
    final client = MockClient((request) async {
      expect(
        request.url.toString(),
        'http://localhost:8000/words/random?difficulty=hard&category=databases',
      );
      return http.Response.bytes(
        utf8.encode(
          '{"source_id":"hard-database-3","term":"Реплікація",'
          '"difficulty":"hard","categories":["databases"]}',
        ),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final api = RemoteDictionaryApi(
      baseUri: Uri.parse('http://localhost:8000'),
      client: client,
    );

    final word = await api.fetchRandomWord(
      difficulty: Difficulty.hard,
      category: WordCategory.databases,
    );

    expect(word.id, 'hard-database-3');
    expect(word.term, 'Реплікація');
    expect(word.difficulty, Difficulty.hard);
    expect(word.category, WordCategory.databases);
  });

  test('remote API explains a non-success server response', () async {
    final client = MockClient((request) async => http.Response('', 503));
    final api = RemoteDictionaryApi(
      baseUri: Uri.parse('http://localhost:8000'),
      client: client,
    );

    expect(api.fetchCategories(), throwsA(isA<RemoteDictionaryException>()));
  });

  test('remote API reads the complete published dictionary for sync', () async {
    final client = MockClient((request) async {
      expect(request.url.toString(), 'http://localhost:8000/words');
      return http.Response.bytes(
        utf8.encode(
          '[{"source_id":"easy-general-1","term":"Алгоритм",'
          '"difficulty":"easy","categories":["general_it"]}]',
        ),
        200,
        headers: const {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final api = RemoteDictionaryApi(
      baseUri: Uri.parse('http://localhost:8000'),
      client: client,
    );

    final words = await api.fetchDictionary();

    expect(words.single.id, 'easy-general-1');
    expect(words.single.term, 'Алгоритм');
    expect(words.single.difficulty, Difficulty.easy);
  });
}
