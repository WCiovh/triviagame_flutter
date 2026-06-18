import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/providers/game_provider.dart';
import 'package:triviagame_flutter/widgets/leaderboard_widget.dart';
import 'package:triviagame_flutter/widgets/timer_widget.dart';

class GameScreen extends ConsumerStatefulWidget {
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
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(gameProvider.notifier).init(
              widget.roomCode,
              widget.playerUuid,
              widget.initialQuestion,
              widget.players,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);

    ref.listen(gameProvider.select((s) => s.hubError), (prev, next) {
      if (next != null && next != prev) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(next)));
      }
    });

    ref.listen(gameProvider.select((s) => s.gameEndedScores), (prev, next) {
      if (next != null) {
        final summaryScores = next
            .map((p) => {
                  'nickname':
                      (p as Map<String, dynamic>)['displayName'] as String,
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
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final router = GoRouter.of(context);
        showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Opuścić grę?'),
            content: const Text('Twój postęp zostanie utracony.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Nie'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Tak'),
              ),
            ],
          ),
        ).then((confirmed) {
          if (confirmed == true && mounted) {
            ref.read(gameProvider.notifier).disconnect();
            router.go('/home');
          }
        });
      },
      child: state.phase == GamePhase.roundResult
          ? _buildRoundResult(context, state)
          : _buildQuestion(context, state),
    );
  }

  Widget _buildQuestion(BuildContext context, GameState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Pytanie ${question.index + 1}/${question.total}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Pokój: ${widget.roomCode}',
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
                  TimerWidget(timeLeft: state.timeLeft, totalTime: 30),
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
                      question.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.text,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (state.showTimedOut)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Czas minął!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              if (state.waitingForOthers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Czekam na pozostałych graczy...',
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
                  children: question.answers.map((answer) {
                    final isSelected = state.selectedAnswer == answer;
                    final bgColor = !state.answered
                        ? Theme.of(context).colorScheme.surface
                        : isSelected
                            ? Colors.blue.shade700
                            : Theme.of(context).colorScheme.surface;

                    return GestureDetector(
                      onTap: () => ref
                          .read(gameProvider.notifier)
                          .selectAnswer(answer),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected && !state.answered
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

  Widget _buildRoundResult(BuildContext context, GameState state) {
    final question = state.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    final isCorrect =
        state.selectedAnswer != null && state.selectedAnswer == state.correctAnswer;
    final didAnswer = state.selectedAnswer != null;

    final Color topColor = !didAnswer
        ? Colors.orange.shade800
        : isCorrect
            ? Colors.green.shade800
            : Colors.red.shade800;
    final String topLabel =
        !didAnswer ? 'Nie odpowiedziałeś' : 'Twoja odpowiedź';

    final currentNickname = widget.players.isNotEmpty
        ? widget.players.firstWhere(
            (p) => p['uuid'] == widget.playerUuid,
            orElse: () => {'displayName': ''},
          )['displayName'] as String
        : '';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Pytanie ${question.index + 1}/${question.total}'),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: topColor,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        Text(topLabel,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        if (didAnswer) ...[
                          const SizedBox(height: 4),
                          Text(
                            state.selectedAnswer ?? '',
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        const Text('Poprawna odpowiedź',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          state.correctAnswer ?? '',
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
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LeaderboardWidget(
                  scores: state.scores,
                  currentNickname: currentNickname,
                ),
              ),
              const SizedBox(height: 16),
              if (state.waitingForNextQuestion)
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
                      'Czekam na pozostałych graczy...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () =>
                      ref.read(gameProvider.notifier).onNextQuestion(),
                  child: const Text(
                    'Następne pytanie',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
