import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class RoomApiService {
  static Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/api/trivia/categories'),
      headers: {
        if (AppConfig.apiKey.isNotEmpty) 'X-Api-Key': AppConfig.apiKey,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Nie udało się pobrać kategorii');
    }
    final body = jsonDecode(response.body);
    final List<dynamic> raw;
    if (body is List) {
      raw = body;
    } else if (body is Map) {
      final listVal = body['trivia_categories'] ??
          body['categories'] ??
          body['data'] ??
          [];
      raw = listVal as List<dynamic>;
    } else {
      return [];
    }
    return raw.map((e) {
      final m = e as Map<String, dynamic>;
      final id = (m['id'] ?? m['categoryId'] ?? m['trivia_category_id']) as int;
      final name = (m['name'] ?? m['categoryName'] ?? m['trivia_category']) as String;
      return {'id': id, 'name': name};
    }).toList();
  }

  static Future<({String roomCode, String playerUuid})> createRoom(
      String ownerName, {int? categoryId}) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/rooms'),
      headers: {
        'Content-Type': 'application/json',
        if (AppConfig.apiKey.isNotEmpty) 'X-Api-Key': AppConfig.apiKey,
      },
      body: jsonEncode({
        'ownerName': ownerName,
        'amount': 10,
        'categoryId': categoryId,
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

  static Future<({String roomCode, String playerUuid, int? categoryId, String? categoryName})> joinRoom(
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
    final room = data['room'] as Map<String, dynamic>?;

    int? categoryId;
    String? categoryName;
    if (room != null) {
      final cat = room['category'];
      if (cat is Map) {
        categoryId = cat['id'] as int?;
        categoryName = cat['name'] as String?;
      } else {
        categoryId = (room['categoryId'] ?? room['category_id']) as int?;
        categoryName = (room['categoryName'] ?? room['category_name']) as String?;
      }
    }

    return (
      roomCode: joinCode,
      playerUuid: data['yourPlayerUuid'] as String,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }
}
