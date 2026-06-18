import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/providers/create_room_provider.dart';
import 'package:triviagame_flutter/widgets/loading_widget.dart';
import 'package:triviagame_flutter/widgets/error_widget.dart';
import 'package:triviagame_flutter/widgets/offline_widget.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  static String _savedNickname = '';
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: _savedNickname);
  }

  Future<void> _createRoom() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj swój nick!')),
      );
      return;
    }

    final result =
        await ref.read(createRoomProvider.notifier).createRoom(nickname);
    if (result != null && mounted) {
      context.go('/lobby', extra: {
        'roomCode': result.roomCode,
        'nickname': nickname,
        'isHost': true,
        'playerUuid': result.playerUuid,
        'categoryId': result.categoryId,
        'categoryName': result.categoryName,
      });
    }
  }

  @override
  void dispose() {
    _savedNickname = _nicknameController.text;
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createRoomProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Utwórz pokój'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/home'),
          ),
        ),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jak masz na imię?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Twój nick będzie widoczny dla innych graczy.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _nicknameController,
                        maxLength: 16,
                        buildCounter: (_, {required currentLength, required isFocused, required maxLength}) => null,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Nick',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 8),
                      state.loadingCategories
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: LinearProgressIndicator(),
                            )
                          : DropdownButtonFormField<int?>(
                              initialValue: state.selectedCategoryId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Kategoria',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                              items: [
                                const DropdownMenuItem<int?>(
                                  value: null,
                                  child: Text('Dowolna kategoria'),
                                ),
                                ...state.categories.map(
                                  (cat) => DropdownMenuItem<int?>(
                                    value: cat['id'] as int,
                                    child: Text(cat['name'] as String),
                                  ),
                                ),
                              ],
                              onChanged: (val) => ref
                                  .read(createRoomProvider.notifier)
                                  .selectCategory(val),
                            ),
                      if (state.errorMessage != null)
                        AppErrorWidget(
                            message: state.errorMessage!, onRetry: _createRoom),
                      if (state.isOffline) OfflineWidget(onRetry: _createRoom),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: state.isLoading
                    ? const LoadingWidget(message: 'Tworzenie pokoju...')
                    : ElevatedButton(
                        onPressed: _createRoom,
                        child: const Text(
                          'Utwórz pokój',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
