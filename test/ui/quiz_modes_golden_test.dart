// 6개 문제 유형 × 라이트/다크 = 12가지 조합을 전부 렌더링해 PNG로 남긴다.
//
// 계획서 Task 25의 "라이트/다크 모드 양쪽에서 6개 문제 유형이 정상 동작"
// 항목 중 **렌더링 부분**을 자동화한 것이다. 상호작용(탭해서 채점까지)은
// 여기서 다루지 않는다 — 그건 여전히 실기기 확인이 필요하다.
//
// 갱신: flutter test --update-goldens test/ui/quiz_modes_golden_test.dart
// 산출물: test/ui/goldens/mode_*.png
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/domain/staff_layout.dart';
import 'package:intervalpractice/theme/app_theme.dart';
import 'package:intervalpractice/ui/quiz/answer_pad.dart';
import 'package:intervalpractice/ui/quiz/staff_view.dart';

final _key = GlobalKey();

/// 고정 문제 — 골든이 매번 달라지지 않게 한다.
IntervalProblem _problemFor(ProblemMode mode) => IntervalProblem(
      lower: StaffLayout.byIndex(8), // C5
      upper: StaffLayout.byIndex(13), // E4
      accidentals: mode.usesAccidentals
          ? const ['sharp', 'none']
          : const ['none', 'none'],
    );

void main() {
  for (final mode in ProblemMode.all) {
    for (final (themeLabel, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      final name =
          '${mode.difficulty.name}_${mode.questionType.name}_$themeLabel';

      testWidgets('$name 렌더', (tester) async {
        tester.view.physicalSize = const Size(1125, 2200);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 844),
            builder: (context, _) => MaterialApp(
              theme: theme,
              home: Scaffold(
                backgroundColor: theme.colorScheme.surface,
                body: RepaintBoundary(
                  key: _key,
                  child: ColoredBox(
                    color: theme.colorScheme.surface,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StaffView(
                          problem: _problemFor(mode),
                          hideUpperNote:
                              mode.questionType == QuestionType.nameTheNote,
                        ),
                        AnswerPad(
                          mode: mode,
                          // 유형 1/3의 품질 버튼까지 보이도록 도수를 미리 고른 상태.
                          selectedSize: '3',
                          submittedAnswer: null,
                          onSizeSelected: (_) {},
                          onQualitySelected: (_) {},
                          onNoteSelected: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);

        await expectLater(
          find.byKey(_key),
          matchesGoldenFile('goldens/mode_$name.png'),
        );
      });
    }
  }
}
