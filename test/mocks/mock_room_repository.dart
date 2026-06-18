import 'package:triviagame_flutter/core/errors/app_failure.dart';
import 'package:triviagame_flutter/domain/repositories/room_repository.dart';

class MockRoomRepository implements RoomRepository {
  List<Map<String, dynamic>> categoriesResult = [];
  AppFailure? failureToThrow;
  String nextRoomCode = 'TST001';
  String nextPlayerUuid = 'player-uuid-1';

  int createRoomCallCount = 0;
  int joinRoomCallCount = 0;

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return categoriesResult;
  }

  @override
  Future<({String roomCode, String playerUuid})> createRoom(
    String ownerName, {
    int? categoryId,
  }) async {
    createRoomCallCount++;
    if (failureToThrow != null) throw failureToThrow!;
    return (roomCode: nextRoomCode, playerUuid: nextPlayerUuid);
  }

  @override
  Future<
      ({
        String roomCode,
        String playerUuid,
        int? categoryId,
        String? categoryName
      })> joinRoom(String joinCode, String displayName) async {
    joinRoomCallCount++;
    if (failureToThrow != null) throw failureToThrow!;
    return (
      roomCode: joinCode,
      playerUuid: nextPlayerUuid,
      categoryId: null,
      categoryName: null,
    );
  }
}
