import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  // Web: localhost (browser and server share the same host)
  // Android emulator: 10.0.2.2 → host localhost
  // Linux/Windows/macOS desktop or physical device: localhost or LAN IP
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5114';
    if (Platform.isAndroid) return 'http://10.0.2.2:5114';
    return 'http://localhost:5114';
  }

  static String get hubUrl => '$baseUrl/hubs/game';
}
