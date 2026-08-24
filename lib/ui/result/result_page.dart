// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// 10문제(또는 오답 복습 문제) 완주 후 보여주는 점수/재도전 시트.
///
/// 기존에는 6개 화면에 거의 동일한 코드가 복붙되어 있었다. 여기서는
/// `QuizSession`이 이미 들고 있는 값(정답 수, 총 문제 수, 복습 모드 여부)만
/// 받아 그리는 순수 위젯으로 정리했다 — 문제 자체(`List<List<int>>` 형태의
/// 오답 인덱스 쌍)는 더 이상 이 위젯이 알 필요가 없다.
Widget resultPage(
  BuildContext context, {
  required bool wrongProblemMode,
  required int numberOfRight,
  required int totalQuestions,
  required Widget nextProblemResult,
  required Widget wrongProblemSolveStart,
  required VoidCallback onPressedNo,
}) {
  final scoreResult =
      totalQuestions == 0 ? 0 : (numberOfRight / totalQuestions * 100).round();

  const resultPageCommentList = [
    '정말 멋져요! 내가 바로 음정박사🎉',
    '잘 했어요! 나는 이제 음정석사🎉',
    '힘을 내요! 나는 아직 음정학사🎉',
  ];

  final String resultPageComment;
  if (scoreResult >= 70) {
    resultPageComment = resultPageCommentList[0];
  } else if (scoreResult >= 30) {
    resultPageComment = resultPageCommentList[1];
  } else {
    resultPageComment = resultPageCommentList[2];
  }

  final colors = Theme.of(context).colorScheme;

  return Container(
    color: colors.surface,
    height: MediaQuery.of(context).size.height * 1.0,
    child: Center(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w, 40.h, 5.w, 5.h),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 600.w,
                            height: 500.h,
                            color: colors.primaryContainer.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20))),
                            height: 55.h,
                            width: 200.w,
                            child: Text(
                              'CLEAR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: colors.onPrimary,
                                  fontSize: 33,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 5),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100.h,
                        left: 0.w,
                        right: 0.w,
                        child: SizedBox(
                          height: 220.h,
                          width: 220.w,
                          child: Lottie.asset('assets/animation/star2.json'),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            SizedBox(height: 100.h),
                            Text(
                              '이번 문제의 점수는',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: colors.onSurfaceVariant,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 200.h),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(height: 25.h),
                                    Container(
                                      alignment: Alignment.center,
                                      width: 150.w,
                                      height: 100.h,
                                      child: AutoSizeText(
                                        '$scoreResult점',
                                        style: TextStyle(
                                          color: colors.onSurface,
                                          decoration: TextDecoration.none,
                                          fontSize: 60,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AutoSizeText(
                                          '($numberOfRight/$totalQuestions)',
                                          style: const TextStyle(fontSize: 20),
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 17.h),
                            Text(resultPageComment,
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurfaceVariant)),
                            SizedBox(height: 30.h),
                            SizedBox(
                              height: 60.h,
                              width: 290.w,
                              child: wrongProblemSolveStart,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 1.h, 0, 1.h),
                child: const Divider(
                  thickness: 1,
                  indent: 7,
                  endIndent: 7,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 600.w,
                          height: 400.h,
                          color: colors.surfaceContainerHighest,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('계속해서 문제를 푸시겠습니까?',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 17.h),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  nextProblemResult,
                                  SizedBox(width: 40.w),
                                  ElevatedButton(
                                    onPressed: onPressedNo,
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    child: Text('아니오',
                                        style: TextStyle(
                                            color: colors.onSurfaceVariant)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
