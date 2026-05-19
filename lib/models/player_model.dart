class PlayerModel {
  final String uuid;
  final String displayName;
  final int points;
  final int correctAnswers;

  const PlayerModel({
    required this.uuid,
    required this.displayName,
    required this.points,
    required this.correctAnswers,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
        uuid: json['uuid'] as String,
        displayName: json['displayName'] as String,
        points: json['points'] as int,
        correctAnswers: json['correctAnswers'] as int,
      );

  Map<String, dynamic> toScoreMap() => {
        'uuid': uuid,
        'nickname': displayName,
        'score': points,
      };
}
