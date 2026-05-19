import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RoomApiService {
  static Future<({String roomCode, String playerUuid})> createRoom(
      String ownerName) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/rooms'),
      headers: {
        'Content-Type': 'application/json',
        if (AppConfig.apiKey.isNotEmpty) 'X-Api-Key': AppConfig.apiKey,
      },
      body: jsonEncode({
        'ownerName': ownerName,
        'amount': 10,
        'categoryId': null,
        'type': 'multiple',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Nie udało się utworzyć pokoju (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final owner = data['owner'] as Map<String, dynamic>;
    return (
      roomCode: data['joinCode'] as String,
      playerUuid: owner['uuid'] as String,
    );
  }

  static Future<({String roomCode, String playerUuid})> joinRoom(
      String joinCode, String displayName) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/rooms/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'joinCode': joinCode, 'displayName': displayName}),
    );

    if (response.statusCode == 404) {
      throw Exception('Pokój "$joinCode" nie istnieje');
    }
    if (response.statusCode != 200) {
      throw Exception('Nie udało się dołączyć do pokoju (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      roomCode: joinCode,
      playerUuid: data['yourPlayerUuid'] as String,
    );
  }
}
