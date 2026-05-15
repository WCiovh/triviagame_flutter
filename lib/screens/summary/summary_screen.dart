import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SummaryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> scores;

  const SummaryScreen({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    final sorted = [...scores]
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final top3 = sorted.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koniec gry!'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                '🏆 Podium',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Podium
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 2 miejsce
                  if (top3.length > 1)
                    _PodiumItem(
                      place: 2,
                      nickname: top3[1]['nickname'],
                      score: top3[1]['score'],
                      height: 100,
                      emoji: '🥈',
                    ),
                  const SizedBox(width: 8),
                  // 1 miejsce
                  _PodiumItem(
                    place: 1,
                    nickname: top3[0]['nickname'],
                    score: top3[0]['score'],
                    height: 140,
                    emoji: '🥇',
                  ),
                  const SizedBox(width: 8),
                  // 3 miejsce
                  if (top3.length > 2)
                    _PodiumItem(
                      place: 3,
                      nickname: top3[2]['nickname'],
                      score: top3[2]['score'],
                      height: 80,
                      emoji: '🥉',
                    ),
                ],
              ),
              const SizedBox(height: 32),
              // Pełny ranking
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sorted.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final player = sorted[index];
                      return Row(
                        children: [
                          Text(
                            '${index + 1}.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              player['nickname'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Text(
                            '${player['score']} pkt',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text(
                  'Powrót do menu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => context.go('/create-room'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Zagraj ponownie',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
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

class _PodiumItem extends StatelessWidget {
  final int place;
  final String nickname;
  final int score;
  final double height;
  final String emoji;

  const _PodiumItem({
    required this.place,
    required this.nickname,
    required this.score,
    required this.height,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          nickname,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$score pkt',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(
              place == 1
                  ? 1.0
                  : place == 2
                  ? 0.7
                  : 0.5,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '$place',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
