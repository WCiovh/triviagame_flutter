import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/room_remote_datasource.dart';
import '../data/repositories/game_hub_repository_impl.dart';
import '../data/repositories/room_repository_impl.dart';
import '../domain/repositories/game_hub_repository.dart';
import '../domain/repositories/room_repository.dart';

final roomRepositoryProvider = Provider<RoomRepository>(
  (_) => RoomRepositoryImpl(RoomRemoteDataSource()),
);

final gameHubRepositoryProvider = Provider<GameHubRepository>(
  (_) => GameHubRepositoryImpl(),
);
