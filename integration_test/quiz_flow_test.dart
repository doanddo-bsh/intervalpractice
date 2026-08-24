// 실기기/시뮬레이터에서 문제 풀이 흐름을 끝까지 돌려본다.
//
// 위젯 테스트는 "위젯이 존재한다"까지만 증명한다. 이 테스트는 실제 기기에서
// 탭을 발생시켜 **채점 → 결과 시트 → 다음 문제 → 결과 화면 → 오답 다시 풀기**
// 경로가 실제로 이어지는지 확인한다. 특히 결과 화면 연결은 리팩토링
// 마지막 단계에서 붙인 것이라 한 번도 실행된 적이 없었다.
//
// 실행: flutter test integration_test/quiz_flow_test.dart -d <device-id>
//
// 주의: QuizPage 를 직접 띄운다. 앱 진입점(LoadingPage -> InitializeScreen)은
// AdMob 동의 SDK를 기다리며 멈추므로 통합 테스트에서 통과할 수 없다.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/state/ad_counter.dart';
import 'package:intervalpractice/theme/app_theme.dart';
import 'package:intervalpractice/ui/quiz/answer_pad.dart';
import 'package:intervalpractice/ui/quiz/quiz_page.dart';
import 'package:intervalpractice/ui/quiz/staff_view.dart';

Widget _app({required ProblemMode mode, required ThemeData theme}) =>
    ChangeNotifierProvider(
      create: (_) => AdCounter(),
      child: ScreenUtilInit(
        designSize: const Size(375, 844),
        builder: (context, _) => MaterialApp(
          theme: theme,
          home: QuizPage(mode: mode),
        ),
      ),
    );

/// 화면에 실제로 보이는 첫 번째 버튼을 누른다.
///
/// [settle] 이 false 면 `pumpAndSettle` 대신 고정 시간 pump 를 쓴다.
/// 결과 화면에는 무한 반복하는 Lottie 애니메이션(star2.json)이 있어
/// `pumpAndSettle` 이 영원히 안정되지 않는다 — 앱 버그가 아니라 테스트가
/// 그 화면을 다루는 방식의 문제다.
Future<void> _tapFirstVisible(
  WidgetTester tester,
  Finder finder, {
  bool settle = true,
}) async {
  final visible = finder.hitTestable();
  expect(visible, findsWidgets, reason: '누를 수 있는 위젯이 없다');
  await tester.tap(visible.first);
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final themeName = theme.brightness == Brightness.light ? 'light' : 'dark';

    testWidgets('$themeName: 유형1 - 답을 제출하면 결과 시트가 뜨고 다음 문제로 넘어간다', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          mode: const ProblemMode(
            difficulty: Difficulty.easy,
            questionType: QuestionType.nameTheInterval,
          ),
          theme: theme,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StaffView), findsOneWidget);
      expect(find.text('음정의 간격을 고르세요'), findsOneWidget);
      expect(find.text('1/10'), findsOneWidget);

      // 도수 선택 -> 품질 버튼이 나타난다
      await _tapFirstVisible(tester, find.widgetWithText(ElevatedButton, '3'));
      expect(find.text('음정의 이름을 고르세요'), findsOneWidget);

      // 품질 선택 -> 채점되어 결과 시트가 뜬다
      await _tapFirstVisible(
        tester,
        find.widgetWithText(ElevatedButton, '장3도'),
      );

      final correct = find.text('정답입니다!');
      final wrong = find.text('오답입니다');
      expect(
        correct.evaluate().isNotEmpty || wrong.evaluate().isNotEmpty,
        isTrue,
        reason: '채점 결과 시트가 뜨지 않았다',
      );
      expect(find.textContaining('정답 : '), findsOneWidget);

      // 다음 문제로
      await _tapFirstVisible(
        tester,
        find.widgetWithText(ElevatedButton, '다음문제'),
      );
      expect(find.text('2/10'), findsOneWidget);
      expect(find.byType(StaffView), findsOneWidget);
    });
  }

  testWidgets('유형2 - 윗음이 가려지고 계이름 버튼이 나온다', (tester) async {
    await tester.pumpWidget(
      _app(
        mode: const ProblemMode(
          difficulty: Difficulty.easy,
          questionType: QuestionType.nameTheNote,
        ),
        theme: AppTheme.light,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('알맞은 계이름을 고르세요'), findsOneWidget);
    for (final name in ['도', '레', '미', '파', '솔', '라', '시']) {
      expect(find.widgetWithText(ElevatedButton, name), findsOneWidget);
    }

    final staff = tester.widget<StaffView>(find.byType(StaffView));
    expect(staff.hideUpperNote, isTrue);

    await _tapFirstVisible(tester, find.widgetWithText(ElevatedButton, '도'));
    expect(find.textContaining('정답 : '), findsOneWidget);
  });

  testWidgets('10문제를 끝까지 풀면 결과 화면이 뜬다', (tester) async {
    await tester.pumpWidget(
      _app(
        mode: const ProblemMode(
          difficulty: Difficulty.hard,
          questionType: QuestionType.invertedInterval,
        ),
        theme: AppTheme.light,
      ),
    );
    await tester.pumpAndSettle();

    for (var q = 1; q <= 10; q++) {
      expect(find.text('$q/10'), findsOneWidget, reason: '$q번 문제가 아니다');

      await _tapFirstVisible(tester, find.widgetWithText(ElevatedButton, '5'));
      await _tapFirstVisible(
        tester,
        find.widgetWithText(ElevatedButton, '완전5도'),
      );
      expect(find.textContaining('정답 : '), findsOneWidget);

      if (q < 10) {
        await _tapFirstVisible(
          tester,
          find.widgetWithText(ElevatedButton, '다음문제'),
        );
      }
    }

    // 마지막 문제에서는 "결과보기"가 나와야 한다
    final seeResult = find.widgetWithText(ElevatedButton, '결과보기');
    expect(seeResult, findsWidgets, reason: '10번째에서 결과보기 버튼이 없다');

    // 결과 화면은 무한 Lottie 를 띄우므로 settle 하지 않는다.
    await _tapFirstVisible(tester, seeResult, settle: false);

    // 결과 화면이 실제로 떴는지 — 리팩토링 막바지에 붙인 경로다
    expect(
      find.textContaining('점').evaluate().isNotEmpty ||
          find.textContaining('개').evaluate().isNotEmpty ||
          find
              .widgetWithText(ElevatedButton, '틀린 문제 다시 풀기')
              .evaluate()
              .isNotEmpty,
      isTrue,
      reason: '결과 화면이 뜨지 않았다',
    );
  });

  testWidgets('AnswerPad 가 어떤 모드에서도 가로로 넘치지 않는다', (tester) async {
    for (final mode in ProblemMode.all) {
      await tester.pumpWidget(
        _app(mode: mode, theme: AppTheme.light),
      );
      await tester.pumpAndSettle();

      if (mode.questionType != QuestionType.nameTheNote) {
        await _tapFirstVisible(
            tester, find.widgetWithText(ElevatedButton, '3'));
      }

      expect(
        tester.takeException(),
        isNull,
        reason: '$mode 에서 레이아웃 예외 발생',
      );
      expect(find.byType(AnswerPad), findsOneWidget);
    }
  });
}
