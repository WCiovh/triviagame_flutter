import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/widgets/qr_widget.dart';
import 'package:share_plus/share_plus.dart';

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  final String nickname;
  final bool isHost;

  const LobbyScreen({
    super.key,
    required this.roomCode,
    required this.nickname,
    required this.isHost,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final List<String> _players = [];

  @override
  void initState() {
    super.initState();
    _players.add(widget.nickname);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _players.addAll(['Gracz2', 'Gracz3']));
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

  void _startGame() {
    context.go(
      '/game',
      extra: {'roomCode': widget.roomCode, 'players': _players},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Kod pokoju', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _copyCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
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
                      Icon(
                        Icons.copy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dotknij aby skopiować',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          title: const Text(
                            'Kod QR pokoju',
                            textAlign: TextAlign.center,
                          ),
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
                                  color:
                                      Theme.of(context).colorScheme.primary,
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
                      );
                    },
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gracze (${_players.length})',
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
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: _players.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final isMe = _players[index] == widget.nickname;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: isMe
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              )
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
                            _players[index],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isMe
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isMe
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          if (index == 0) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
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
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (widget.isHost)
                ElevatedButton(
                  onPressed: _players.length >= 2 ? _startGame : null,
                  child: const Text(
                    'Rozpocznij grę',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
    );
  }
}