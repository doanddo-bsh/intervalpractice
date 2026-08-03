import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/state/quiz_session.dart';

void main() {
  const mode = ProblemMode(
    difficulty: Difficulty.easy,
    questionType: QuestionType.nameTheInterval,
  );

  QuizSession newSession() => QuizSession(
        mode: mode,
        generator: ProblemGenerator(random: Random(11)),
      );

  group('QuizSession 진행', () {
    test('1번 문제부터 시작하고 첫 문제가 준비된다', () {
      final session = newSession();

      expect(session.questionNumber, 1);
      expect(session.totalQuestions, 10);
      expect(session.correctCount, 0);
      expect(session.isReviewMode, isFalse);
    });

    test('정답을 기록하면 정답 수가 증가한다', () {
      final session = newSession()..recordAnswer(isCorrect: true);

      expect(session.correctCount, 1);
      expect(session.wrongProblems, isEmpty);
    });

    test('오답을 기록하면 오답노트에 쌓인다', () {
      final session = newSession()..recordAnswer(isCorrect: false);

      expect(session.correctCount, 0);
      expect(session.wrongProblems, hasLength(1));
    });

    test('10문제를 다 풀면 완료 상태가 된다', () {
      final session = newSession();

      for (var i = 0; i < 10; i++) {
        session.recordAnswer(isCorrect: true);
        if (!session.isFinished) session.nextQuestion();
      }

      expect(session.isFinished, isTrue);
      expect(session.correctCount, 10);
    });
  });

  group('오답 다시 풀기', () {
    test('오답이 없으면 복습을 시작할 수 없다', () {
      final session = newSession()..recordAnswer(isCorrect: true);

      expect(session.canStartReview, isFalse);
    });

    test('오답이 있으면 복습을 시작할 수 있다', () {
      final session = newSession()..recordAnswer(isCorrect: false);

      expect(session.canStartReview, isTrue);
    });

    test('복습을 시작하면 오답 개수만큼만 출제한다', () {
      final session = newSession();

      session.recordAnswer(isCorrect: false);
      session.nextQuestion();
      session.recordAnswer(isCorrect: false);
      session.nextQuestion();
      session.recordAnswer(isCorrect: true);

      session.startReview();

      expect(session.isReviewMode, isTrue);
      expect(session.totalQuestions, 2);
      expect(session.questionNumber, 1);
      expect(session.correctCount, 0);
    });

    test('복습 중 다시 틀리면 다음 복습 대상으로 쌓인다', () {
      final session = newSession();

      session.recordAnswer(isCorrect: false);
      session.startReview();
      session.recordAnswer(isCorrect: false);

      expect(session.wrongProblems, hasLength(1));
    });

    test('restart하면 처음 상태로 돌아간다', () {
      final session = newSession();

      session.recordAnswer(isCorrect: false);
      session.nextQuestion();
      session.restart();

      expect(session.questionNumber, 1);
      expect(session.correctCount, 0);
      expect(session.isReviewMode, isFalse);
      expect(session.wrongProblems, isEmpty);
    });
  });

  test('진행률은 0.0 ~ 1.0 범위다', () {
    final session = newSession();

    expect(session.progress, closeTo(0.1, 0.001));

    for (var i = 0; i < 9; i++) {
      session.recordAnswer(isCorrect: true);
      session.nextQuestion();
    }

    expect(session.progress, closeTo(1.0, 0.001));
  });
}
