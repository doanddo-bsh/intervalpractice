// 특성화 테스트 — AnswerChecker.
//
// Task 18이 레거시 파이프라인(`lib/page/`)을 지우면서 41건의 특성화 테스트와
// 13,671건 대조 결과 0건 불일치였던 패리티 테스트가 함께 사라졌다. 이 파일은
// 그 패리티 테스트가 이미 신규 코드와 동일함을 증명한 출력을, 신규 코드
// (`lib/domain/answer_checker.dart`) 자체에 대한 직접 단언으로 다시 박제한다.
//
// 모든 기대값은 음악 이론으로 추론한 것이 아니라, 프로브를 돌려 실제로
// 관찰한 출력을 그대로 옮긴 것이다.
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/answer_checker.dart';
import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/domain/staff_layout.dart';

void main() {
  const easyType1 = ProblemMode(
    difficulty: Difficulty.easy,
    questionType: QuestionType.nameTheInterval,
  );
  const easyType2 = ProblemMode(
    difficulty: Difficulty.easy,
    questionType: QuestionType.nameTheNote,
  );
  const easyType3 = ProblemMode(
    difficulty: Difficulty.easy,
    questionType: QuestionType.invertedInterval,
  );

  // C4 (index 15) / E4 (index 13), 임시표 없음 -> 장3도.
  final c4 = StaffLayout.byIndex(15);
  final e4 = StaffLayout.byIndex(13);
  final f4 = StaffLayout.byIndex(12);
  final g4 = StaffLayout.byIndex(11);

  IntervalProblem problemOf(
    StaffSlot lower,
    StaffSlot upper, [
    List<String> accidentals = const ['none', 'none'],
  ]) =>
      IntervalProblem(lower: lower, upper: upper, accidentals: accidentals);

  group('correctAnswerText 형식', () {
    test('유형 1(음정 이름)은 "장3도" 꼴을 낸다', () {
      final grading = AnswerChecker.grade(
        problem: problemOf(c4, e4),
        mode: easyType1,
        submitted: '',
      );

      expect(grading.correctAnswerText, '장3도');
    });

    test('유형 2(계이름)는 "미" 같은 솔페지오 이름을 낸다', () {
      final grading = AnswerChecker.grade(
        problem: problemOf(c4, e4),
        mode: easyType2,
        submitted: '',
      );

      expect(grading.correctAnswerText, '미');
    });

    test('유형 3(자리바꿈)도 "단6도" 꼴을 낸다', () {
      final grading = AnswerChecker.grade(
        problem: problemOf(c4, e4),
        mode: easyType3,
        submitted: '',
      );

      expect(grading.correctAnswerText, '단6도');
    });

    test('완전5도 / 솔 / 완전4도 (C4-G4)', () {
      final problem = problemOf(c4, g4);

      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '완전5도',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType2,
          submitted: '',
        ).correctAnswerText,
        '솔',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        '완전4도',
      );
    });

    test('단2도 / 파 / 장7도 (E4-F4, 반음 경계)', () {
      final problem = problemOf(e4, f4);

      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '단2도',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType2,
          submitted: '',
        ).correctAnswerText,
        '파',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        '장7도',
      );
    });
  });

  group('유형 3은 진짜 자리바꿈 음정을 낸다', () {
    test('C4-E4: 유형 1은 장3도, 유형 3은 단6도 — 서로 다르다', () {
      final problem = problemOf(c4, e4);

      final type1 = AnswerChecker.grade(
        problem: problem,
        mode: easyType1,
        submitted: '',
      );
      final type3 = AnswerChecker.grade(
        problem: problem,
        mode: easyType3,
        submitted: '',
      );

      expect(type1.correctAnswerText, isNot(type3.correctAnswerText));
      expect(type1.correctAnswerText, '장3도');
      expect(type3.correctAnswerText, '단6도');
    });
  });

  group('임시표가 정답을 바꾼다 (C4-E4 기준, 장3도)', () {
    test('sharp: 위 음에 샵 -> 증3도 / 감6도', () {
      final problem = problemOf(c4, e4, const ['none', 'sharp']);

      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '증3도',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        '감6도',
      );
    });

    test('flat: 아래 음에 플랫 -> 증3도 / 감6도', () {
      final problem = problemOf(c4, e4, const ['flat', 'none']);

      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '증3도',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        '감6도',
      );
    });

    test('double flat: 위 음에 더블플랫 -> 감3도 / 증6도', () {
      final problem = problemOf(c4, e4, const ['none', 'double flat']);

      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '감3도',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        '증6도',
      );
    });

    test('double sharp: 위 음에 더블샵 -> 겹증3도 / 겹감6도', () {
      final problem = problemOf(c4, e4, const ['none', 'double sharp']);

      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '겹증3도',
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        '겹감6도',
      );
    });

    test('임시표 없음(none)은 장3도 그대로다', () {
      final problem = problemOf(c4, e4, const ['none', 'none']);

      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '장3도',
      );
    });
  });

  group('isCorrect — 제출값과 정확히 일치할 때만 true', () {
    // UI는 "장3" 처럼 "도" 접미사 없이 제출한다.
    // correctAnswerText는 "장3도" 처럼 "도"가 붙어 화면에 표시된다.
    // isCorrect는 접미사 없는 원형(korean)과 비교한다.
    final problem = problemOf(c4, e4);

    test('유형 1: "장3"은 정답, "장3도"(표시 문자열)는 오답', () {
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '장3',
        ).isCorrect,
        isTrue,
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType1,
          submitted: '장3도',
        ).isCorrect,
        isFalse,
      );
    });

    test('유형 2: "미"는 정답, 그 외는 오답', () {
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType2,
          submitted: '미',
        ).isCorrect,
        isTrue,
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType2,
          submitted: '레',
        ).isCorrect,
        isFalse,
      );
    });

    test('유형 3: "단6"은 정답, "단6도"(표시 문자열)는 오답', () {
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '단6',
        ).isCorrect,
        isTrue,
      );
      expect(
        AnswerChecker.grade(
          problem: problem,
          mode: easyType3,
          submitted: '단6도',
        ).isCorrect,
        isFalse,
      );
    });

    test('빈 문자열이나 엉뚱한 값은 세 유형 모두 오답', () {
      for (final submitted in ['', 'X']) {
        expect(
          AnswerChecker.grade(
            problem: problem,
            mode: easyType1,
            submitted: submitted,
          ).isCorrect,
          isFalse,
        );
        expect(
          AnswerChecker.grade(
            problem: problem,
            mode: easyType2,
            submitted: submitted,
          ).isCorrect,
          isFalse,
        );
        expect(
          AnswerChecker.grade(
            problem: problem,
            mode: easyType3,
            submitted: submitted,
          ).isCorrect,
          isFalse,
        );
      }
    });
  });

  group('인자 순서 무관성 (sortedPitches가 내부에서 정렬)', () {
    test('유형 1/3: lower/upper를 바꿔 넣어도 같은 정답이 나온다', () {
      final forward = problemOf(c4, e4); // lower=C4, upper=E4
      final reversed = problemOf(e4, c4); // lower=E4, upper=C4

      expect(
        AnswerChecker.grade(
          problem: forward,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        AnswerChecker.grade(
          problem: reversed,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
      );
      expect(
        AnswerChecker.grade(
          problem: forward,
          mode: easyType1,
          submitted: '',
        ).correctAnswerText,
        '장3도',
      );

      expect(
        AnswerChecker.grade(
          problem: forward,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        AnswerChecker.grade(
          problem: reversed,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
      );
      expect(
        AnswerChecker.grade(
          problem: forward,
          mode: easyType3,
          submitted: '',
        ).correctAnswerText,
        '단6도',
      );
    });

    test(
      '유형 2는 순서 무관이 아니다 — upper 필드가 "가려진 음"을 가리키므로 '
      '순서를 바꾸면 다른 질문이 된다',
      () {
        final forward = problemOf(c4, e4); // upper=E4 -> "미"
        final reversed = problemOf(e4, c4); // upper=C4 -> "도"

        expect(
          AnswerChecker.grade(
            problem: forward,
            mode: easyType2,
            submitted: '',
          ).correctAnswerText,
          '미',
        );
        expect(
          AnswerChecker.grade(
            problem: reversed,
            mode: easyType2,
            submitted: '',
          ).correctAnswerText,
          '도',
        );
      },
    );
  });

  test(
    '생성된 모든 문제는 크래시 없이 채점되고 정답 텍스트가 비지 않는다 '
    '(원본 앱의 크래시·빈칸 버그 회귀 방지, 6개 모드 x 1000회)',
    () {
      for (final mode in ProblemMode.all) {
        final generator = ProblemGenerator(random: Random(4242));
        for (var i = 0; i < 1000; i++) {
          final problem = generator.next(mode: mode);
          final grading = AnswerChecker.grade(
            problem: problem,
            mode: mode,
            submitted: 'X',
          );
          expect(
            grading.correctAnswerText,
            isNotEmpty,
            reason: '$mode $problem 의 정답 텍스트가 비었다',
          );
        }
      }
    },
  );
}
