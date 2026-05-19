// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appSubtitle => 'Real-time multiplayer quiz';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get tryAgain => 'Try again';

  @override
  String get host => 'Host';

  @override
  String points(int score) {
    return '$score pts';
  }

  @override
  String get exitAppTitle => 'Exit the app?';

  @override
  String get createRoom => 'Create room';

  @override
  String get joinRoom => 'Join room';

  @override
  String get whatsYourName => 'What\'s your name?';

  @override
  String get nicknameVisible =>
      'Your nickname will be visible to other players.';

  @override
  String get nickLabel => 'Nickname';

  @override
  String get categoryLabel => 'Category';

  @override
  String get anyCategory => 'Any category';

  @override
  String get creatingRoom => 'Creating room...';

  @override
  String get enterNickname => 'Enter your nickname!';

  @override
  String get roomCodeMustBe6 => 'Room code must be 6 characters!';

  @override
  String get joinGame => 'Join game';

  @override
  String get enterNicknameAndCode =>
      'Enter your nickname and room code to join.';

  @override
  String get roomCodeLabel => 'Room code';

  @override
  String get enterNicknameFirst => 'Enter your nickname first!';

  @override
  String get scanQrCode => 'Scan QR code';

  @override
  String get joiningRoom => 'Joining room...';

  @override
  String get join => 'Join';

  @override
  String get hostClosedRoom => 'Host closed the room.';

  @override
  String get connectionFailed =>
      'Failed to connect to server. Check your connection.';

  @override
  String get startGameFailed => 'Failed to start the game.';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String shareRoomText(String roomCode) {
    return 'Join my TriviaGame room!\nCode: $roomCode';
  }

  @override
  String get closeRoomTitle => 'Close room?';

  @override
  String get closeRoomContent => 'All players will be disconnected.';

  @override
  String get lobby => 'Lobby';

  @override
  String get connectingToRoom => 'Connecting to room...';

  @override
  String get tapToCopy => 'Tap to copy';

  @override
  String get roomQrCode => 'Room QR code';

  @override
  String get showQr => 'Show QR';

  @override
  String get share => 'Share';

  @override
  String playersCount(int count) {
    return 'Players ($count)';
  }

  @override
  String get waitingForHost => 'Waiting for host...';

  @override
  String get startGame => 'Start game';

  @override
  String get leaveRoom => 'Leave room';

  @override
  String get leaveGameTitle => 'Leave game?';

  @override
  String get leaveGameContent => 'Your progress will be lost.';

  @override
  String questionProgress(int current, int total) {
    return 'Question $current/$total';
  }

  @override
  String roomLabel(String roomCode) {
    return 'Room: $roomCode';
  }

  @override
  String get timeUp => 'Time\'s up!';

  @override
  String get waitingForOtherPlayers => 'Waiting for other players...';

  @override
  String get didNotAnswer => 'Did not answer';

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get submitAnswerFailed => 'Failed to submit answer.';

  @override
  String get nextQuestion => 'Next question';

  @override
  String get gameOver => 'Game over!';

  @override
  String get podium => '🏆 Podium';

  @override
  String get backToMenu => 'Back to menu';

  @override
  String get categoryForNextGame => 'Category for next game';

  @override
  String get playAgain => 'Play again';

  @override
  String get waitingForHostLong => 'Waiting for host...';

  @override
  String get noPermissions => 'No permissions';

  @override
  String get cameraPermissionNeeded =>
      'The app needs camera access to scan QR codes.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get pointCameraAtQr => 'Point camera at the room QR code';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noConnection => 'No connection';

  @override
  String get checkInternetConnection =>
      'Check your internet connection and try again.';

  @override
  String get ranking => 'Ranking';
}
