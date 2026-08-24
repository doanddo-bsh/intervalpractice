// Hard 유형 2(계이름 맞히기)는 임시표까지 골라야 정답이 특정된다.
//
// 리팩토링 후 임시표가 정답에서 완전히 빠져 있었다 — 가려진 음이 솔♯이어도
// 정답이 "솔"이라 사용자는 임시표를 표현할 방법이 없었고, 표시되는 정답도
// 실제 음과 달랐다.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/answer_checker.dart';
import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/staff_layout.dart';

const _easy = ProblemMode(
  difficulty: Difficulty.easy,
  questionType: QuestionType.nameTheNote,
);
const _hard = ProblemMode(
  difficulty: Difficulty.hard,
  questionType: QuestionType.nameTheNote,
);

IntervalProblem _problem(String hiddenAccidental) => IntervalProblem(
      lower: StaffLayout.byIndex(15), // C4 (보이는 음)
      upper: StaffLayout.byIndex(11), // G4 (가려진 음)
      accidentals: ['none', hiddenAccidental],
    );

void main() {
  test('Easy 는 계이름만 정답이다', () {
    expect(AnswerChecker.noteAnswer(_problem('none'), _easy), '솔');
  });

  group('Hard 는 임시표까지 정답에 포함한다', () {
    const cases = {
      'none': '솔',
      'sharp': '솔#',
      'double sharp': '솔x',
      'flat': '솔b',
      'double flat': '솔bb',
    };

    cases.forEach((accidental, expected) {
      test('$accidental -> $expected', () {
        expect(AnswerChecker.noteAnswer(_problem(accidental), _hard), expected);
      });
    });
  });

  test('임시표가 다르면 오답으로 채점된다', () {
    final problem = _problem('sharp'); // 실제 정답은 솔#

    expect(
      AnswerChecker.grade(problem: problem, mode: _hard, submitted: '솔')
          .isCorrect,
      isFalse,
      reason: '임시표를 빼고 낸 답이 정답 처리되면 안 된다',
    );
    expect(
      AnswerChecker.grade(problem: problem, mode: _hard, submitted: '솔b')
          .isCorrect,
      isFalse,
    );
    expect(
      AnswerChecker.grade(problem: problem, mode: _hard, submitted: '솔#')
          .isCorrect,
      isTrue,
    );
  });

  test('Hard 정답 표시에 영문 음이름이 함께 나온다', () {
    final text = AnswerChecker.grade(
      problem: _problem('sharp'),
      mode: _hard,
      submitted: '',
    ).correctAnswerText;

    expect(text, startsWith('솔#('));
    expect(text, endsWith(')'));
  });

  test('버튼 기호 5개가 모든 임시표를 덮는다', () {
    const generated = ['none', 'sharp', 'double sharp', 'flat', 'double flat'];
    final fromButtons = AnswerChecker.accidentalSymbols
        .map(AnswerChecker.answerFragmentOf)
        .toSet();
    final fromGenerator =
        generated.map(AnswerChecker.accidentalSymbolOf).toSet();

    expect(fromButtons, fromGenerator,
        reason: '생성기가 내는 임시표를 버튼으로 모두 표현할 수 있어야 한다');
  });

  test('생성되는 모든 Hard 유형2 문제의 정답을 버튼 조합으로 만들 수 있다', () {
    final generator = ProblemGenerator(random: Random(4242));
    final letters = StaffLayout.koreanNoteNames.toSet();

    for (var i = 0; i < 800; i++) {
      final problem = generator.next(mode: _hard);
      final answer = AnswerChecker.noteAnswer(problem, _hard);

      final letter = answer.substring(0, 1);
      final symbol = answer.substring(1);

      expect(letters, contains(letter), reason: '$problem -> $answer');
      expect(
        AnswerChecker.accidentalSymbols.map(AnswerChecker.answerFragmentOf),
        contains(symbol),
        reason: '$problem 의 임시표 "$symbol" 를 낼 버튼이 없다',
      );
      expect(
        AnswerChecker.grade(problem: problem, mode: _hard, submitted: answer)
            .isCorrect,
        isTrue,
      );
    }
  });
}
