import 'package:flutter/material.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> scores;
  final String currentNickname;

  const LeaderboardWidget({
    super.key,
    required this.scores,
    required this.currentNickname,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...scores]
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final top5 = sorted.take(5).toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Ranking',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ...top5.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final isMe = player['nickname'] == currentNickname;

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Pozycja
                  SizedBox(
                    width: 32,
                    child: Text(
                      _getMedal(index),
                      style: const TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nick
                  Expanded(
                    child: Text(
                      player['nickname'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isMe ? FontWeight.bold : FontWeight.normal,
                        color: isMe
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // Punkty
                  Text(
                    '${player['score']} pkt',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getMedal(int index) {
    switch (index) {
      case 0:
        return '🥇';
      case 1:
        return '🥈';
      case 2:
        return '🥉';
      default:
        return '${index + 1}.';
    }
  }
}