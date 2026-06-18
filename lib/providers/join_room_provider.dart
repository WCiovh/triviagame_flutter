import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/room_api_service.dart';

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
  @override
  JoinRoomState build() => const JoinRoomState();

  Future<JoinRoomResult?> joinRoom(String nickname, String roomCode) async {
    final online = await ConnectivityService.isOnline();
    if (!online) {
      state = state.copyWith(isOffline: true);
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true, isOffline: false);

    try {
      final result = await RoomApiService.joinRoom(
          roomCode.trim().toUpperCase(), nickname.trim());
      state = state.copyWith(isLoading: false);
      return JoinRoomResult(
        roomCode: result.roomCode,
        playerUuid: result.playerUuid,
        categoryId: result.categoryId,
        categoryName: result.categoryName,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
      return null;
    }
  }
}

final joinRoomProvider =
    AutoDisposeNotifierProvider<JoinRoomNotifier, JoinRoomState>(
  JoinRoomNotifier.new,
);
