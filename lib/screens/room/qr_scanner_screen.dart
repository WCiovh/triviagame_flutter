import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:triviagame_flutter/core/services/permission_service.dart';
import 'package:triviagame_flutter/core/services/room_api_service.dart';
import 'package:triviagame_flutter/l10n/app_localizations.dart';

class QrScannerScreen extends StatefulWidget {
  final String nickname;

  const QrScannerScreen({super.key, required this.nickname});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller =
      MobileScannerController(autoStart: false);
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
    if (granted && mounted) {
      setState(() => _hasPermission = true);
      _controller.start();
      return;
    }
    if (!granted && mounted) {
      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(l10n.noPermissions),
          content: Text(l10n.cameraPermissionNeeded),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/join-room');
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                PermissionService.openSettings();
              },
              child: Text(l10n.openSettings),
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

    final roomCode = barcode!.rawValue!.toUpperCase();

    try {
      final result =
          await RoomApiService.joinRoom(roomCode, widget.nickname);
      if (mounted) {
        context.go('/lobby', extra: {
          'roomCode': result.roomCode,
          'nickname': widget.nickname,
          'isHost': false,
          'playerUuid': result.playerUuid,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanned = false;
          _isJoining = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        _controller.start();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanQrCode),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/join-room'),
        ),
        actions: [
          if (!_isJoining)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () => _controller.toggleTorch(),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_hasPermission)
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
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      l10n.joiningRoom,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
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
                l10n.pointCameraAtQr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        color: Colors.black.withValues(alpha: 0.8), blurRadius: 8),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
