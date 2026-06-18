abstract class GameHubRepository {
  set onConnectedToRoom(void Function(Map<String, dynamic>)? cb);
  set onPlayerConnected(void Function(Map<String, dynamic>)? cb);
  set onPlayerDisconnected(void Function(String)? cb);
  set onRoomClosed(void Function()? cb);
  set onGameStarted(void Function(Map<String, dynamic>)? cb);
  set onAnswerAccepted(void Function()? cb);
  set onQuestionTimedOut(void Function()? cb);
  set onRoundEnded(void Function(Map<String, dynamic>)? cb);
  set onQuestionReceived(void Function(Map<String, dynamic>)? cb);
  set onGameEnded(void Function(List<dynamic>)? cb);
  set onGameRestarted(void Function(Map<String, dynamic>)? cb);
  set onError(void Function(String)? cb);

  bool get isConnected;

  Future<void> connect();
  Future<void> connectToRoom(String roomCode, String playerUuid);
  Future<void> startGame(String roomCode, String playerUuid);
  Future<void> submitAnswer(String roomCode, String playerUuid, String answer);
  Future<void> playerReady(String roomCode, String playerUuid);
  Future<void> restartGame(String roomCode, String playerUuid, int? categoryId);
  Future<void> disconnect();
  void clearCallbacks();
}
