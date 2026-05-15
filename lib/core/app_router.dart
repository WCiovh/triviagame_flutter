import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:triviagame_flutter/screens/splash/splash_screen.dart';
import 'package:triviagame_flutter/screens/home/home_screen.dart';
import 'package:triviagame_flutter/screens/room/create_room_screen.dart';
import 'package:triviagame_flutter/screens/room/join_room_screen.dart';
import 'package:triviagame_flutter/screens/room/lobby_screen.dart';
import 'package:triviagame_flutter/screens/game/game_screen.dart';

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
            roomCode: extra['roomCode'],
            nickname: extra['nickname'],
            isHost: extra['isHost'],
          );
        },
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return GameScreen(
            roomCode: extra['roomCode'],
            players: List<String>.from(extra['players']),
          );
        },
      ),
      GoRoute(
        path: '/summary',
        name: 'summary',
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Summary'))),
      ),
    ],
  );
}
