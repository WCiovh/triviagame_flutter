import 'package:signalr_netcore/signalr_client.dart';
import '../config/app_config.dart';

class GameHubService {
  static HubConnection? _connection;

  static void Function(Map<String, dynamic>)? onConnectedToRoom;
  static void Function(Map<String, dynamic>)? onPlayerConnected;
  static void Function(String)? onPlayerDisconnected;
  static void Function(Map<String, dynamic>)? onGameStarted;
  static void Function()? onAnswerAccepted;
  static void Function()? onQuestionTimedOut;
  static void Function(Map<String, dynamic>)? onRoundEnded;
  static void Function(Map<String, dynamic>)? onQuestionReceived;
  static void Function(List<dynamic>)? onGameEnded;
  static void Function(String)? onError;

  static Future<void> connect() async {
    _connection = HubConnectionBuilder()
        .withUrl(AppConfig.hubUrl)
        .withAutomaticReconnect()
        .build();

    _connection!.on('ConnectedToRoom',
        (args) => onConnectedToRoom?.call(args![0] as Map<String, dynamic>));
    _connection!.on('PlayerConnected',
        (args) => onPlayerConnected?.call(args![0] as Map<String, dynamic>));
    _connection!.on('PlayerDisconnected',
        (args) => onPlayerDisconnected?.call(args![0] as String));
    _connection!.on('GameStarted',
        (args) => onGameStarted?.call(args![0] as Map<String, dynamic>));
    _connection!.on('AnswerAccepted', (_) => onAnswerAccepted?.call());
    _connection!.on('QuestionTimedOut', (_) => onQuestionTimedOut?.call());
    _connection!.on('RoundEnded',
        (args) => onRoundEnded?.call(args![0] as Map<String, dynamic>));
    _connection!.on('QuestionReceived',
        (args) => onQuestionReceived?.call(args![0] as Map<String, dynamic>));
    _connection!.on('GameEnded',
        (args) => onGameEnded?.call(args![0] as List<dynamic>));
    _connection!.on(
        'Error', (args) => onError?.call(args![0] as String));

    await _connection!.start();
  }

  static Future<void> connectToRoom(
      String roomCode, String playerUuid) async {
    await _connection!.invoke('ConnectToRoom', args: [roomCode, playerUuid]);
  }

  static Future<void> startGame(String roomCode, String playerUuid) async {
    await _connection!.invoke('StartGame', args: [roomCode, playerUuid]);
  }

  static Future<void> submitAnswer(
      String roomCode, String playerUuid, String answer) async {
    await _connection!.invoke('SubmitAnswer',
        args: [roomCode, playerUuid, answer]);
  }

  static Future<void> playerReady(String roomCode, String playerUuid) async {
    await _connection!.invoke('PlayerReady', args: [roomCode, playerUuid]);
  }

  static Future<void> disconnect() async {
    await _connection?.stop();
    _connection = null;
  }

  static void clearCallbacks() {
    onConnectedToRoom = null;
    onPlayerConnected = null;
    onPlayerDisconnected = null;
    onGameStarted = null;
    onAnswerAccepted = null;
    onQuestionTimedOut = null;
    onRoundEnded = null;
    onQuestionReceived = null;
    onGameEnded = null;
    onError = null;
  }
}
