import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/room_api_service.dart';

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
  @override
  CreateRoomState build() {
    _loadCategories();
    return const CreateRoomState();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await RoomApiService.getCategories();
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
    final online = await ConnectivityService.isOnline();
    if (!online) {
      state = state.copyWith(isOffline: true);
      return null;
    }

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

      final result =
          await RoomApiService.createRoom(nickname, categoryId: categoryId);
      state = state.copyWith(isLoading: false);
      return CreateRoomResult(
        roomCode: result.roomCode,
        playerUuid: result.playerUuid,
        categoryId: categoryId,
        categoryName: categoryName,
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

final createRoomProvider =
    AutoDisposeNotifierProvider<CreateRoomNotifier, CreateRoomState>(
  CreateRoomNotifier.new,
);
