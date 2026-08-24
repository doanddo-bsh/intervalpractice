// 문제 화면을 라이트/다크 양쪽으로 실제 렌더링해 PNG로 남긴다.
//
// 목적은 회귀 검사가 아니라 **육안 검증 자료 생성**이다. 시뮬레이터에서
// ATT 시스템 다이얼로그 때문에 자동 탭이 막혀 문제 화면까지 도달하기
// 어려운데, 다크모드에서 가장 위험한 화면이 바로 이 화면(검은 선화
// 악보 에셋)이라 렌더 결과를 확인할 방법이 필요했다.
//
// 갱신: flutter test --update-goldens test/ui/quiz_golden_test.dart
// 산출물: test/ui/goldens/*.png
//
// 주의: 골든은 기기/폰트 렌더링에 민감하므로 CI 게이트로 쓰지 않는다.
// (.github/workflows/ci.yml 은 이 파일을 --exclude-tags 로 제외한다.)
@Tags(['golden'])
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/domain/staff_layout.dart';
import 'package:intervalpractice/theme/app_theme.dart';
import 'package:intervalpractice/ui/quiz/staff_view.dart';

/// 시드 고정 — 골든이 매번 달라지지 않도록 문제를 직접 만든다.
final _captureKey = GlobalKey();

IntervalProblem _fixedProblem({required List<String> accidentals}) =>
    IntervalProblem(
      lower: StaffLayout.byIndex(8), // C5
      upper: StaffLayout.byIndex(13), // E4
      accidentals: accidentals,
    );

/// 실제 화면과 같은 조건으로 렌더링한다.
///
/// 테마 배경색을 깔지 않으면 다크모드에서 반전된 흰 선화가 투명(=흰) 배경
/// 위에 놓여 가독성을 전혀 판단할 수 없다. `Scaffold`의 배경이 실제로
/// 칠해지도록 `ColoredBox`로 한 겹 감싼다.
Widget _harness({required ThemeData theme, required Widget child}) =>
    ScreenUtilInit(
      designSize: const Size(375, 844),
      builder: (context, _) => MaterialApp(
        theme: theme,
        home: Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: RepaintBoundary(
            key: _captureKey,
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: child,
            ),
          ),
        ),
      ),
    );

void main() {
  // 골든 파일 크기를 고정한다.
  setUp(() {
    // ignore: deprecated_member_use
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('StaffView 렌더', () {
    for (final (label, theme) in [
      ('light', AppTheme.light),
      ('dark', AppTheme.dark),
    ]) {
      testWidgets('임시표 없음 - $label', (tester) async {
        tester.view.physicalSize = const Size(1125, 1200);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _harness(
            theme: theme,
            child: StaffView(
              problem: _fixedProblem(accidentals: const ['none', 'none']),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byKey(_captureKey),
          matchesGoldenFile('goldens/staff_plain_$label.png'),
        );
      });

      testWidgets('임시표 포함 - $label', (tester) async {
        tester.view.physicalSize = const Size(1125, 1200);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          _harness(
            theme: theme,
            child: StaffView(
              problem: _fixedProblem(
                accidentals: const ['sharp', 'double flat'],
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await expectLater(
          find.byKey(_captureKey),
          matchesGoldenFile('goldens/staff_accidentals_$label.png'),
        );
      });
    }
  });

  test('시드 고정 문제는 결정적이다', () {
    final a = _fixedProblem(accidentals: const ['sharp', 'none']);
    final b = _fixedProblem(accidentals: const ['sharp', 'none']);
    expect(a.slotIndices, b.slotIndices);
    expect(Random(1).nextInt(10), Random(1).nextInt(10));
  });

  test('사용된 문제 모드가 유효하다', () {
    expect(ProblemMode.all, hasLength(6));
  });
}
