import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intervalpractice/domain/staff_layout.dart';
import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/answer_checker.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/state/ad_counter.dart';
import 'package:intervalpractice/ui/quiz/answer_pad.dart';
import 'package:intervalpractice/ui/quiz/quiz_page.dart';
import 'package:intervalpractice/ui/quiz/staff_view.dart';

Widget wrap(Widget child) => ChangeNotifierProvider(
      create: (_) => AdCounter(),
      child: ScreenUtilInit(
        designSize: const Size(375, 844),
        builder: (context, _) => MaterialApp(home: child),
      ),
    );

void main() {
  _type2Answerable();

  testWidgets('유형 1은 오선지와 도수 버튼을 보여준다', (tester) async {
    await tester.pumpWidget(
      wrap(
        const QuizPage(
          mode: ProblemMode(
            difficulty: Difficulty.easy,
            questionType: QuestionType.nameTheInterval,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(StaffView), findsOneWidget);
    expect(find.byType(AnswerPad), findsOneWidget);
    expect(find.text('음정의 간격을 고르세요'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('유형 2는 계이름 버튼을 보여준다', (tester) async {
    await tester.pumpWidget(
      wrap(
        const QuizPage(
          mode: ProblemMode(
            difficulty: Difficulty.easy,
            questionType: QuestionType.nameTheNote,
          ),
        ),
      ),
    );
    await tester.pump();

    // 유형 2는 "어떤 음정인지" 와 "위/아래 어느 쪽인지" 를 반드시 보여줘야
    // 한다. 둘 중 하나라도 없으면 계이름 7개 중 찍는 문제가 된다.
    expect(find.textContaining('주어진 음정 :'), findsOneWidget);
    expect(
      find.textContaining('계이름은?'),
      findsOneWidget,
      reason: '가려진 음이 위인지 아래인지 알려줘야 한다',
    );
    expect(find.text('도'), findsOneWidget);
    expect(find.text('시'), findsOneWidget);
  });

  testWidgets('AppBar 제목은 난이도를 따른다', (tester) async {
    await tester.pumpWidget(
      wrap(
        const QuizPage(
          mode: ProblemMode(
            difficulty: Difficulty.hard,
            questionType: QuestionType.nameTheInterval,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Hard'), findsOneWidget);
  });
}

// ---------------------------------------------------------------------------
// 유형 2가 풀 수 있는 문제인지 지키는 회귀 테스트.
//
// 리팩토링 중 "주어진 음정" 표시와 "위↑/아래↓" 안내가 빠져서, 음표 하나만
// 보고 계이름 7개 중 찍어야 하는 상태로 프로덕션에 나갔다.
// ---------------------------------------------------------------------------
void _type2Answerable() {
  test('유형 2에 필요한 정보가 도메인에서 나온다', () {
    // 인덱스가 작을수록 높은 음(0 = D6, 18 = G3).
    final hiddenAbove = IntervalProblem(
      lower: StaffLayout.byIndex(10), // 보이는 음 (아래쪽)
      upper: StaffLayout.byIndex(6), // 가려진 음 (위쪽)
      accidentals: const ['none', 'none'],
    );
    final hiddenBelow = IntervalProblem(
      lower: StaffLayout.byIndex(6),
      upper: StaffLayout.byIndex(10),
      accidentals: const ['none', 'none'],
    );

    expect(AnswerChecker.hiddenNoteIsAbove(hiddenAbove), isTrue);
    expect(AnswerChecker.hiddenNoteIsAbove(hiddenBelow), isFalse);

    // 주어진 음정 문구는 비어 있으면 안 된다.
    for (final p in [hiddenAbove, hiddenBelow]) {
      final text = AnswerChecker.givenIntervalText(p);
      expect(text, endsWith('도'));
      expect(text.length, greaterThan(2));
    }
  });

  test('생성되는 모든 유형 2 문제에 주어진 음정이 표시된다', () {
    for (final mode in ProblemMode.all) {
      if (mode.questionType != QuestionType.nameTheNote) continue;

      final generator = ProblemGenerator(random: Random(77));
      for (var i = 0; i < 300; i++) {
        final problem = generator.next(mode: mode);
        expect(
          AnswerChecker.givenIntervalText(problem),
          endsWith('도'),
          reason: '$mode $problem 의 주어진 음정이 비었다',
        );
      }
    }
  });
}
