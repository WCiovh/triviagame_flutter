import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:triviagame_flutter/core/errors/app_failure.dart';
import 'package:triviagame_flutter/core/theme/app_theme.dart';
import 'package:triviagame_flutter/providers/repository_providers.dart';
import 'package:triviagame_flutter/screens/room/join_room_screen.dart';

import '../mocks/mock_room_repository.dart';

void main() {
  late MockRoomRepository mockRepo;
  late GoRouter router;

  setUp(() {
    mockRepo = MockRoomRepository();
    router = GoRouter(
      initialLocation: '/join-room',
      routes: [
        GoRoute(
          path: '/join-room',
          builder: (_, _) => const JoinRoomScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('Strona główna')),
        ),
        GoRoute(
          path: '/lobby',
          builder: (_, _) => const Scaffold(body: Text('Lobby')),
        ),
        GoRoute(
          path: '/qr-scanner',
          builder: (_, _) => const Scaffold(body: Text('QR Scanner')),
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

  group('JoinRoomScreen', () {
    testWidgets('wyświetla pola formularza i przycisk', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      expect(find.text('Dołącz do pokoju'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.widgetWithText(ElevatedButton, 'Dołącz'), findsOneWidget);
    });

    testWidgets('pokazuje snackbar gdy nick jest pusty', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Dołącz'));
      await tester.pumpAndSettle();

      expect(find.text('Podaj swój nick!'), findsOneWidget);
    });

    testWidgets('pokazuje snackbar gdy kod ma złą długość', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Wiktor');
      await tester.enterText(find.byType(TextField).last, 'ABC');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Dołącz'));
      await tester.pumpAndSettle();

      expect(find.text('Kod pokoju musi mieć 6 znaków!'), findsOneWidget);
    });

    testWidgets('pokazuje widget błędu gdy pokój nie istnieje', (tester) async {
      mockRepo.failureToThrow =
          const NotFoundFailure('Pokój "ABC123" nie istnieje');

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Wiktor');
      await tester.enterText(find.byType(TextField).last, 'ABC123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Dołącz'));
      await tester.pumpAndSettle();

      expect(find.text('Coś poszło nie tak'), findsOneWidget);
      expect(find.text('Pokój "ABC123" nie istnieje'), findsOneWidget);
    });

    testWidgets('pokazuje widget offline przy braku połączenia', (tester) async {
      mockRepo.failureToThrow = const NetworkFailure();

      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Wiktor');
      await tester.enterText(find.byType(TextField).last, 'ABC123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Dołącz'));
      await tester.pumpAndSettle();

      expect(find.text('Brak połączenia'), findsOneWidget);
    });
  });
}
