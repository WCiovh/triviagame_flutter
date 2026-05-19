import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/l10n/app_localizations.dart';
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
  static String _savedNickname = '';

  late final TextEditingController _nicknameController;
  late final TextEditingController _roomCodeController;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: _savedNickname);
    _roomCodeController = TextEditingController();
  }

  void _joinRoom() async {
    final l10n = AppLocalizations.of(context)!;
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterNickname)),
      );
      return;
    }
    if (_roomCodeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.roomCodeMustBe6)),
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
          'categoryId': result.categoryId,
          'categoryName': result.categoryName,
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
    _savedNickname = _nicknameController.text;
    _nicknameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.joinRoom),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.joinGame,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.enterNicknameAndCode,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _nicknameController,
                        maxLength: 16,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.nickLabel,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _roomCodeController,
                        maxLength: 6,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.roomCodeLabel,
                          prefixIcon: const Icon(Icons.meeting_room_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          if (_nicknameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.enterNicknameFirst)),
                            );
                            return;
                          }
                          context.go('/qr-scanner',
                              extra: {'nickname': _nicknameController.text.trim()});
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text(l10n.scanQrCode),
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
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: _isLoading
                    ? LoadingWidget(message: l10n.joiningRoom)
                    : ElevatedButton(
                        onPressed: _joinRoom,
                        child: Text(
                          l10n.join,
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
