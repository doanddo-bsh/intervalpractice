import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
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

    expect(find.text('알맞은 계이름을 고르세요'), findsOneWidget);
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
