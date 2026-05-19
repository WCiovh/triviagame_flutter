import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/widgets/loading_widget.dart';
import 'package:triviagame_flutter/widgets/error_widget.dart';
import 'package:triviagame_flutter/core/services/connectivity_service.dart';
import 'package:triviagame_flutter/core/services/room_api_service.dart';
import 'package:triviagame_flutter/widgets/offline_widget.dart';

class JoinRoomScreen extends StatefulWidget {
  const JoinRoomScreen({super.key});

  @override
  State<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final _nicknameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  void _joinRoom() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj swój nick!')),
      );
      return;
    }
    if (_roomCodeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kod pokoju musi mieć 6 znaków!')),
      );
      return;
    }

    final online = await ConnectivityService.isOnline();
    if (!online) {
      setState(() => _isOffline = true);
      return;
    }
    setState(() => _isOffline = false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roomCode = _roomCodeController.text.trim().toUpperCase();
      final result = await RoomApiService.joinRoom(
          roomCode, _nicknameController.text.trim());

      if (mounted) {
        context.go('/lobby', extra: {
          'roomCode': result.roomCode,
          'nickname': _nicknameController.text.trim(),
          'isHost': false,
          'playerUuid': result.playerUuid,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dołącz do pokoju'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dołącz do gry',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Podaj nick i kod pokoju aby dołączyć.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nicknameController,
                maxLength: 16,
                decoration: const InputDecoration(
                  labelText: 'Nick',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _roomCodeController,
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Kod pokoju',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  if (_nicknameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Najpierw podaj nick!')),
                    );
                    return;
                  }
                  context.go('/qr-scanner',
                      extra: {'nickname': _nicknameController.text.trim()});
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Skanuj kod QR'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              if (_errorMessage != null)
                AppErrorWidget(message: _errorMessage!, onRetry: _joinRoom),
              if (_isOffline) OfflineWidget(onRetry: _joinRoom),
              const Spacer(),
              _isLoading
                  ? const LoadingWidget(message: 'Dołączanie do pokoju...')
                  : ElevatedButton(
                      onPressed: _joinRoom,
                      child: const Text(
                        'Dołącz',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
