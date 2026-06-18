import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/providers/summary_provider.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> scores;
  final String? roomCode;
  final String? playerUuid;
  final String? nickname;
  final bool isHost;
  final int? categoryId;
  final String? categoryName;

  const SummaryScreen({
    super.key,
    required this.scores,
    this.roomCode,
    this.playerUuid,
    this.nickname,
    this.isHost = false,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(summaryProvider.notifier).init(
              widget.roomCode,
              widget.playerUuid,
              widget.categoryId,
              widget.isHost,
            );
      }
    });
  }

  void _leaveGame() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(summaryProvider);

    ref.listen(summaryProvider.select((s) => s.restartedData), (prev, next) {
      if (next != null) {
        String? catName;
        try {
          final cat = next['category'];
          catName = cat is Map
              ? cat['name'] as String?
              : (next['categoryName'] ?? next['category_name']) as String?;
        } catch (_) {}
        context.go('/lobby', extra: {
          'roomCode': next['joinCode'] as String,
          'nickname': widget.nickname,
          'isHost': widget.isHost,
          'playerUuid': widget.playerUuid,
          'categoryId': null,
          'categoryName': catName,
        });
      }
    });

    final sorted = [...widget.scores]
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final top3 = sorted.take(3).toList();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) GoRouter.of(context).go('/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Koniec gry!'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Text(
                  '🏆 Podium',
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (top3.length > 1)
                      _PodiumItem(
                        place: 2,
                        nickname: top3[1]['nickname'],
                        score: top3[1]['score'],
                        height: 100,
                        emoji: '🥈',
                      ),
                    const SizedBox(width: 8),
                    _PodiumItem(
                      place: 1,
                      nickname: top3[0]['nickname'],
                      score: top3[0]['score'],
                      height: 140,
                      emoji: '🥇',
                    ),
                    const SizedBox(width: 8),
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
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: sorted.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final player = sorted[index];
                        return Row(
                          children: [
                            Text(
                              '${index + 1}.',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
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
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: _leaveGame,
                  child: const Text(
                    'Powrót do menu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (widget.isHost && widget.roomCode != null) ...[
                  const SizedBox(height: 8),
                  if (state.categories.isNotEmpty)
                    DropdownButtonFormField<int?>(
                      initialValue: state.selectedCategoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Kategoria na następną grę',
                        prefixIcon: Icon(Icons.category_outlined),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Dowolna kategoria'),
                        ),
                        ...state.categories.map((cat) => DropdownMenuItem<int?>(
                              value: cat['id'] as int,
                              child: Text(cat['name'] as String),
                            )),
                      ],
                      onChanged: state.isRestarting
                          ? null
                          : (val) => ref
                              .read(summaryProvider.notifier)
                              .selectCategory(val),
                    ),
                  const SizedBox(height: 8),
                  state.isRestarting
                      ? const CircularProgressIndicator()
                      : OutlinedButton(
                          onPressed: () =>
                              ref.read(summaryProvider.notifier).playAgain(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Zagraj ponownie',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ] else if (!widget.isHost) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Oczekuję na hosta...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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
            color: Theme.of(context).colorScheme.primary.withValues(
                  alpha: place == 1 ? 1.0 : place == 2 ? 0.7 : 0.5,
                ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
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
