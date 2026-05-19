import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/widgets/loading_widget.dart';
import 'package:triviagame_flutter/widgets/error_widget.dart';
import 'package:triviagame_flutter/core/services/connectivity_service.dart';
import 'package:triviagame_flutter/core/services/room_api_service.dart';
import 'package:triviagame_flutter/widgets/offline_widget.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  List<Map<String, dynamic>> _categories = [];
  bool _loadingCategories = true;
  int? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await RoomApiService.getCategories();
      if (mounted) setState(() { _categories = cats; _loadingCategories = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingCategories = false);
    }
  }

  void _createRoom() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj swój nick!')),
      );
      return;
    }

    final online = await ConnectivityService.isOnline();
    if (!online) {
      setState(() => _isOffline = true);
      return;
    }
    setState(() => _isOffline = false);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int? categoryId = _selectedCategoryId;
      String? categoryName = _selectedCategoryName;
      if (categoryId == null && _categories.isNotEmpty) {
        final random = _categories[Random().nextInt(_categories.length)];
        categoryId = random['id'] as int;
        categoryName = random['name'] as String;
      }

      final result = await RoomApiService.createRoom(
        _nicknameController.text.trim(),
        categoryId: categoryId,
      );

      if (mounted) {
        context.go('/lobby', extra: {
          'roomCode': result.roomCode,
          'nickname': _nicknameController.text.trim(),
          'isHost': true,
          'playerUuid': result.playerUuid,
          'categoryId': categoryId,
          'categoryName': categoryName,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Utwórz pokój'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                decoration: const InputDecoration(
                  labelText: 'Nick',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 8),
              _loadingCategories
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  : DropdownButtonFormField<int?>(
                      initialValue: _selectedCategoryId,
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
                        ..._categories.map((cat) => DropdownMenuItem<int?>(
                              value: cat['id'] as int,
                              child: Text(cat['name'] as String),
                            )),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          _selectedCategoryName = val == null
                              ? null
                              : _categories.firstWhere(
                                  (c) => c['id'] == val)['name'] as String;
                        });
                      },
                    ),
              if (_errorMessage != null)
                AppErrorWidget(message: _errorMessage!, onRetry: _createRoom),
              if (_isOffline) OfflineWidget(onRetry: _createRoom),
              const Spacer(),
              _isLoading
                  ? const LoadingWidget(message: 'Tworzenie pokoju...')
                  : ElevatedButton(
                      onPressed: _createRoom,
                      child: const Text(
                        'Utwórz pokój',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
