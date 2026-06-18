import '../../core/errors/app_failure.dart';
import '../../core/services/connectivity_service.dart';
import '../../data/datasources/room_remote_datasource.dart';
import '../../domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource _dataSource;

  RoomRepositoryImpl(this._dataSource);

  @override
  Future<List<Map<String, dynamic>>> getCategories() {
    return _dataSource.getCategories();
  }

  @override
  Future<({String roomCode, String playerUuid})> createRoom(
    String ownerName, {
    int? categoryId,
  }) async {
    if (!await ConnectivityService.isOnline()) throw const NetworkFailure();
    return _dataSource.createRoom(ownerName, categoryId: categoryId);
  }

  @override
  Future<
      ({
        String roomCode,
        String playerUuid,
        int? categoryId,
        String? categoryName
      })> joinRoom(String joinCode, String displayName) async {
    if (!await ConnectivityService.isOnline()) throw const NetworkFailure();
    return _dataSource.joinRoom(joinCode, displayName);
  }
}
