import 'package:triviagame_flutter/domain/repositories/game_hub_repository.dart';

class MockGameHubRepository implements GameHubRepository {
  @override
  set onConnectedToRoom(void Function(Map<String, dynamic>)? cb) {}
  @override
  set onPlayerConnected(void Function(Map<String, dynamic>)? cb) {}
  @override
  set onPlayerDisconnected(void Function(String)? cb) {}
  @override
  set onRoomClosed(void Function()? cb) {}
  @override
  set onGameStarted(void Function(Map<String, dynamic>)? cb) {}
  @override
  set onAnswerAccepted(void Function()? cb) {}
  @override
  set onQuestionTimedOut(void Function()? cb) {}
  @override
  set onRoundEnded(void Function(Map<String, dynamic>)? cb) {}
  @override
  set onQuestionReceived(void Function(Map<String, dynamic>)? cb) {}
  @override
  set onGameEnded(void Function(List<dynamic>)? cb) {}
  @override
  set onGameRestarted(void Function(Map<String, dynamic>)? cb) {}
  @override
  set onError(void Function(String)? cb) {}

  @override
  bool get isConnected => false;

  @override
  Future<void> connect() async {}
  @override
  Future<void> connectToRoom(String roomCode, String playerUuid) async {}
  @override
  Future<void> startGame(String roomCode, String playerUuid) async {}
  @override
  Future<void> submitAnswer(
      String roomCode, String playerUuid, String answer) async {}
  @override
  Future<void> playerReady(String roomCode, String playerUuid) async {}
  @override
  Future<void> restartGame(
      String roomCode, String playerUuid, int? categoryId) async {}
  @override
  Future<void> disconnect() async {}
  @override
  void clearCallbacks() {}
}
