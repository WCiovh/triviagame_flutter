import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5114';
    if (Platform.isAndroid) return 'http://localhost:5114';
    return 'http://localhost:5114';
  }

  static String get hubUrl {
    final base = '$baseUrl/hubs/game';
    return apiKey.isNotEmpty ? '$base?api-key=$apiKey' : base;
  }
}
