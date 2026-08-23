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
  const hardType2 = ProblemMode(
    difficulty: Difficulty.hard,
    questionType: QuestionType.nameTheNote,
  );
  const hardType3 = ProblemMode(
    difficulty: Difficulty.hard,
    questionType: QuestionType.invertedInterval,
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

    test('hard 는 세 유형 모두 두 음 다 임시표 없는 문제를 내지 않는다', () {
      // 임시표가 하나도 없으면 같은 유형의 Easy 문제와 구별되지 않는다.
      for (final mode in [hardType1, hardType2, hardType3]) {
        final generator = ProblemGenerator(random: Random(11));

        for (var i = 0; i < 3000; i++) {
          final problem = generator.next(mode: mode);

          expect(
            problem.accidentals.any((a) => a != 'none'),
            isTrue,
            reason: '$mode 에서 임시표 없는 문제가 나왔다: $problem',
          );
        }
      }
    });

    test('hard 유형 2는 한쪽에만 임시표가 붙어 정답이 "없음"인 문제도 낸다', () {
      // "두 음 다 없음"을 막는 것과 "가려진 음이 없음"을 막는 것은 다르다.
      // 후자까지 막으면 답안 패드의 `없음` 버튼이 영원히 오답이 되어
      // 5지선다가 4지선다로 줄어든다. 보이는 음에만 임시표가 붙는 경우는
      // 계속 나와야 한다.
      final generator = ProblemGenerator(random: Random(11));
      var hiddenWithoutAccidental = 0;

      for (var i = 0; i < 1000; i++) {
        final problem = generator.next(mode: hardType2);

        if (problem.hiddenAccidental == 'none') {
          hiddenWithoutAccidental++;
          expect(
            problem.accidentals[0],
            isNot('none'),
            reason: '가려진 음이 "없음"이면 보이는 음에는 임시표가 있어야 한다: $problem',
          );
        }
      }

      // 한쪽만 붙는 62.5% 중 절반이 보이는 음 쪽 -> 약 31%.
      expect(hiddenWithoutAccidental, inInclusiveRange(200, 420));
    });

    test('hard 는 네 가지 임시표를 고르게 섞어 낸다', () {
      // 겹임시표가 홑임시표에 비해 극단적으로 드물면 Hard 가 사실상
      // "#/b 만 나오는 모드"가 된다. 명목 비율은 홑 30% / 겹 20% 씩이다.
      final generator = ProblemGenerator(random: Random(11));
      final counts = <String, int>{
        'sharp': 0,
        'flat': 0,
        'double sharp': 0,
        'double flat': 0,
      };

      for (var i = 0; i < 5000; i++) {
        for (final accidental in generator.next(mode: hardType1).accidentals) {
          if (accidental != 'none') counts[accidental] = counts[accidental]! + 1;
        }
      }

      final placed = counts.values.reduce((a, b) => a + b);

      // 홑 30% / 겹 20% 를 목표로 하되, 답할 수 없는 후보가 재추첨되며
      // 생기는 편차를 감안해 폭을 넉넉히 둔다.
      for (final kind in const ['sharp', 'flat']) {
        expect(
          counts[kind]! / placed,
          inInclusiveRange(0.25, 0.38),
          reason: '$kind 비율이 목표(30%)에서 크게 벗어남: $counts',
        );
      }
      for (final kind in const ['double sharp', 'double flat']) {
        expect(
          counts[kind]! / placed,
          inInclusiveRange(0.13, 0.26),
          reason: '$kind 비율이 목표(20%)에서 크게 벗어남: $counts',
        );
      }
    });

    test('직전 문제와 같은 음 조합을 연속 출제하지 않는다', () {
      final generator = ProblemGenerator(random: Random(3));
      var previous = generator.next(mode: easyType1);

      for (var i = 0; i < 100; i++) {
        final current = generator.next(mode: easyType1, previous: previous);
        final samePair = {current.lower.index, current.upper.index}.difference(
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
      for (final mode in [hardType1, hardType2, hardType3]) {
        final generator = ProblemGenerator(random: Random(2026));

        for (var i = 0; i < 2000; i++) {
          final problem = generator.next(mode: mode);
          final pitches = problem.sortedPitches;
          final interval = pitches[0].interval(pitches[1]);

          expect(
            KoreanInterval.isAnswerable(interval),
            isTrue,
            reason: '답할 수 없는 음정 출제됨($mode): $problem -> '
                '${KoreanInterval.intervalAbbreviation(interval)}',
          );
          expect(
            KoreanInterval.isAnswerable(interval.inversion),
            isTrue,
            reason: '자리바꿈이 답할 수 없음($mode): $problem -> '
                '${KoreanInterval.intervalAbbreviation(interval.inversion)}',
          );
        }
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
