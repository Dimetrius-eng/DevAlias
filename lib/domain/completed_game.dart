import 'difficulty.dart';
import 'game_word.dart';
import 'round_word_result.dart';
import 'word_category.dart';

/// An immutable record of a completed local party.
class CompletedGame {
  CompletedGame({
    this.id,
    required this.completedAt,
    required this.firstTeamName,
    required this.secondTeamName,
    required this.firstTeamScore,
    required this.secondTeamScore,
    required List<RoundWordResult> history,
  }) : history = List.unmodifiable(history);

  final int? id;
  final DateTime completedAt;
  final String firstTeamName;
  final String secondTeamName;
  final int firstTeamScore;
  final int secondTeamScore;
  final List<RoundWordResult> history;

  String get winnerName {
    if (firstTeamScore == secondTeamScore) {
      return 'Нічия';
    }
    return firstTeamScore > secondTeamScore ? firstTeamName : secondTeamName;
  }

  Map<String, Object?> toJson() {
    return {
      'completedAt': completedAt.toUtc().millisecondsSinceEpoch,
      'firstTeamName': firstTeamName,
      'secondTeamName': secondTeamName,
      'firstTeamScore': firstTeamScore,
      'secondTeamScore': secondTeamScore,
      'history': history.map(_resultToJson).toList(),
    };
  }

  factory CompletedGame.fromJson(Map<String, Object?> json, {int? id}) {
    return CompletedGame(
      id: id,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        _int(json['completedAt']),
        isUtc: true,
      ).toLocal(),
      firstTeamName: _string(json['firstTeamName']),
      secondTeamName: _string(json['secondTeamName']),
      firstTeamScore: _int(json['firstTeamScore']),
      secondTeamScore: _int(json['secondTeamScore']),
      history: _list(json['history']).map(_resultFromJson).toList(),
    );
  }

  static Map<String, Object?> _resultToJson(RoundWordResult result) {
    return {
      'teamName': result.teamName,
      'outcome': result.outcome.name,
      'word': {
        'id': result.word.id,
        'term': result.word.term,
        'difficulty': result.word.difficulty.name,
        'category': result.word.category.name,
      },
    };
  }

  static RoundWordResult _resultFromJson(Object? value) {
    final json = _map(value);
    final wordJson = _map(json['word']);
    return RoundWordResult(
      word: GameWord(
        id: _string(wordJson['id']),
        term: _string(wordJson['term']),
        difficulty: Difficulty.values.byName(_string(wordJson['difficulty'])),
        category: WordCategory.values.byName(_string(wordJson['category'])),
      ),
      teamName: _string(json['teamName']),
      outcome: WordOutcome.values.byName(_string(json['outcome'])),
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is! Map) {
      throw const FormatException('Invalid saved game data.');
    }
    return Map<String, Object?>.from(value);
  }

  static List<Object?> _list(Object? value) {
    if (value is! List) {
      throw const FormatException('Invalid saved game data.');
    }
    return List<Object?>.from(value);
  }

  static String _string(Object? value) {
    if (value is! String) {
      throw const FormatException('Invalid saved game data.');
    }
    return value;
  }

  static int _int(Object? value) {
    if (value is! int) {
      throw const FormatException('Invalid saved game data.');
    }
    return value;
  }
}
