import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:triviagame_flutter/core/services/game_hub_service.dart';
import 'package:triviagame_flutter/models/player_model.dart';
import 'package:triviagame_flutter/widgets/qr_widget.dart';

class LobbyScreen extends StatefulWidget {
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
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  List<PlayerModel> _players = [];
  bool _isConnecting = true;
  String? _errorMessage;
  bool _isStarting = false;
  bool _didNavigateToGame = false;
  String? _categoryName;

  @override
  void initState() {
    super.initState();
    _categoryName = widget.categoryName;
    _setupCallbacks();
    _connect();
  }

  void _setupCallbacks() {
    GameHubService.onConnectedToRoom = (data) {
      if (!mounted) return;
      final members = (data['members'] as List<dynamic>)
          .map((m) => PlayerModel.fromJson(m as Map<String, dynamic>))
          .toList();
      String? catName;
      try {
        final cat = data['category'];
        if (cat is Map) {
          catName = cat['name'] as String?;
        } else {
          catName = (data['categoryName'] ?? data['category_name']) as String?;
        }
      } catch (_) {}
      setState(() {
        _players = members;
        _isConnecting = false;
        if (catName != null) _categoryName = catName;
      });
    };

    GameHubService.onPlayerConnected = (data) {
      if (!mounted) return;
      final player = PlayerModel.fromJson(data);
      setState(() {
        if (!_players.any((p) => p.uuid == player.uuid)) {
          _players.add(player);
        }
      });
    };

    GameHubService.onPlayerDisconnected = (uuid) {
      if (!mounted) return;
      setState(() => _players.removeWhere((p) => p.uuid == uuid));
    };

    GameHubService.onRoomClosed = () {
      if (!mounted) return;
      GameHubService.clearCallbacks();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Host zamknął pokój.')),
      );
      GoRouter.of(context).go('/home');
    };

    GameHubService.onGameStarted = (data) {
      if (!mounted) return;
      _didNavigateToGame = true;
      context.go('/game', extra: {
        'roomCode': widget.roomCode,
        'playerUuid': widget.playerUuid,
        'nickname': widget.nickname,
        'isHost': widget.isHost,
        'categoryId': widget.categoryId,
        'categoryName': widget.categoryName,
        'players': _players.map((p) => {
              'uuid': p.uuid,
              'displayName': p.displayName,
              'points': p.points,
              'correctAnswers': p.correctAnswers,
            }).toList(),
        'initialQuestion': data,
      });
    };

    GameHubService.onError = (error) {
      if (!mounted) return;
      setState(() {
        _isStarting = false;
        _errorMessage = error;
      });
    };
  }

  Future<void> _connect() async {
    try {
      if (!GameHubService.isConnected) await GameHubService.connect();
      await GameHubService.connectToRoom(widget.roomCode, widget.playerUuid);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage =
              'Nie udało się połączyć z serwerem. Sprawdź połączenie.';
        });
      }
    }
  }

  Future<void> _startGame() async {
    setState(() {
      _isStarting = true;
      _errorMessage = null;
    });
    try {
      await GameHubService.startGame(widget.roomCode, widget.playerUuid);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isStarting = false;
          _errorMessage = 'Nie udało się rozpocząć gry.';
        });
      }
    }
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
        text:
            'Dołącz do mojego pokoju TriviaGame!\nKod: ${widget.roomCode}',
      ),
    );
  }

  @override
  void dispose() {
    if (!_didNavigateToGame) {
      GameHubService.clearCallbacks();
      GameHubService.disconnect();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              GameHubService.disconnect();
              router.go('/home');
            }
          });
        } else {
          GameHubService.disconnect();
          router.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lobby'),
          automaticallyImplyLeading: false,
        ),
      body: SafeArea(
        child: _isConnecting
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 32),
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
                    if (_categoryName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _categoryName!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
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
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _players.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = _players[index];
                          final isMe =
                              player.uuid == widget.playerUuid;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: isMe
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  color: isMe
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  player.displayName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isMe
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isMe
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                                if (index == 0) ...[
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      borderRadius:
                                          BorderRadius.circular(8),
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
                      _isStarting
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed:
                                  _players.length >= 2 ? _startGame : null,
                              child: const Text(
                                'Rozpocznij grę',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold),
                              ),
                            )
                    else
                      OutlinedButton(
                        onPressed: () {
                          GameHubService.disconnect();
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
