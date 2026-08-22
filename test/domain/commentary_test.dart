// 특성화 테스트 — Commentary.
//
// Task 18b: `lib/domain/commentary.dart`가 만드는 해설 문구를, 프로브로 실제
// 관찰한 값 그대로 전체 문자열 비교(=)로 고정한다. `contains(...)`는 쓰지
// 않는다 — 문구 일부가 우연히 맞아도 전체가 틀릴 수 있기 때문이다.
import 'package:flutter_test/flutter_test.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/answer_checker.dart';
import 'dart:math';

import 'package:intervalpractice/domain/commentary.dart';
import 'package:intervalpractice/domain/commentary_data.dart';
import 'package:intervalpractice/domain/korean_interval.dart';
import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/staff_layout.dart';

void main() {
  _reviewRegression();

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

  group('자리바꿈(유형 3) 해설은 임시표가 붙은 음을 화면 기준으로 가리킨다', () {
    // 자리바꿈 해설은 자리를 바꾼 뒤의 음정을 설명하므로 위/아래가 화면과
    // 반대다. 유형 1과 같은 "아래에 있는 음" 문구를 쓰면, 악보에서 위에
    // 그려진 음을 "아래에 있는 음"이라 부르게 되어 계산이 맞는데도 읽는
    // 사람이 반대로 이해한다. 실기기에서 확인된 문제다.
    test('실기기 화면 사례 — 도♯4 + 시bb4, 정답 겹증2도', () {
      final problem = IntervalProblem(
        lower: StaffLayout.byIndex(9), // B4  — 악보에서 위
        upper: StaffLayout.byIndex(15), // C4 — 악보에서 아래
        accidentals: const ['double flat', 'sharp'],
      );
      const mode = ProblemMode(
        difficulty: Difficulty.hard,
        questionType: QuestionType.invertedInterval,
      );

      final grading = AnswerChecker.grade(
        problem: problem,
        mode: mode,
        submitted: '',
      );

      expect(grading.correctAnswerText, '겹증2도');
      expect(
        grading.commentary,
        '자리바꿈하면 아래 음이 한 옥타브 위로 올라가 위아래가 바뀝니다. '
        '아래로 오는 음에 붙은 더블플렛으로 인해 음정간 간격이 늘어나고 '
        '위로 가는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고 '
        '반음이 1개이므로 간격이 줄어들어 겹증2도 음정입니다 '
        '\n(장2도 음정의 기본 반음수는 0개)',
      );
    });

    test('Easy 유형 3 — 임시표가 없어도 자리바꿈 도입 문장이 붙는다', () {
      // 임시표 설명이 통째로 비는 난이도라, 도입 문장이 없으면 해설에
      // 자리바꿈 언급이 하나도 남지 않는다.
      final problem = IntervalProblem(
        lower: StaffLayout.byIndex(13), // E4
        upper: StaffLayout.byIndex(12), // F4
        accidentals: const ['none', 'none'],
      );
      const mode = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.invertedInterval,
      );

      final grading = AnswerChecker.grade(
        problem: problem,
        mode: mode,
        submitted: '',
      );

      expect(grading.correctAnswerText, '장7도');
      expect(
        grading.commentary,
        // 장7도의 기본 반음수도 1개라 "간격이 줄어들어"가 붙지 않는다.
        '자리바꿈하면 아래 음이 한 옥타브 위로 올라가 위아래가 바뀝니다. '
        '반음이 1개이므로 장7도 음정입니다 '
        '\n(장7도 음정의 기본 반음수는 1개)',
      );
    });

    test('유형 1·2 에는 자리바꿈 도입 문장이 붙지 않는다', () {
      final problem = IntervalProblem(
        lower: StaffLayout.byIndex(13), // E4
        upper: StaffLayout.byIndex(12), // F4
        accidentals: const ['none', 'none'],
      );

      for (final mode in ProblemMode.all) {
        if (mode.questionType == QuestionType.invertedInterval) continue;

        final commentary = AnswerChecker.grade(
          problem: problem,
          mode: mode,
          submitted: '',
        ).commentary;

        expect(
          commentary,
          isNot(contains('자리바꿈')),
          reason: '$mode 에 자리바꿈 문구가 새어 들어갔다: $commentary',
        );
      }
    });

    test('유형 1은 기존 "위/아래에 있는 음" 문구를 그대로 쓴다', () {
      final problem = IntervalProblem(
        lower: StaffLayout.byIndex(9), // B4
        upper: StaffLayout.byIndex(15), // C4
        accidentals: const ['double flat', 'sharp'],
      );
      const mode = ProblemMode(
        difficulty: Difficulty.hard,
        questionType: QuestionType.nameTheInterval,
      );

      final grading = AnswerChecker.grade(
        problem: problem,
        mode: mode,
        submitted: '',
      );

      expect(grading.correctAnswerText, '겹감7도');
      expect(grading.commentary, startsWith('아래에 있는 음에 붙은 샵으로'));
      expect(grading.commentary, contains('위에 있는 음에 붙은 더블플렛으로'));
      expect(grading.commentary, isNot(contains('자리바꿈하면')));
    });

    test('생성 가능한 모든 유형 3 문제에서 자리바꿈 전용 문구만 쓴다', () {
      for (final difficulty in Difficulty.values) {
        final mode = ProblemMode(
          difficulty: difficulty,
          questionType: QuestionType.invertedInterval,
        );
        final generator = ProblemGenerator(random: Random(4242));

        for (var i = 0; i < 500; i++) {
          final commentary = AnswerChecker.grade(
            problem: generator.next(mode: mode),
            mode: mode,
            submitted: '',
          ).commentary;

          expect(
            commentary,
            isNot(contains('있는 음에 붙은')),
            reason: '$mode 에 유형 1 문구가 섞였다: $commentary',
          );
          expect(
            commentary,
            startsWith(commentaryInversionLead),
            reason: '$mode 해설이 자리바꿈 설명 없이 시작한다: $commentary',
          );
        }
      }
    });
  });
}

