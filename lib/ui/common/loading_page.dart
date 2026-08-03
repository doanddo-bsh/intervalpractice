// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../home/home_page.dart';
import 'initialize_screen.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {

  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(milliseconds: 1500),
        () => Navigator.pushReplacement(
            context,
           MaterialPageRoute(
               builder: (BuildContext context) {
                 return const InitializeScreen(
                         targetWidget: HomePage()
                        );
               }
           ),
        ),
    );
  }

  // ChangeNotifierProvider<Counter>(
  // create: (_) => Counter(),
  // child: problemPage[index]
  // );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 스플래시 화면은 시스템 다크모드 판단 이전에 뜨므로 테마와 무관한
      // 고정 브랜드 색을 쓴다 (근거: lib/theme/app_theme.dart의
      // AppTheme.splashBackground/splashForeground 문서 참고).
      backgroundColor: AppTheme.splashBackground,
      body: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height/2-85,
              left: MediaQuery.of(context).size.width/2-5 ,
              child: Image.asset('assets/note11.png',
                fit: BoxFit.contain,
                height: 80.h,
                width: 80.w,),
            ),
            Center(
              child: Container(
                alignment: Alignment.center,
                child: Lottie.asset('assets/animation/Animation - 1700747597611'
                    '.json'),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height/2+45,
                left: MediaQuery.of(context).size.width/2-38,
                child: const Text('음 정 박 사',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppTheme.splashForeground,
                  ),
                )
            ),
            Positioned(
                top: MediaQuery.of(context).size.height-70.h,
                left: 0,
                right: 0,
                child: const Text("© Copyright 2024, seohwa lee",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.0,
                    color: AppTheme.splashForeground,
                  ),
                  textAlign: TextAlign.center,
                )
            ),
          ]
      ),
    );

  }
}