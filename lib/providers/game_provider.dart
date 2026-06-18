import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/game_hub_service.dart';
import '../models/question_model.dart';

enum GamePhase { question, roundResult }

class GameState {
  final QuestionModel? currentQuestion;
  final int timeLeft;
  final String? selectedAnswer;
  final bool answered;
  final bool waitingForOthers;
  final GamePhase phase;
  final String? correctAnswer;
  final List<Map<String, dynamic>> scores;
  final bool showTimedOut;
  final bool waitingForNextQuestion;
  final List<dynamic>? gameEndedScores;
  final String? hubError;

  const GameState({
    this.currentQuestion,
    this.timeLeft = 30,
    this.selectedAnswer,
    this.answered = false,
    this.waitingForOthers = false,
    this.phase = GamePhase.question,
    this.correctAnswer,
    this.scores = const [],
    this.showTimedOut = false,
    this.waitingForNextQuestion = false,
    this.gameEndedScores,
    this.hubError,
  });

  GameState copyWith({
    QuestionModel? currentQuestion,
    int? timeLeft,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    bool? answered,
    bool? waitingForOthers,
    GamePhase? phase,
    String? correctAnswer,
    List<Map<String, dynamic>>? scores,
    bool? showTimedOut,
    bool? waitingForNextQuestion,
    List<dynamic>? gameEndedScores,
    String? hubError,
  }) {
    return GameState(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      timeLeft: timeLeft ?? this.timeLeft,
      selectedAnswer:
          clearSelectedAnswer ? null : selectedAnswer ?? this.selectedAnswer,
      answered: answered ?? this.answered,
      waitingForOthers: waitingForOthers ?? this.waitingForOthers,
      phase: phase ?? this.phase,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      scores: scores ?? this.scores,
      showTimedOut: showTimedOut ?? this.showTimedOut,
      waitingForNextQuestion:
          waitingForNextQuestion ?? this.waitingForNextQuestion,
      gameEndedScores: gameEndedScores ?? this.gameEndedScores,
      hubError: hubError ?? this.hubError,
    );
  }
}

class GameNotifier extends AutoDisposeNotifier<GameState> {
  Timer? _timer;
  String _roomCode = '';
  String _playerUuid = '';

  @override
  GameState build() {
    ref.onDispose(() {
      _timer?.cancel();
      if (state.gameEndedScores == null) {
        GameHubService.clearCallbacks();
        GameHubService.disconnect();
      }
    });
    return const GameState();
  }

  void init(
    String roomCode,
    String playerUuid,
    Map<String, dynamic> initialQuestion,
    List<Map<String, dynamic>> players,
  ) {
    _roomCode = roomCode;
    _playerUuid = playerUuid;

    final question = QuestionModel.fromJson(initialQuestion);
    final scores = players
        .map((p) => {
              'uuid': p['uuid'] as String,
              'nickname': p['displayName'] as String,
              'score': (p['points'] as int?) ?? 0,
            })
        .toList();

    state = state.copyWith(currentQuestion: question, scores: scores);
    _setupCallbacks();
    _startLocalTimer();
  }

  void _setupCallbacks() {
    GameHubService.onAnswerAccepted = () {
      state = state.copyWith(waitingForOthers: true);
    };

    GameHubService.onQuestionTimedOut = () {
      _timer?.cancel();
      state = state.copyWith(showTimedOut: true);
    };

    GameHubService.onRoundEnded = (data) {
      _timer?.cancel();
      final correctAnswer = data['correctAnswer'] as String;
      final rawScores = data['scores'] as List<dynamic>;
      final scores = rawScores
          .map((s) => {
                'uuid': (s as Map<String, dynamic>)['uuid'] as String,
                'nickname': s['displayName'] as String,
                'score': s['points'] as int,
              })
          .toList();

      state = state.copyWith(
        correctAnswer: correctAnswer,
        scores: scores,
        answered: false,
        waitingForOthers: false,
        showTimedOut: false,
        waitingForNextQuestion: false,
        phase: GamePhase.roundResult,
      );
    };

    GameHubService.onQuestionReceived = (data) {
      state = state.copyWith(currentQuestion: QuestionModel.fromJson(data));
      _startLocalTimer();
    };

    GameHubService.onGameEnded = (data) {
      state = state.copyWith(gameEndedScores: data);
    };

    GameHubService.onError = (error) {
      state = state.copyWith(hubError: error);
    };
  }

  void _startLocalTimer() {
    _timer?.cancel();
    state = state.copyWith(
      timeLeft: 30,
      clearSelectedAnswer: true,
      answered: false,
      waitingForOthers: false,
      showTimedOut: false,
      waitingForNextQuestion: false,
      phase: GamePhase.question,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft == 0) {
        timer.cancel();
      } else {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      }
    });
  }

  Future<void> selectAnswer(String answer) async {
    if (state.answered || state.waitingForOthers) return;
    state = state.copyWith(selectedAnswer: answer, answered: true);
    try {
      await GameHubService.submitAnswer(_roomCode, _playerUuid, answer);
    } catch (_) {
      state = state.copyWith(hubError: 'Nie udało się wysłać odpowiedzi.');
    }
  }

  Future<void> onNextQuestion() async {
    state = state.copyWith(waitingForNextQuestion: true);
    try {
      await GameHubService.playerReady(_roomCode, _playerUuid);
    } catch (_) {}
  }

  void disconnect() {
    GameHubService.disconnect();
  }
}

final gameProvider =
    AutoDisposeNotifierProvider<GameNotifier, GameState>(GameNotifier.new);
