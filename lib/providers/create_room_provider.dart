import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_failure.dart';
import '../domain/repositories/room_repository.dart';
import 'repository_providers.dart';

class CreateRoomState {
  final bool isLoading;
  final String? errorMessage;
  final bool isOffline;
  final List<Map<String, dynamic>> categories;
  final bool loadingCategories;
  final int? selectedCategoryId;
  final String? selectedCategoryName;

  const CreateRoomState({
    this.isLoading = false,
    this.errorMessage,
    this.isOffline = false,
    this.categories = const [],
    this.loadingCategories = true,
    this.selectedCategoryId,
    this.selectedCategoryName,
  });

  CreateRoomState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool? isOffline,
    List<Map<String, dynamic>>? categories,
    bool? loadingCategories,
    int? selectedCategoryId,
    String? selectedCategoryName,
    bool clearCategory = false,
  }) {
    return CreateRoomState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      isOffline: isOffline ?? this.isOffline,
      categories: categories ?? this.categories,
      loadingCategories: loadingCategories ?? this.loadingCategories,
      selectedCategoryId:
          clearCategory ? null : selectedCategoryId ?? this.selectedCategoryId,
      selectedCategoryName: clearCategory
          ? null
          : selectedCategoryName ?? this.selectedCategoryName,
    );
  }
}

class CreateRoomResult {
  final String roomCode;
  final String playerUuid;
  final int? categoryId;
  final String? categoryName;

  const CreateRoomResult({
    required this.roomCode,
    required this.playerUuid,
    this.categoryId,
    this.categoryName,
  });
}

class CreateRoomNotifier extends AutoDisposeNotifier<CreateRoomState> {
  late RoomRepository _repo;

  @override
  CreateRoomState build() {
    _repo = ref.read(roomRepositoryProvider);
    _loadCategories();
    return const CreateRoomState();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _repo.getCategories();
      state = state.copyWith(categories: cats, loadingCategories: false);
    } catch (_) {
      state = state.copyWith(loadingCategories: false);
    }
  }

  void selectCategory(int? id) {
    if (id == null) {
      state = state.copyWith(clearCategory: true);
      return;
    }
    final name =
        state.categories.firstWhere((c) => c['id'] == id)['name'] as String;
    state = state.copyWith(selectedCategoryId: id, selectedCategoryName: name);
  }

  Future<CreateRoomResult?> createRoom(String nickname) async {
    state = state.copyWith(isLoading: true, clearError: true, isOffline: false);

    try {
      int? categoryId = state.selectedCategoryId;
      String? categoryName = state.selectedCategoryName;
      if (categoryId == null && state.categories.isNotEmpty) {
        final random =
            state.categories[Random().nextInt(state.categories.length)];
        categoryId = random['id'] as int;
        categoryName = random['name'] as String;
      }

      final result = await _repo.createRoom(nickname, categoryId: categoryId);
      state = state.copyWith(isLoading: false);
      return CreateRoomResult(
        roomCode: result.roomCode,
        playerUuid: result.playerUuid,
        categoryId: categoryId,
        categoryName: categoryName,
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

final createRoomProvider =
    AutoDisposeNotifierProvider<CreateRoomNotifier, CreateRoomState>(
  CreateRoomNotifier.new,
);
