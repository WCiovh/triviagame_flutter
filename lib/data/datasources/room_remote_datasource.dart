import '../../core/errors/app_failure.dart';
import '../../core/services/room_api_service.dart';

class RoomRemoteDataSource {
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      return await RoomApiService.getCategories();
    } on Exception catch (e) {
      throw UnknownFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<({String roomCode, String playerUuid})> createRoom(
    String ownerName, {
    int? categoryId,
  }) async {
    try {
      return await RoomApiService.createRoom(ownerName, categoryId: categoryId);
    } on Exception catch (e) {
      throw ServerFailure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<
      ({
        String roomCode,
        String playerUuid,
        int? categoryId,
        String? categoryName
      })> joinRoom(String joinCode, String displayName) async {
    try {
      return await RoomApiService.joinRoom(joinCode, displayName);
    } on Exception catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      if (msg.contains('nie istnieje')) throw NotFoundFailure(msg);
      throw ServerFailure(msg);
    }
  }
}
