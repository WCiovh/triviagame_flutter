import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConfig {
  static const String apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
  static String get baseUrl {
    if (kIsWeb) return 'https://trivia.arkadiuszcios.online';
    if (Platform.isAndroid) return 'https://trivia.arkadiuszcios.online';
    return 'https://trivia.arkadiuszcios.online';
  }

  static String get hubUrl => '$baseUrl/hubs/game';
}
