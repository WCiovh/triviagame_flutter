import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triviagame_flutter/core/theme/app_theme.dart';
import 'package:triviagame_flutter/screens/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('SplashScreen wyświetla nazwę aplikacji i podtytuł', (tester) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.darkTheme,
      ),
    );

    await tester.pump();

    expect(find.text('TriviaGame'), findsOneWidget);
    expect(find.text('Real-time multiplayer quiz'), findsOneWidget);
    expect(find.byIcon(Icons.quiz_rounded), findsOneWidget);

    // przewiń czas testowy żeby timer ze splash screena mógł się zakończyć
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
