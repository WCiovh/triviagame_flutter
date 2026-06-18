import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:triviagame_flutter/providers/lobby_provider.dart';
import 'package:triviagame_flutter/models/player_model.dart';
import 'package:triviagame_flutter/widgets/qr_widget.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final String roomCode;
  final String nickname;
  final bool isHost;
  final String playerUuid;
  final int? categoryId;
  final String? categoryName;

  const LobbyScreen({
    super.key,
    required this.roomCode,
    required this.nickname,
    required this.isHost,
    required this.playerUuid,
    this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lobbyProvider.notifier).init(
              widget.roomCode,
              widget.playerUuid,
              widget.categoryName,
            );
      }
    });
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kod skopiowany!')),
    );
  }

  void _shareCode() {
    SharePlus.instance.share(
      ShareParams(
        text: 'Dołącz do mojego pokoju TriviaGame!\nKod: ${widget.roomCode}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lobbyProvider);

    ref.listen(lobbyProvider.select((s) => s.roomClosed), (prev, next) {
      if (next) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Host zamknął pokój.')),
        );
        GoRouter.of(context).go('/home');
      }
    });

    ref.listen(lobbyProvider.select((s) => s.gameStartData), (prev, next) {
      if (next != null) {
        final players = state.players
            .map((p) => {
                  'uuid': p.uuid,
                  'displayName': p.displayName,
                  'points': p.points,
                  'correctAnswers': p.correctAnswers,
                })
            .toList();
        context.go('/game', extra: {
          'roomCode': widget.roomCode,
          'playerUuid': widget.playerUuid,
          'nickname': widget.nickname,
          'isHost': widget.isHost,
          'categoryId': widget.categoryId,
          'categoryName': widget.categoryName,
          'players': players,
          'initialQuestion': next,
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (widget.isHost) {
          showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Zamknąć pokój?'),
              content: const Text('Wszyscy gracze zostaną rozłączeni.'),
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
              ref.read(lobbyProvider.notifier).disconnect();
              router.go('/home');
            }
          });
        } else {
          ref.read(lobbyProvider.notifier).disconnect();
          router.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lobby'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: state.isConnecting
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Łączenie z pokojem...'),
                    ],
                  ),
                )
              : Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Kod pokoju',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _copyCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.roomCode,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: 8,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(Icons.copy,
                                  color:
                                      Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Dotknij aby skopiować',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                title: const Text('Kod QR pokoju',
                                    textAlign: TextAlign.center),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    QrWidget(roomCode: widget.roomCode),
                                    const SizedBox(height: 16),
                                    Text(
                                      widget.roomCode,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 8,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Zamknij'),
                                  ),
                                ],
                              ),
                            ),
                            icon: const Icon(Icons.qr_code),
                            label: const Text('Pokaż QR'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: _shareCode,
                            icon: const Icon(Icons.share),
                            label: const Text('Udostępnij'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.categoryName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 14,
                                color:
                                    Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                state.categoryName!,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gracze (${state.players.length})',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (!widget.isHost)
                            Text(
                              'Czekam na hosta...',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          state.errorMessage!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.players.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final player = state.players[index];
                            final isMe = player.uuid == widget.playerUuid;
                            return _PlayerTile(
                                player: player,
                                isMe: isMe,
                                isFirst: index == 0);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (widget.isHost)
                        state.isStarting
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: state.players.length >= 2
                                    ? () => ref
                                        .read(lobbyProvider.notifier)
                                        .startGame()
                                    : null,
                                child: const Text(
                                  'Rozpocznij grę',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                      else
                        OutlinedButton(
                          onPressed: () {
                            ref.read(lobbyProvider.notifier).disconnect();
                            context.go('/home');
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            side: BorderSide(
                                color: Theme.of(context).colorScheme.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Opuść pokój',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final PlayerModel player;
  final bool isMe;
  final bool isFirst;

  const _PlayerTile({
    required this.player,
    required this.isMe,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            Icons.person,
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
          Text(
            player.displayName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
              color: isMe
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (isFirst) ...[
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Host',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
