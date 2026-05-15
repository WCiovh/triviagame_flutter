import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:triviagame_flutter/core/services/permission_service.dart';

class QrScannerScreen extends StatefulWidget {
  final String nickname;

  const QrScannerScreen({super.key, required this.nickname});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  bool _scanned = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await PermissionService.requestCameraPermission();
    if (!granted && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Brak uprawnień'),
          content: const Text(
            'Aplikacja potrzebuje dostępu do kamery aby skanować kody QR.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/join-room');
              },
              child: const Text('Anuluj'),
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

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _scanned = true);
    controller.stop();

    final roomCode = barcode!.rawValue!;

    if (mounted) {
      context.go('/lobby', extra: {
        'roomCode': roomCode,
        'nickname': widget.nickname,
        'isHost': false,
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
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
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
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
          // Instrukcja
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
                  Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}