import 'game_word.dart';

enum WordOutcome { guessed, skipped }

class RoundWordResult {
  const RoundWordResult({
    required this.word,
    required this.teamName,
    required this.outcome,
  });

  final GameWord word;
  final String teamName;
  final WordOutcome outcome;

  bool get wasGuessed => outcome == WordOutcome.guessed;
}
