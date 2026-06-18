import '../../core/services/game_hub_service.dart';
import '../../domain/repositories/game_hub_repository.dart';

class GameHubRepositoryImpl implements GameHubRepository {
  @override
  set onConnectedToRoom(void Function(Map<String, dynamic>)? cb) =>
      GameHubService.onConnectedToRoom = cb;

  @override
  set onPlayerConnected(void Function(Map<String, dynamic>)? cb) =>
      GameHubService.onPlayerConnected = cb;

  @override
  set onPlayerDisconnected(void Function(String)? cb) =>
      GameHubService.onPlayerDisconnected = cb;

  @override
  set onRoomClosed(void Function()? cb) => GameHubService.onRoomClosed = cb;

  @override
  set onGameStarted(void Function(Map<String, dynamic>)? cb) =>
      GameHubService.onGameStarted = cb;

  @override
  set onAnswerAccepted(void Function()? cb) =>
      GameHubService.onAnswerAccepted = cb;

  @override
  set onQuestionTimedOut(void Function()? cb) =>
      GameHubService.onQuestionTimedOut = cb;

  @override
  set onRoundEnded(void Function(Map<String, dynamic>)? cb) =>
      GameHubService.onRoundEnded = cb;

  @override
  set onQuestionReceived(void Function(Map<String, dynamic>)? cb) =>
      GameHubService.onQuestionReceived = cb;

  @override
  set onGameEnded(void Function(List<dynamic>)? cb) =>
      GameHubService.onGameEnded = cb;

  @override
  set onGameRestarted(void Function(Map<String, dynamic>)? cb) =>
      GameHubService.onGameRestarted = cb;

  @override
  set onError(void Function(String)? cb) => GameHubService.onError = cb;

  @override
  bool get isConnected => GameHubService.isConnected;

  @override
  Future<void> connect() => GameHubService.connect();

  @override
  Future<void> connectToRoom(String roomCode, String playerUuid) =>
      GameHubService.connectToRoom(roomCode, playerUuid);

  @override
  Future<void> startGame(String roomCode, String playerUuid) =>
      GameHubService.startGame(roomCode, playerUuid);

  @override
  Future<void> submitAnswer(
          String roomCode, String playerUuid, String answer) =>
      GameHubService.submitAnswer(roomCode, playerUuid, answer);

  @override
  Future<void> playerReady(String roomCode, String playerUuid) =>
      GameHubService.playerReady(roomCode, playerUuid);

  @override
  Future<void> restartGame(
          String roomCode, String playerUuid, int? categoryId) =>
      GameHubService.restartGame(roomCode, playerUuid, categoryId);

  @override
  Future<void> disconnect() => GameHubService.disconnect();

  @override
  void clearCallbacks() => GameHubService.clearCallbacks();
}
