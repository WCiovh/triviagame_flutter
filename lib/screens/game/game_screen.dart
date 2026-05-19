import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/core/services/game_hub_service.dart';
import 'package:triviagame_flutter/l10n/app_localizations.dart';
import 'package:triviagame_flutter/models/question_model.dart';
import 'package:triviagame_flutter/widgets/leaderboard_widget.dart';
import 'package:triviagame_flutter/widgets/timer_widget.dart';

enum _GamePhase { question, roundResult }

class GameScreen extends StatefulWidget {
  final String roomCode;
  final String playerUuid;
  final String nickname;
  final bool isHost;
  final int? categoryId;
  final String? categoryName;
  final List<Map<String, dynamic>> players;
  final Map<String, dynamic> initialQuestion;

  const GameScreen({
    super.key,
    required this.roomCode,
    required this.playerUuid,
    required this.nickname,
    required this.isHost,
    this.categoryId,
    this.categoryName,
    required this.players,
    required this.initialQuestion,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late QuestionModel _currentQuestion;
  int _timeLeft = 30;
  String? _selectedAnswer;
  bool _answered = false;
  bool _waitingForOthers = false;
  Timer? _timer;

  _GamePhase _phase = _GamePhase.question;
  String? _correctAnswer;
  List<Map<String, dynamic>> _scores = [];
  bool _showTimedOut = false;

  bool _waitingForNextQuestion = false;
  bool _didNavigateToSummary = false;

  @override
  void initState() {
    super.initState();
    _currentQuestion = QuestionModel.fromJson(widget.initialQuestion);
    _scores = widget.players
        .map((p) => {
              'uuid': p['uuid'] as String,
              'nickname': p['displayName'] as String,
              'score': (p['points'] as int?) ?? 0,
            })
        .toList();
    _setupCallbacks();
    _startLocalTimer();
  }

  void _setupCallbacks() {
    GameHubService.onAnswerAccepted = () {
      if (!mounted) return;
      setState(() {
        _waitingForOthers = true;
      });
    };

    GameHubService.onQuestionTimedOut = () {
      if (!mounted) return;
      setState(() {
        _showTimedOut = true;
        _timer?.cancel();
      });
    };

    GameHubService.onRoundEnded = (data) {
      if (!mounted) return;
      final correctAnswer = data['correctAnswer'] as String;
      final rawScores = data['scores'] as List<dynamic>;

      setState(() {
        _correctAnswer = correctAnswer;
        _scores = rawScores
            .map((s) => {
                  'uuid': (s as Map<String, dynamic>)['uuid'] as String,
                  'nickname': s['displayName'] as String,
                  'score': s['points'] as int,
                })
            .toList();
        _answered = false;
        _waitingForOthers = false;
        _showTimedOut = false;
        _waitingForNextQuestion = false;
        _phase = _GamePhase.roundResult;
        _timer?.cancel();
      });
    };

    GameHubService.onQuestionReceived = (data) {
      if (!mounted) return;
      _applyNextQuestion(data);
    };

    GameHubService.onGameEnded = (data) {
      if (!mounted) return;
      _didNavigateToSummary = true;
      final summaryScores = (data)
          .map((p) => {
                'nickname': (p as Map<String, dynamic>)['displayName'] as String,
                'score': p['points'] as int,
              })
          .toList();
      context.go('/summary', extra: {
        'scores': summaryScores,
        'roomCode': widget.roomCode,
        'playerUuid': widget.playerUuid,
        'nickname': widget.nickname,
        'isHost': widget.isHost,
        'categoryId': widget.categoryId,
        'categoryName': widget.categoryName,
      });
    };

    GameHubService.onError = (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    };
  }

  void _applyNextQuestion(Map<String, dynamic> data) {
    setState(() => _currentQuestion = QuestionModel.fromJson(data));
    _startLocalTimer();
  }

  void _startLocalTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
      _selectedAnswer = null;
      _answered = false;
      _waitingForOthers = false;
      _showTimedOut = false;
      _waitingForNextQuestion = false;
      _phase = _GamePhase.question;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
      } else {
        if (mounted) setState(() => _timeLeft--);
      }
    });
  }

  Future<void> _selectAnswer(String answer) async {
    if (_answered || _waitingForOthers) return;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });
    try {
      await GameHubService.submitAnswer(
          widget.roomCode, widget.playerUuid, answer);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.submitAnswerFailed)),
        );
      }
    }
  }

  Future<void> _onNextQuestion() async {
    setState(() => _waitingForNextQuestion = true);
    try {
      await GameHubService.playerReady(widget.roomCode, widget.playerUuid);
    } catch (_) {}
  }

  Widget _buildResultBanner(AppLocalizations l10n) {
    final isCorrect = _selectedAnswer != null && _selectedAnswer == _correctAnswer;
    final didAnswer = _selectedAnswer != null;

    final Color topColor = !didAnswer
        ? Colors.orange.shade800
        : isCorrect
            ? Colors.green.shade800
            : Colors.red.shade800;
    final String topLabel = !didAnswer ? l10n.didNotAnswer : l10n.yourAnswer;
    final String topValue = didAnswer ? (_selectedAnswer ?? '') : '';

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: topColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Text(topLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              if (didAnswer) ...[
                const SizedBox(height: 4),
                Text(
                  topValue,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade800,
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Text(l10n.correctAnswer,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                _correctAnswer ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAnswerColor(String answer) {
    if (_phase != _GamePhase.question) return Theme.of(context).colorScheme.surface;
    if (!_answered) return Theme.of(context).colorScheme.surface;
    if (answer == _selectedAnswer) {
      return Colors.blue.shade700;
    }
    return Theme.of(context).colorScheme.surface;
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_didNavigateToSummary) {
      GameHubService.clearCallbacks();
      GameHubService.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final router = GoRouter.of(context);
        showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.leaveGameTitle),
            content: Text(l10n.leaveGameContent),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.yes),
              ),
            ],
          ),
        ).then((confirmed) {
          if (confirmed == true && mounted) {
            GameHubService.disconnect();
            router.go('/home');
          }
        });
      },
      child: _phase == _GamePhase.roundResult
          ? _buildRoundResult(l10n)
          : _buildQuestion(l10n),
    );
  }

  Widget _buildQuestion(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.questionProgress(
            _currentQuestion.index + 1, _currentQuestion.total)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                l10n.roomLabel(widget.roomCode),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimerWidget(timeLeft: _timeLeft, totalTime: 30),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentQuestion.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentQuestion.text,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_showTimedOut)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.timeUp,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              if (_waitingForOthers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.waitingForOtherPlayers,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 14,
                    ),
                  ),
                ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: _currentQuestion.answers.map((answer) {
                    final isSelected = _selectedAnswer == answer;
                    return GestureDetector(
                      onTap: () => _selectAnswer(answer),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _getAnswerColor(answer),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected && !_answered
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              answer,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundResult(AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.questionProgress(
            _currentQuestion.index + 1, _currentQuestion.total)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              _buildResultBanner(l10n),
              const SizedBox(height: 24),
              Expanded(
                child: LeaderboardWidget(
                  scores: _scores,
                  currentNickname: widget.players.isNotEmpty
                      ? widget.players.firstWhere(
                          (p) => p['uuid'] == widget.playerUuid,
                          orElse: () => {'displayName': ''},
                        )['displayName'] as String
                      : '',
                ),
              ),
              const SizedBox(height: 16),
              if (_waitingForNextQuestion)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.waitingForOtherPlayers,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: _onNextQuestion,
                  child: Text(
                    l10n.nextQuestion,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
