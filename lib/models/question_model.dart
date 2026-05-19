class QuestionModel {
  final int index;
  final int total;
  final String text;
  final String category;
  final String difficulty;
  final String type;
  final List<String> answers;

  const QuestionModel({
    required this.index,
    required this.total,
    required this.text,
    required this.category,
    required this.difficulty,
    required this.type,
    required this.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        index: json['index'] as int,
        total: json['total'] as int,
        text: json['text'] as String,
        category: json['category'] as String,
        difficulty: json['difficulty'] as String,
        type: json['type'] as String,
        answers: List<String>.from(json['answers'] as List),
      );
}
