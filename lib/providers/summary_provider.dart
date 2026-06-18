import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/game_hub_service.dart';
import '../core/services/room_api_service.dart';

class SummaryState {
  final bool isRestarting;
  final String? errorMessage;
  final List<Map<String, dynamic>> categories;
  final int? selectedCategoryId;
  final Map<String, dynamic>? restartedData;

  const SummaryState({
    this.isRestarting = false,
    this.errorMessage,
    this.categories = const [],
    this.selectedCategoryId,
    this.restartedData,
  });

  SummaryState copyWith({
    bool? isRestarting,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? categories,
    int? selectedCategoryId,
    bool clearCategoryId = false,
    Map<String, dynamic>? restartedData,
  }) {
    return SummaryState(
      isRestarting: isRestarting ?? this.isRestarting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      categories: categories ?? this.categories,
      selectedCategoryId: clearCategoryId
          ? null
          : selectedCategoryId ?? this.selectedCategoryId,
      restartedData: restartedData ?? this.restartedData,
    );
  }
}

class SummaryNotifier extends AutoDisposeNotifier<SummaryState> {
  String? _roomCode;
  String? _playerUuid;

  @override
  SummaryState build() {
    ref.onDispose(() {
      if (state.restartedData == null) {
        GameHubService.clearCallbacks();
        GameHubService.disconnect();
      }
    });
    return const SummaryState();
  }

  void init(
      String? roomCode, String? playerUuid, int? categoryId, bool isHost) {
    _roomCode = roomCode;
    _playerUuid = playerUuid;
    state = state.copyWith(selectedCategoryId: categoryId);
    _setupCallbacks();
    if (isHost && roomCode != null) _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await RoomApiService.getCategories();
      state = state.copyWith(categories: cats);
    } catch (_) {}
  }

  void _setupCallbacks() {
    GameHubService.onGameRestarted = (data) {
      state = state.copyWith(restartedData: data);
    };
  }

  void selectCategory(int? id) {
    if (id == null) {
      state = state.copyWith(clearCategoryId: true);
    } else {
      state = state.copyWith(selectedCategoryId: id);
    }
  }

  Future<void> playAgain() async {
    if (_roomCode == null || _playerUuid == null) return;
    state = state.copyWith(isRestarting: true, clearError: true);
    try {
      await GameHubService.restartGame(
          _roomCode!, _playerUuid!, state.selectedCategoryId);
    } catch (e) {
      state = state.copyWith(
        isRestarting: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

final summaryProvider =
    AutoDisposeNotifierProvider<SummaryNotifier, SummaryState>(
  SummaryNotifier.new,
);
