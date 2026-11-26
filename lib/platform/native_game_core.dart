import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:ffi/ffi.dart';

import '../domain/game_word.dart';

final class _NativeWordInput extends Struct {
  external Pointer<Utf8> id;
}

class NativeGameCore {
  NativeGameCore._();

  static final instance = NativeGameCore._();

  DynamicLibrary? _library;

  int? get apiVersion {
    final library = _openLibrary();
    if (library == null) {
      return null;
    }

    try {
      final readVersion = library
          .lookupFunction<Int32 Function(), int Function()>(
            'devalias_game_core_api_version',
          );
      return readVersion();
    } on ArgumentError {
      return null;
    }
  }

  NativeGameSession? createSession({
    required List<GameWord> words,
    required int roundsPerTeam,
  }) {
    final library = _openLibrary();
    if (library == null || words.isEmpty || roundsPerTeam <= 0) {
      return null;
    }

    try {
      final createSession = library
          .lookupFunction<
            Pointer<Void> Function(
              Int32,
              Pointer<_NativeWordInput>,
              Int32,
              Uint32,
            ),
            Pointer<Void> Function(int, Pointer<_NativeWordInput>, int, int)
          >('devalias_game_session_create');
      final destroySession = library
          .lookupFunction<
            Void Function(Pointer<Void>),
            void Function(Pointer<Void>)
          >('devalias_game_session_destroy');
      final startTurn = library
          .lookupFunction<
            Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)
          >('devalias_game_session_start_turn');
      final guessWord = library
          .lookupFunction<
            Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)
          >('devalias_game_session_guess_word');
      final skipWord = library
          .lookupFunction<
            Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)
          >('devalias_game_session_skip_word');
      final finishTurn = library
          .lookupFunction<
            Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)
          >('devalias_game_session_finish_turn');
      final currentTeamIndex = library
          .lookupFunction<
            Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)
          >('devalias_game_session_current_team_index');
      final currentRound = library
          .lookupFunction<
            Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)
          >('devalias_game_session_current_round');
      final teamScore = library
          .lookupFunction<
            Int32 Function(Pointer<Void>, Int32),
            int Function(Pointer<Void>, int)
          >('devalias_game_session_team_score');
      final isFinished = library
          .lookupFunction<
            Int32 Function(Pointer<Void>),
            int Function(Pointer<Void>)
          >('devalias_game_session_is_finished');
      final currentWordId = library
          .lookupFunction<
            Pointer<Utf8> Function(Pointer<Void>),
            Pointer<Utf8> Function(Pointer<Void>)
          >('devalias_game_session_current_word_id');

      final inputs = calloc<_NativeWordInput>(words.length);
      final idPointers = <Pointer<Utf8>>[];
      try {
        for (var index = 0; index < words.length; index++) {
          final idPointer = words[index].id.toNativeUtf8();
          idPointers.add(idPointer);
          inputs[index].id = idPointer;
        }

        final handle = createSession(
          roundsPerTeam,
          inputs,
          words.length,
          20261126,
        );
        if (handle == nullptr) {
          return null;
        }

        return NativeGameSession._(
          handle: handle,
          destroy: destroySession,
          startTurn: startTurn,
          guessWord: guessWord,
          skipWord: skipWord,
          finishTurn: finishTurn,
          currentTeamIndex: currentTeamIndex,
          currentRound: currentRound,
          teamScore: teamScore,
          isFinished: isFinished,
          currentWordId: currentWordId,
        );
      } finally {
        for (final pointer in idPointers) {
          calloc.free(pointer);
        }
        calloc.free(inputs);
      }
    } on ArgumentError {
      return null;
    }
  }

  DynamicLibrary? _openLibrary() {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      return _library ??= DynamicLibrary.open('libdevalias_game_core.so');
    } on ArgumentError {
      return null;
    }
  }
}

class NativeGameSession {
  NativeGameSession._({
    required this._handle,
    required this._destroy,
    required this._startTurn,
    required this._guessWord,
    required this._skipWord,
    required this._finishTurn,
    required this._currentTeamIndex,
    required this._currentRound,
    required this._teamScore,
    required this._isFinished,
    required this._currentWordId,
  });

  Pointer<Void>? _handle;
  final void Function(Pointer<Void>) _destroy;
  final int Function(Pointer<Void>) _startTurn;
  final int Function(Pointer<Void>) _guessWord;
  final int Function(Pointer<Void>) _skipWord;
  final int Function(Pointer<Void>) _finishTurn;
  final int Function(Pointer<Void>) _currentTeamIndex;
  final int Function(Pointer<Void>) _currentRound;
  final int Function(Pointer<Void>, int) _teamScore;
  final int Function(Pointer<Void>) _isFinished;
  final Pointer<Utf8> Function(Pointer<Void>) _currentWordId;

  int get currentTeamIndex => _withHandle(_currentTeamIndex, fallback: -1);
  int get currentRound => _withHandle(_currentRound, fallback: 0);
  int scoreForTeam(int teamIndex) =>
      _withHandle((handle) => _teamScore(handle, teamIndex), fallback: 0);
  bool get isFinished => _withHandle(_isFinished, fallback: 1) == 1;

  String? get currentWordId {
    final handle = _handle;
    if (handle == null) {
      return null;
    }

    final pointer = _currentWordId(handle);
    return pointer == nullptr ? null : pointer.toDartString();
  }

  bool startTurn() => _withHandle(_startTurn, fallback: 0) == 1;
  bool guessWord() => _withHandle(_guessWord, fallback: 0) == 1;
  bool skipWord() => _withHandle(_skipWord, fallback: 0) == 1;
  bool finishTurn() => _withHandle(_finishTurn, fallback: 0) == 1;

  void dispose() {
    final handle = _handle;
    if (handle == null) {
      return;
    }

    _destroy(handle);
    _handle = null;
  }

  int _withHandle(int Function(Pointer<Void>) action, {required int fallback}) {
    final handle = _handle;
    return handle == null ? fallback : action(handle);
  }
}
