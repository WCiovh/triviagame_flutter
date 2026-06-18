import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_failure.dart';
import '../domain/repositories/game_hub_repository.dart';
import '../domain/repositories/room_repository.dart';
import 'repository_providers.dart';

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
  late RoomRepository _roomRepo;
  late GameHubRepository _hub;
  String? _roomCode;
  String? _playerUuid;

  @override
  SummaryState build() {
    _roomRepo = ref.read(roomRepositoryProvider);
    _hub = ref.read(gameHubRepositoryProvider);
    ref.onDispose(() {
      if (state.restartedData == null) {
        _hub.clearCallbacks();
        _hub.disconnect();
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
      final cats = await _roomRepo.getCategories();
      state = state.copyWith(categories: cats);
    } catch (_) {}
  }

  void _setupCallbacks() {
    _hub.onGameRestarted = (data) {
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
      await _hub.restartGame(_roomCode!, _playerUuid!, state.selectedCategoryId);
    } on AppFailure catch (f) {
      state = state.copyWith(isRestarting: false, errorMessage: f.message);
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
