import 'package:flutter_test/flutter_test.dart';
import 'package:triviagame_flutter/models/question_model.dart';

Map<String, dynamic> _q(String text, [List<String>? answers]) => {
      'index': 0,
      'total': 10,
      'text': text,
      'category': 'Math',
      'difficulty': 'easy',
      'type': 'multiple',
      'answers': answers ?? ['A', 'B', 'C', 'D'],
    };

void main() {
  group('QuestionModel.fromJson', () {
    test('parsuje podstawowe pola poprawnie', () {
      final q = QuestionModel.fromJson(_q('What is 2+2?', ['4', '3', '5', '2']));

      expect(q.index, 0);
      expect(q.total, 10);
      expect(q.text, 'What is 2+2?');
      expect(q.category, 'Math');
      expect(q.difficulty, 'easy');
      expect(q.type, 'multiple');
      expect(q.answers, ['4', '3', '5', '2']);
    });

    test('dekoduje &amp; na &', () {
      final q = QuestionModel.fromJson(_q('Tom &amp; Jerry'));
      expect(q.text, 'Tom & Jerry');
    });

    test('dekoduje &quot; na "', () {
      final q = QuestionModel.fromJson(_q('He said &quot;hello&quot;'));
      expect(q.text, 'He said "hello"');
    });

    test('dekoduje &#039; na apostrof', () {
      final q = QuestionModel.fromJson(_q('It&#039;s fine'));
      expect(q.text, "It's fine");
    });

    test('dekoduje &lt; i &gt; na < i >', () {
      final q = QuestionModel.fromJson(_q('&lt;html&gt;'));
      expect(q.text, '<html>');
    });

    test('dekoduje &nbsp; na spację', () {
      final q = QuestionModel.fromJson(_q('A&nbsp;B'));
      expect(q.text, 'A B');
    });

    test('dekoduje encje HTML w odpowiedziach', () {
      final q = QuestionModel.fromJson(
        _q('Question?', ['A &amp; B', 'C &quot; D', 'E', 'F']),
      );
      expect(q.answers[0], 'A & B');
      expect(q.answers[1], 'C " D');
    });
  });
}
