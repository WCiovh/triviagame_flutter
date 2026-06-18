import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/game_hub_repository.dart';
import '../models/player_model.dart';
import 'repository_providers.dart';

class LobbyState {
  final List<PlayerModel> players;
  final bool isConnecting;
  final String? errorMessage;
  final bool isStarting;
  final String? categoryName;
  final Map<String, dynamic>? gameStartData;
  final bool roomClosed;

  const LobbyState({
    this.players = const [],
    this.isConnecting = true,
    this.errorMessage,
    this.isStarting = false,
    this.categoryName,
    this.gameStartData,
    this.roomClosed = false,
  });

  LobbyState copyWith({
    List<PlayerModel>? players,
    bool? isConnecting,
    String? errorMessage,
    bool clearError = false,
    bool? isStarting,
    String? categoryName,
    Map<String, dynamic>? gameStartData,
    bool? roomClosed,
  }) {
    return LobbyState(
      players: players ?? this.players,
      isConnecting: isConnecting ?? this.isConnecting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isStarting: isStarting ?? this.isStarting,
      categoryName: categoryName ?? this.categoryName,
      gameStartData: gameStartData ?? this.gameStartData,
      roomClosed: roomClosed ?? this.roomClosed,
    );
  }
}

class LobbyNotifier extends AutoDisposeNotifier<LobbyState> {
  late GameHubRepository _hub;
  String _roomCode = '';
  String _playerUuid = '';

  @override
  LobbyState build() {
    _hub = ref.read(gameHubRepositoryProvider);
    ref.onDispose(() {
      if (state.gameStartData == null && !state.roomClosed) {
        _hub.clearCallbacks();
        _hub.disconnect();
      }
    });
    return const LobbyState();
  }

  Future<void> init(
      String roomCode, String playerUuid, String? categoryName) async {
    _roomCode = roomCode;
    _playerUuid = playerUuid;
    if (categoryName != null) {
      state = state.copyWith(categoryName: categoryName);
    }
    _setupCallbacks();
    await _connect();
  }

  void _setupCallbacks() {
    _hub.onConnectedToRoom = (data) {
      final members = (data['members'] as List<dynamic>)
          .map((m) => PlayerModel.fromJson(m as Map<String, dynamic>))
          .toList();
      String? catName;
      try {
        final cat = data['category'];
        catName = cat is Map
            ? cat['name'] as String?
            : (data['categoryName'] ?? data['category_name']) as String?;
      } catch (_) {}
      state = state.copyWith(
        players: members,
        isConnecting: false,
        categoryName: catName ?? state.categoryName,
      );
    };

    _hub.onPlayerConnected = (data) {
      final player = PlayerModel.fromJson(data);
      if (!state.players.any((p) => p.uuid == player.uuid)) {
        state = state.copyWith(players: [...state.players, player]);
      }
    };

    _hub.onPlayerDisconnected = (uuid) {
      state = state.copyWith(
        players: state.players.where((p) => p.uuid != uuid).toList(),
      );
    };

    _hub.onRoomClosed = () {
      _hub.clearCallbacks();
      state = state.copyWith(roomClosed: true);
    };

    _hub.onGameStarted = (data) {
      state = state.copyWith(gameStartData: data);
    };

    _hub.onError = (error) {
      state = state.copyWith(isStarting: false, errorMessage: error);
    };
  }

  Future<void> _connect() async {
    try {
      if (!_hub.isConnected) await _hub.connect();
      await _hub.connectToRoom(_roomCode, _playerUuid);
    } catch (_) {
      state = state.copyWith(
        isConnecting: false,
        errorMessage: 'Nie udało się połączyć z serwerem. Sprawdź połączenie.',
      );
    }
  }

  Future<void> startGame() async {
    state = state.copyWith(isStarting: true, clearError: true);
    try {
      await _hub.startGame(_roomCode, _playerUuid);
    } catch (_) {
      state = state.copyWith(
          isStarting: false, errorMessage: 'Nie udało się rozpocząć gry.');
    }
  }

  void disconnect() {
    _hub.disconnect();
  }
}

final lobbyProvider =
    AutoDisposeNotifierProvider<LobbyNotifier, LobbyState>(LobbyNotifier.new);
