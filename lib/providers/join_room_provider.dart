import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_failure.dart';
import '../domain/repositories/room_repository.dart';
import 'repository_providers.dart';

class JoinRoomState {
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;

  const JoinRoomState({
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
  });

  JoinRoomState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isOffline,
  }) {
    return JoinRoomState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}

class JoinRoomResult {
  final String roomCode;
  final String playerUuid;
  final int? categoryId;
  final String? categoryName;

  const JoinRoomResult({
    required this.roomCode,
    required this.playerUuid,
    this.categoryId,
    this.categoryName,
  });
}

class JoinRoomNotifier extends AutoDisposeNotifier<JoinRoomState> {
  late RoomRepository _repo;

  @override
  JoinRoomState build() {
    _repo = ref.read(roomRepositoryProvider);
    return const JoinRoomState();
  }

  Future<JoinRoomResult?> joinRoom(String nickname, String roomCode) async {
    state = state.copyWith(isLoading: true, clearError: true, isOffline: false);

    try {
      final result = await _repo.joinRoom(
          roomCode.trim().toUpperCase(), nickname.trim());
      state = state.copyWith(isLoading: false);
      return JoinRoomResult(
        roomCode: result.roomCode,
        playerUuid: result.playerUuid,
        categoryId: result.categoryId,
        categoryName: result.categoryName,
      );
    } on NetworkFailure {
      state = state.copyWith(isLoading: false, isOffline: true);
      return null;
    } on AppFailure catch (f) {
      state = state.copyWith(isLoading: false, errorMessage: f.message);
      return null;
    }
  }
}

final joinRoomProvider =
    AutoDisposeNotifierProvider<JoinRoomNotifier, JoinRoomState>(
  JoinRoomNotifier.new,
);
