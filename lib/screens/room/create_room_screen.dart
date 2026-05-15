import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/widgets/loading_widget.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _nicknameController = TextEditingController();
  bool _isLoading = false;

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = List.generate(
      6,
      (i) => chars[DateTime.now().millisecondsSinceEpoch % chars.length],
    );
    return random.join();
  }

  void _createRoom() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Podaj swój nick!')));
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    final roomCode = _generateRoomCode();

    if (mounted) {
      setState(() => _isLoading = false);
      context.go(
        '/lobby',
        extra: {
          'roomCode': roomCode,
          'nickname': _nicknameController.text.trim(),
          'isHost': true,
        },
      );
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utwórz pokój'),
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
                'Jak masz na imię?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Twój nick będzie widoczny dla innych graczy.',
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
              const Spacer(),
              _isLoading
                  ? const LoadingWidget(message: 'Tworzenie pokoju...')
                  : ElevatedButton(
                      onPressed: _createRoom,
                      child: const Text(
                        'Utwórz pokój',
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
