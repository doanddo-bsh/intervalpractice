// 특성화 테스트 — Commentary.
//
// Task 18b: `lib/domain/commentary.dart`가 만드는 해설 문구를, 프로브로 실제
// 관찰한 값 그대로 전체 문자열 비교(=)로 고정한다. `contains(...)`는 쓰지
// 않는다 — 문구 일부가 우연히 맞아도 전체가 틀릴 수 있기 때문이다.
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/commentary.dart';
import 'package:intervalpractice/domain/korean_interval.dart';
import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/staff_layout.dart';

void main() {
  final c4 = StaffLayout.byIndex(15);
  final e4 = StaffLayout.byIndex(13);
  final f4 = StaffLayout.byIndex(12);

  group('forIntervalQuestion — 임시표 없음', () {
    test('C4-E4, 장3 -> 반음 0개 설명', () {
      final problem = IntervalProblem(
        lower: c4,
        upper: e4,
        accidentals: const ['none', 'none'],
      );

      final result = Commentary.forIntervalQuestion(
        problem.sortedPitches,
        '장3',
      );

      expect(
        result,
        '반음이 0개이므로 장3도 음정입니다 \n(장3도 음정의 기본 반음수는 0개)',
      );
    });

    test('E4-F4, 단2 -> 반음 경계 설명 ("간격이 줄어들어")', () {
      final problem = IntervalProblem(
        lower: e4,
        upper: f4,
        accidentals: const ['none', 'none'],
      );

      final result = Commentary.forIntervalQuestion(
        problem.sortedPitches,
        '단2',
      );

      expect(
        result,
        '반음이 1개이므로 간격이 줄어들어 단2도 음정입니다 \n(장2도 음정의 기본 반음수는 0개)',
      );
    });
  });

  group('forIntervalQuestion — 임시표 있음', () {
    test('C4-E4, 위 음에 샵 -> 증3, 임시표 설명이 앞에 붙는다', () {
      final problem = IntervalProblem(
        lower: c4,
        upper: e4,
        accidentals: const ['none', 'sharp'],
      );

      final result = Commentary.forIntervalQuestion(
        problem.sortedPitches,
        '증3',
      );

      expect(
        result,
        '위에 있는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고 '
        '반음이 0개이므로 증3도 음정입니다 \n(장3도 음정의 기본 반음수는 0개)',
      );
    });

    test('C4-E4, 아래 음에 플랫 -> 증3, 아래쪽 임시표 설명이 붙는다', () {
      final problem = IntervalProblem(
        lower: c4,
        upper: e4,
        accidentals: const ['flat', 'none'],
      );

      final result = Commentary.forIntervalQuestion(
        problem.sortedPitches,
        '증3',
      );

      expect(
        result,
        '아래에 있는 음에 붙은 플렛으로 인해 음정간 간격이 늘어나고 '
        '반음이 0개이므로 증3도 음정입니다 \n(장3도 음정의 기본 반음수는 0개)',
      );
    });

    test('C4-E4, 양쪽에 임시표(아래 플랫 + 위 샵) -> 두 설명이 순서대로 붙는다', () {
      final problem = IntervalProblem(
        lower: c4,
        upper: e4,
        accidentals: const ['flat', 'sharp'],
      );
      final korean = KoreanInterval.fromInterval(
        problem.sortedPitches[0].interval(problem.sortedPitches[1]),
      );

      expect(korean, '겹증3');

      final result = Commentary.forIntervalQuestion(
        problem.sortedPitches,
        korean,
      );

      expect(
        result,
        '아래에 있는 음에 붙은 플렛으로 인해 음정간 간격이 늘어나고 '
        '위에 있는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고 '
        '반음이 0개이므로 겹증3도 음정입니다 \n(장3도 음정의 기본 반음수는 0개)',
      );
    });
  });

  group('forNoteQuestion', () {
    test('C4-E4 (장3도) 의 유형 2 해설', () {
      final problem = IntervalProblem(
        lower: c4,
        upper: e4,
        accidentals: const ['none', 'none'],
      );

      final result = Commentary.forNoteQuestion(problem.sortedPitches);

      expect(
        result,
        '장3도는 반음이 0개입니다 (장3도 음정의 기본 반음수는 0개)',
      );
    });
  });

  group('해설 테이블에 없는 조합', () {
    // 정상적인 게임 플레이로는 도달하지 않는다: ProblemGenerator는 두 음
    // 사이 간격을 7자리 이하로 제한하므로(옥타브 이내), 도수가 8을 넘는
    // 음정은 만들어지지 않는다. 하지만 Commentary.forIntervalQuestion은
    // 임의의 List<Pitch>를 받는 public API이므로, 직접 넓은 음정을 구성해
    // "테이블에 없으면 크래시 대신 빈 문자열을 낸다"를 확인한다.
    test('7자리를 넘는 간격(복합 음정)은 조회에 실패해 빈 문자열을 낸다', () {
      final wide = IntervalProblem(
        lower: StaffLayout.byIndex(0), // D6
        upper: StaffLayout.byIndex(18), // G3
        accidentals: const ['none', 'none'],
      );
      final interval = wide.sortedPitches[0].interval(wide.sortedPitches[1]);
      final korean = KoreanInterval.fromInterval(interval);

      final result = Commentary.forIntervalQuestion(
        wide.sortedPitches,
        korean,
      );

      expect(result, '');
    });
  });
}
