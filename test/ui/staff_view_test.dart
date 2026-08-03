import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/staff_layout.dart';
import 'package:intervalpractice/theme/app_theme.dart';
import 'package:intervalpractice/ui/quiz/staff_view.dart';

Widget wrap(Widget child, ThemeData theme) => ScreenUtilInit(
  designSize: const Size(375, 844),
  builder: (context, _) => MaterialApp(theme: theme, home: Scaffold(body: child)),
);

void main() {
  final problem = IntervalProblem(
    lower: StaffLayout.byIndex(8),
    upper: StaffLayout.byIndex(12),
    accidentals: const ['sharp', 'none'],
  );

  testWidgets('다크 테마에서 악보 이미지에 색 필터가 적용된다', (tester) async {
    await tester.pumpWidget(wrap(StaffView(problem: problem), AppTheme.dark));
    await tester.pump();

    expect(find.byType(ColorFiltered), findsWidgets);
  });

  testWidgets('라이트 테마에서는 색 필터를 적용하지 않는다', (tester) async {
    await tester.pumpWidget(wrap(StaffView(problem: problem), AppTheme.light));
    await tester.pump();

    expect(find.byType(ColorFiltered), findsNothing);
  });
}
