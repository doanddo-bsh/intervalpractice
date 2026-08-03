import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/korean_interval.dart';
import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/problem_mode.dart';

void main() {
  const easyType1 = ProblemMode(
    difficulty: Difficulty.easy,
    questionType: QuestionType.nameTheInterval,
  );
  const hardType1 = ProblemMode(
    difficulty: Difficulty.hard,
    questionType: QuestionType.nameTheInterval,
  );

  group('ProblemGenerator', () {
    test('두 음자리를 생성한다', () {
      final generator = ProblemGenerator(random: Random(42));
      final problem = generator.next(mode: easyType1);

      expect(problem.lower.index, isNot(problem.upper.index));
    });

    test('두 음의 간격은 항상 7자리 이하다', () {
      final generator = ProblemGenerator(random: Random(7));

      for (var i = 0; i < 200; i++) {
        final problem = generator.next(mode: easyType1);
        final distance = (problem.lower.index - problem.upper.index).abs();

        expect(distance, lessThanOrEqualTo(7));
      }
    });

    test('easy 모드는 임시표를 붙이지 않는다', () {
      final generator = ProblemGenerator(random: Random(1));

      for (var i = 0; i < 50; i++) {
        final problem = generator.next(mode: easyType1);

        expect(problem.accidentals, ['none', 'none']);
      }
    });

    test('hard 모드는 임시표를 붙일 수 있다', () {
      final generator = ProblemGenerator(random: Random(1));
      var sawAccidental = false;

      for (var i = 0; i < 50; i++) {
        final problem = generator.next(mode: hardType1);
        if (problem.accidentals.any((a) => a != 'none')) {
          sawAccidental = true;
          break;
        }
      }

      expect(sawAccidental, isTrue);
    });

    test('직전 문제와 같은 음 조합을 연속 출제하지 않는다', () {
      final generator = ProblemGenerator(random: Random(3));
      var previous = generator.next(mode: easyType1);

      for (var i = 0; i < 100; i++) {
        final current = generator.next(mode: easyType1, previous: previous);
        final samePair =
            {current.lower.index, current.upper.index}.difference(
              {previous.lower.index, previous.upper.index},
            ).isEmpty;

        expect(samePair, isFalse);
        previous = current;
      }
    });

    test('생성된 모든 문제는 UI 버튼으로 답할 수 있어야 한다 (원본 크래시 버그 회귀 방지)', () {
      // 원본 앱은 노출 가능한 Hard 조합 1680개 중 8개에서 크래시했고
      // 16개에서 정답이 빈칸이었다. 원인: 겹임시표 금지 가드가 겹임시표를
      // 만들지 않는 분기에만 걸려 있었다.
      final generator = ProblemGenerator(random: Random(2026));

      for (var i = 0; i < 2000; i++) {
        final problem = generator.next(mode: hardType1);
        final pitches = problem.sortedPitches;
        final interval = pitches[0].interval(pitches[1]);

        expect(
          KoreanInterval.isAnswerable(interval),
          isTrue,
          reason: '답할 수 없는 음정 출제됨: $problem -> '
              '${KoreanInterval.intervalAbbreviation(interval)}',
        );
        expect(
          KoreanInterval.isAnswerable(interval.inversion),
          isTrue,
          reason: '자리바꿈이 답할 수 없음: $problem -> '
              '${KoreanInterval.intervalAbbreviation(interval.inversion)}',
        );
      }
    });

    test('같은 seed는 같은 문제열을 만든다 (재현 가능)', () {
      final a = ProblemGenerator(random: Random(99));
      final b = ProblemGenerator(random: Random(99));

      for (var i = 0; i < 20; i++) {
        final pa = a.next(mode: hardType1);
        final pb = b.next(mode: hardType1);

        expect(pa.lower.index, pb.lower.index);
        expect(pa.upper.index, pb.upper.index);
        expect(pa.accidentals, pb.accidentals);
      }
    });
  });
}
