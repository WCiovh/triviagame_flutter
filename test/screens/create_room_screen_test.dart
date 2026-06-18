import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/core/errors/app_failure.dart';
import 'package:triviagame_flutter/core/theme/app_theme.dart';
import 'package:triviagame_flutter/providers/repository_providers.dart';
import 'package:triviagame_flutter/screens/room/create_room_screen.dart';

import '../mocks/mock_room_repository.dart';

void main() {
  late MockRoomRepository mockRepo;
  late GoRouter router;

  setUp(() {
    mockRepo = MockRoomRepository();
    router = GoRouter(
      initialLocation: '/create-room',
      routes: [
        GoRoute(
          path: '/create-room',
          builder: (_, _) => const CreateRoomScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Strona główna')),
        ),
        GoRoute(
          path: '/lobby',
          builder: (_, _) => const Scaffold(body: Text('Lobby')),
        ),
      ],
    );
  });

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        roomRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.darkTheme,
      ),
    );
  }

  group('CreateRoomScreen', () {
    testWidgets('wyświetla pola formularza i przycisk', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Utwórz pokój'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Utwórz pokój'), findsOneWidget);
    });

    testWidgets('pokazuje snackbar gdy nick jest pusty', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Utwórz pokój'));
      await tester.pumpAndSettle();

      expect(find.text('Podaj swój nick!'), findsOneWidget);
    });

    testWidgets('pokazuje widget błędu gdy serwer zwróci błąd', (tester) async {
      mockRepo.failureToThrow = const ServerFailure('Serwer niedostępny');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Wiktor');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Utwórz pokój'));
      await tester.pumpAndSettle();

      expect(find.text('Coś poszło nie tak'), findsOneWidget);
      expect(find.text('Serwer niedostępny'), findsOneWidget);
    });

    testWidgets('pokazuje widget offline przy braku połączenia', (tester) async {
      mockRepo.failureToThrow = const NetworkFailure();

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Wiktor');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Utwórz pokój'));
      await tester.pumpAndSettle();

      expect(find.text('Brak połączenia'), findsOneWidget);
    });

    testWidgets('wyświetla kategorie po otwarciu dropdowna', (tester) async {
      mockRepo.categoriesResult = [
        {'id': 1, 'name': 'Historia'},
        {'id': 2, 'name': 'Nauka'},
      ];

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButtonFormField<int?>));
      await tester.pumpAndSettle();

      expect(find.text('Historia'), findsWidgets);
      expect(find.text('Nauka'), findsWidgets);
    });
  });
}
