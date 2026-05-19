import 'dart:io' show Platform;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ConnectivityService {
  static Future<bool> isOnline() async {
    if (kIsWeb || Platform.isLinux) return true;
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  static Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Connectivity().onConnectivityChanged;
}