// ---------------------------------------------------------------------------
// 사용자 리뷰로 제보된 버그의 회귀 테스트
//
//   "음정 정답이랑 해설이 정반대임 단2도인데 정답은 장7도 근데 해설은 장7도로 나옴"
//
// 원본 앱은 자리바꿈 문제(유형 3)에서 해설 키를 자리바꿈하지 않은 음정으로
// 뽑으면서 문구에는 자리바꿈된 이름을 넣었다. 결과적으로
// "장7도 음정입니다 (장2도 음정의 기본 반음수는 0개)" 같은 모순이 나왔다.
// ---------------------------------------------------------------------------
void _reviewRegression() {
  group('해설과 정답의 도수가 일치한다 (리뷰 제보 버그)', () {
    test('미4+파4 자리바꿈: 정답 장7도 → 해설도 7도 기준이어야 한다', () {
      final problem = IntervalProblem(
        lower: StaffLayout.byIndex(13), // E4
        upper: StaffLayout.byIndex(12), // F4
        accidentals: const ['none', 'none'],
      );
      const mode = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.invertedInterval,
      );

      final grading = AnswerChecker.grade(
        problem: problem,
        mode: mode,
        submitted: '',
      );

      expect(grading.correctAnswerText, '장7도');
      expect(
        grading.commentary,
        contains('장7도 음정의 기본 반음수'),
        reason: '해설이 자리바꿈된 음정(7도)을 설명해야 한다',
      );
      expect(
        grading.commentary,
        isNot(contains('장2도 음정의 기본 반음수')),
        reason: '원래 음정(2도) 설명이 남아 있으면 안 된다',
      );
    });

    test('생성 가능한 모든 문제에서 해설 도수와 정답 도수가 같다', () {
      final degree = RegExp(r'(\d)도');

      for (final mode in ProblemMode.all) {
        if (mode.questionType == QuestionType.nameTheNote) continue;

        final generator = ProblemGenerator(random: Random(20260818));
        for (var i = 0; i < 500; i++) {
          final problem = generator.next(mode: mode);
          final grading = AnswerChecker.grade(
            problem: problem,
            mode: mode,
            submitted: '',
          );
          if (grading.commentary.isEmpty) continue;

          final answerDegree =
              degree.firstMatch(grading.correctAnswerText)?.group(1);
          // 해설 끝의 "(...N도 음정의 기본 반음수는 ...)" 안의 도수
          final explained = RegExp(r'\((?:완전|장|단|증|감|겹증|겹감)?(\d)도')
              .firstMatch(grading.commentary)
              ?.group(1);

          if (explained == null) continue;
          expect(
            explained,
            answerDegree,
            reason: '$mode $problem\n'
                '  정답 ${grading.correctAnswerText}\n'
                '  해설 ${grading.commentary}',
          );
        }
      }
    });
  });
}
