import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/widgets/timer_widget.dart';
import 'package:triviagame_flutter/widgets/leaderboard_widget.dart';

class GameScreen extends StatefulWidget {
  final String roomCode;
  final List<String> players;

  const GameScreen({super.key, required this.roomCode, required this.players});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Mockowane pytania
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Jaka jest stolica Francji?',
      'answers': ['Berlin', 'Madryt', 'Paryż', 'Rzym'],
      'correct': 2,
    },
    {
      'question': 'Ile wynosi 7 x 8?',
      'answers': ['54', '56', '58', '62'],
      'correct': 1,
    },
    {
      'question': 'Kto napisał "Pana Tadeusza"?',
      'answers': ['Słowacki', 'Mickiewicz', 'Norwid', 'Krasicki'],
      'correct': 1,
    },
    {
      'question': 'Który pierwiastek ma symbol Au?',
      'answers': ['Srebro', 'Aluminium', 'Złoto', 'Miedź'],
      'correct': 2,
    },
    {
      'question': 'W którym roku wybuchła II wojna światowa?',
      'answers': ['1937', '1938', '1939', '1940'],
      'correct': 2,
    },
  ];

  int _currentQuestion = 0;
  int _timeLeft = 30;
  int? _selectedAnswer;
  bool _answered = false;
  Timer? _timer;

  // Mockowane wyniki graczy
  late List<Map<String, dynamic>> _scores;

  @override
  void initState() {
    super.initState();
    _scores = widget.players.map((p) => {'nickname': p, 'score': 0}).toList();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 30;
      _selectedAnswer = null;
      _answered = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        _nextQuestion();
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    _timer?.cancel();
    setState(() {
      _selectedAnswer = index;
      _answered = true;
    });

    // Dodaj punkty jeśli poprawna odpowiedź
    if (index == _questions[_currentQuestion]['correct']) {
      setState(() {
        _scores[0]['score'] += _timeLeft * 10;
      });
    }

    // Mockuj odpowiedzi innych graczy
    for (int i = 1; i < _scores.length; i++) {
      if (i % 2 == 0) _scores[i]['score'] += 150;
    }

    Future.delayed(const Duration(seconds: 2), () {
  if (mounted) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LeaderboardWidget(
              scores: _scores,
              currentNickname: widget.players[0],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _nextQuestion();
              },
              child: const Text(
                'Następne pytanie',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
});
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
      _startTimer();
    } else {
      // Koniec gry
      _timer?.cancel();
      context.go('/summary', extra: {'scores': _scores});
    }
  }

  Color _getAnswerColor(int index) {
    if (!_answered) return Theme.of(context).colorScheme.surface;
    final correct = _questions[_currentQuestion]['correct'];
    if (index == correct) return Colors.green.shade700;
    if (index == _selectedAnswer) return Colors.red.shade700;
    return Theme.of(context).colorScheme.surface;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Pytanie ${_currentQuestion + 1}/${_questions.length}'),
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
              // Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [TimerWidget(timeLeft: _timeLeft, totalTime: 30)],
              ),
              const SizedBox(height: 24),
              // Pytanie
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question['question'],
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              // Odpowiedzi
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: List.generate(
                    4,
                    (index) => GestureDetector(
                      onTap: () => _selectAnswer(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: _getAnswerColor(index),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedAnswer == index && !_answered
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              question['answers'][index],
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
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
