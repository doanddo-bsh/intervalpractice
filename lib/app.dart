import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'state/ad_counter.dart';
import 'state/theme_controller.dart';
import 'theme/app_theme.dart';
import 'ui/common/loading_page.dart';

class IntervalPracticeApp extends StatelessWidget {
  const IntervalPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdCounter()),
        // 저장된 밝기 모드를 불러온다. 불러오기 전에는 system 이므로
        // 첫 프레임이 OS 설정으로 그려졌다가 사용자 선택으로 바뀐다.
        ChangeNotifierProvider(create: (_) => ThemeController()..load()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 844),
        builder: (context, child) {
          final themeMode = context.watch<ThemeController>().mode;

          return MaterialApp(
            title: '음정박사',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
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
