import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'state/ad_counter.dart';
import 'ui/common/loading_page.dart';

class IntervalPracticeApp extends StatelessWidget {
  const IntervalPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdCounter(),
      child: ScreenUtilInit(
        designSize: const Size(375, 844),
        builder: (context, child) => MaterialApp(
          title: '음정박사',
          debugShowCheckedModeBanner: false,
          // TODO(Task 19): AppTheme의 M3 ColorScheme로 교체한다.
          theme: ThemeData.light(useMaterial3: true),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: ThemeMode.system,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
          home: child,
        ),
        child: const LoadingPage(),
      ),
    );
  }
}
