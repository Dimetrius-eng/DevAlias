import 'difficulty.dart';
import 'game_settings.dart';
import 'game_word.dart';
import 'round_word_result.dart';
import 'team.dart';
import 'word_category.dart';

class SavedGame {
  SavedGame({
    required this.settings,
    required List<GameWord> words,
    required this.currentWordId,
    required this.roundIndex,
    required this.firstTeamScore,
    required this.secondTeamScore,
    required this.secondsRemaining,
    required this.isPaused,
    required this.isRoundFinished,
    required List<RoundWordResult> roundHistory,
    required List<RoundWordResult> gameHistory,
    required List<List<RoundWordResult>> completedRoundHistories,
  }) : words = List.unmodifiable(words),
       roundHistory = List.unmodifiable(roundHistory),
       gameHistory = List.unmodifiable(gameHistory),
       completedRoundHistories = List<List<RoundWordResult>>.unmodifiable(
         completedRoundHistories.map(
           (history) => List<RoundWordResult>.unmodifiable(history),
         ),
       );

  final GameSettings settings;
  final List<GameWord> words;
  final String currentWordId;
  final int roundIndex;
  final int firstTeamScore;
  final int secondTeamScore;
  final int secondsRemaining;
  final bool isPaused;
  final bool isRoundFinished;
  final List<RoundWordResult> roundHistory;
  final List<RoundWordResult> gameHistory;

  /// Actions from every finished turn, in their original order.
  ///
  /// This lets Lesson 20 rebuild the deterministic C++ deck precisely.
  final List<List<RoundWordResult>> completedRoundHistories;

  Map<String, Object?> toJson() {
    return {
      'settings': {
        'firstTeam': settings.firstTeam.name,
        'secondTeam': settings.secondTeam.name,
        'roundDurationSeconds': settings.roundDuration.inSeconds,
        'roundCount': settings.roundCount,
        'difficulty': settings.difficulty.name,
        'categories': settings.categories
            .map((category) => category.name)
            .toList(),
      },
      'words': words.map(_wordToJson).toList(),
      'currentWordId': currentWordId,
      'roundIndex': roundIndex,
      'firstTeamScore': firstTeamScore,
      'secondTeamScore': secondTeamScore,
      'secondsRemaining': secondsRemaining,
      'isPaused': isPaused,
      'isRoundFinished': isRoundFinished,
      'roundHistory': roundHistory.map(_resultToJson).toList(),
      'gameHistory': gameHistory.map(_resultToJson).toList(),
      'completedRoundHistories': completedRoundHistories
          .map((history) => history.map(_resultToJson).toList())
          .toList(),
    };
  }

  factory SavedGame.fromJson(Map<String, Object?> json) {
    final settingsJson = _map(json['settings']);
    final words = _list(json['words']).map(_wordFromJson).toList();
    final wordsById = {for (final word in words) word.id: word};

    return SavedGame(
      settings: GameSettings(
        firstTeam: Team(name: _string(settingsJson['firstTeam'])),
        secondTeam: Team(name: _string(settingsJson['secondTeam'])),
        roundDuration: Duration(
          seconds: _int(settingsJson['roundDurationSeconds']),
        ),
        roundCount: _int(settingsJson['roundCount']),
        difficulty: Difficulty.values.byName(
          _string(settingsJson['difficulty']),
        ),
        categories: _list(settingsJson['categories'])
            .map((value) => WordCategory.values.byName(_string(value)))
            .toSet(),
      ),
      words: words,
      currentWordId: _string(json['currentWordId']),
      roundIndex: _int(json['roundIndex']),
      firstTeamScore: _int(json['firstTeamScore']),
      secondTeamScore: _int(json['secondTeamScore']),
      secondsRemaining: _int(json['secondsRemaining']),
      isPaused: _bool(json['isPaused']),
      isRoundFinished: _bool(json['isRoundFinished']),
      roundHistory: _list(json['roundHistory'])
          .map((value) => _resultFromJson(value, wordsById))
          .toList(),
      gameHistory: _list(json['gameHistory'])
          .map((value) => _resultFromJson(value, wordsById))
          .toList(),
      completedRoundHistories: _list(json['completedRoundHistories'])
          .map(
            (history) =>
                _list(history)
                    .map((value) => _resultFromJson(value, wordsById))
                    .toList(),
          )
          .toList(),
    );
  }

  static Map<String, Object?> _wordToJson(GameWord word) {
    return {
      'id': word.id,
      'term': word.term,
      'difficulty': word.difficulty.name,
      'category': word.category.name,
    };
  }

  static GameWord _wordFromJson(Object? value) {
    final json = _map(value);
    return GameWord(
      id: _string(json['id']),
      term: _string(json['term']),
      difficulty: Difficulty.values.byName(_string(json['difficulty'])),
      category: WordCategory.values.byName(_string(json['category'])),
    );
  }

  static Map<String, Object?> _resultToJson(RoundWordResult result) {
    return {
      'wordId': result.word.id,
      'teamName': result.teamName,
      'outcome': result.outcome.name,
    };
  }

  static RoundWordResult _resultFromJson(
    Object? value,
    Map<String, GameWord> wordsById,
  ) {
    final json = _map(value);
    final wordId = _string(json['wordId']);
    final word = wordsById[wordId];
    if (word == null) {
      throw FormatException('Saved result references an unknown word: $wordId');
    }

    return RoundWordResult(
      word: word,
      teamName: _string(json['teamName']),
      outcome: WordOutcome.values.byName(_string(json['outcome'])),
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is! Map) {
      throw const FormatException('Saved game contains an invalid object.');
    }
    return Map<String, Object?>.from(value);
  }

  static List<Object?> _list(Object? value) {
    if (value is! List) {
      throw const FormatException('Saved game contains an invalid list.');
    }
    return List<Object?>.from(value);
  }

  static String _string(Object? value) {
    if (value is! String) {
      throw const FormatException('Saved game contains an invalid string.');
    }
    return value;
  }

  static int _int(Object? value) {
    if (value is! int) {
      throw const FormatException('Saved game contains an invalid integer.');
    }
    return value;
  }

  static bool _bool(Object? value) {
    if (value is! bool) {
      throw const FormatException('Saved game contains an invalid boolean.');
    }
    return value;
  }
}
