import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:triviagame_flutter/screens/splash/splash_screen.dart';
import 'package:triviagame_flutter/screens/home/home_screen.dart';
import 'package:triviagame_flutter/screens/room/create_room_screen.dart';
import 'package:triviagame_flutter/screens/room/join_room_screen.dart';
import 'package:triviagame_flutter/screens/room/lobby_screen.dart';
import 'package:triviagame_flutter/screens/room/qr_scanner_screen.dart';
import 'package:triviagame_flutter/screens/game/game_screen.dart';
import 'package:triviagame_flutter/screens/summary/summary_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/create-room',
        name: 'createRoom',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: '/join-room',
        name: 'joinRoom',
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: '/lobby',
        name: 'lobby',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return LobbyScreen(
            roomCode: extra['roomCode'] as String,
            nickname: extra['nickname'] as String,
            isHost: extra['isHost'] as bool,
            playerUuid: extra['playerUuid'] as String,
            categoryId: extra['categoryId'] as int?,
            categoryName: extra['categoryName'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/qr-scanner',
        name: 'qrScanner',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return QrScannerScreen(nickname: extra['nickname'] as String);
        },
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return GameScreen(
            roomCode: extra['roomCode'] as String,
            playerUuid: extra['playerUuid'] as String,
            nickname: extra['nickname'] as String,
            isHost: extra['isHost'] as bool,
            categoryId: extra['categoryId'] as int?,
            categoryName: extra['categoryName'] as String?,
            players: List<Map<String, dynamic>>.from(
                extra['players'] as List),
            initialQuestion:
                extra['initialQuestion'] as Map<String, dynamic>,
          );
        },
      ),
      GoRoute(
        path: '/summary',
        name: 'summary',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SummaryScreen(
            scores: List<Map<String, dynamic>>.from(extra['scores'] as List),
            roomCode: extra['roomCode'] as String?,
            playerUuid: extra['playerUuid'] as String?,
            nickname: extra['nickname'] as String?,
            isHost: extra['isHost'] as bool? ?? false,
            categoryId: extra['categoryId'] as int?,
            categoryName: extra['categoryName'] as String?,
          );
        },
      ),
    ],
  );
}
