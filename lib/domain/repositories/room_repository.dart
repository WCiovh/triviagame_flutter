abstract class RoomRepository {
  Future<List<Map<String, dynamic>>> getCategories();

  Future<({String roomCode, String playerUuid})> createRoom(
    String ownerName, {
    int? categoryId,
  });

  Future<
      ({
        String roomCode,
        String playerUuid,
        int? categoryId,
        String? categoryName
      })> joinRoom(String joinCode, String displayName);
}
