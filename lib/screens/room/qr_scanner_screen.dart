import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:triviagame_flutter/core/errors/app_failure.dart';
import 'package:triviagame_flutter/core/services/permission_service.dart';
import 'package:triviagame_flutter/domain/repositories/room_repository.dart';
import 'package:triviagame_flutter/providers/repository_providers.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  final String nickname;

  const QrScannerScreen({super.key, required this.nickname});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _controller =
      MobileScannerController(autoStart: false);
  final TextEditingController _manualCodeController = TextEditingController();
  bool _scanned = false;
  bool _isJoining = false;
  String? _errorMessage;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionService.requestCameraPermission();
    if (!mounted) return;
    if (granted) {
      setState(() => _hasPermission = true);
      _controller.start();
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Brak uprawnień do kamery'),
          content: const Text(
            'Aplikacja potrzebuje dostępu do kamery aby skanować kody QR. '
            'Możesz też wpisać kod ręcznie poniżej.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                PermissionService.openSettings();
              },
              child: const Text('Otwórz ustawienia'),
            ),
          ],
        ),
      );
    }
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() {
      _scanned = true;
      _isJoining = true;
      _errorMessage = null;
    });
    _controller.stop();

    await _joinRoom(barcode!.rawValue!.toUpperCase());
    if (!_isJoining) _scanned = false;
  }

  Future<void> _joinWithManualCode() async {
    final code = _manualCodeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kod pokoju musi mieć 6 znaków!')),
      );
      return;
    }
    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });
    await _joinRoom(code);
  }

  Future<void> _joinRoom(String roomCode) async {
    final RoomRepository repo = ref.read(roomRepositoryProvider);
    try {
      final result = await repo.joinRoom(roomCode, widget.nickname);
      if (mounted) {
        context.go('/lobby', extra: {
          'roomCode': result.roomCode,
          'nickname': widget.nickname,
          'isHost': false,
          'playerUuid': result.playerUuid,
          'categoryId': result.categoryId,
          'categoryName': result.categoryName,
        });
      }
    } on AppFailure catch (f) {
      if (mounted) {
        setState(() {
          _isJoining = false;
          _errorMessage = f.message;
        });
        if (_hasPermission) _controller.start();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isJoining = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        if (_hasPermission) _controller.start();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skanuj kod QR'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/join-room'),
        ),
        actions: [
          if (_hasPermission && !_isJoining)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller.toggleTorch(),
            ),
        ],
      ),
      body: _hasPermission ? _buildCamera() : _buildManualFallback(),
    );
  }

  Widget _buildCamera() {
    return Stack(
      children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),
        Center(
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        if (_isJoining)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Dołączanie do pokoju...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        if (_errorMessage != null && !_isJoining)
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (!_isJoining)
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Text(
              'Skieruj kamerę na kod QR pokoju',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildManualFallback() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: Column(
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Brak dostępu do kamery',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Wpisz kod pokoju ręcznie aby dołączyć do gry.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _manualCodeController,
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
            decoration: const InputDecoration(
              labelText: 'Kod pokoju',
              prefixIcon: Icon(Icons.meeting_room_outlined),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          _isJoining
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _joinWithManualCode,
                  child: const Text(
                    'Dołącz do pokoju',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => PermissionService.openSettings(),
            icon: const Icon(Icons.settings_outlined),
            label: const Text('Otwórz ustawienia kamery'),
          ),
        ],
      ),
    );
  }
}
