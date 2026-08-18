import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'state/ad_counter.dart';
import 'theme/app_theme.dart';
import 'ui/common/loading_page.dart';

class IntervalPracticeApp extends StatelessWidget {
  const IntervalPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AdCounter())],
      child: ScreenUtilInit(
        designSize: const Size(375, 844),
        builder: (context, child) {
          return MaterialApp(
            title: '음정박사',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            // 다크모드는 의도적으로 꺼 두었다 — 수요가 없다고 판단.
            //
            // 구현은 전부 남아 있다(`AppTheme.dark`, `LineArtImage` 의 반전,
            // `ThemeController`, 다크 골든). 되살리려면 두 곳만 되돌리면 된다:
            //   1. 여기: MultiProvider 에
            //      `ChangeNotifierProvider(create: (_) => ThemeController()..load())`
            //      를 추가하고, themeMode 를
            //      `context.watch<ThemeController>().mode` 로 바꾼다.
            //   2. `lib/ui/home/home_page.dart` 의 `_BottomActions` 에
            //      토글 IconButton 을 되살린다(주석으로 남겨 둠).
            themeMode: ThemeMode.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            ),
            home: child,
          );
        },
        child: const LoadingPage(),
      ),
    );
  }
}
