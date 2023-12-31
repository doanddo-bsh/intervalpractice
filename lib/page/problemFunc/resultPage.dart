import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';



Widget resultPage(context,
    bool wrongProblemMode,
    int numberOfRight,
    List<List<int>> wrongProblemsSave,
    List<List<int>> wrongProblems,
    Widget nextProblemResult,
    Widget wrongProblemSolveStart,
    onPressed_no,
    ){

  int scoreResult ;

  if (wrongProblemMode){
    scoreResult =
      (numberOfRight/wrongProblemsSave.length * 100).round();
  } else {
    scoreResult =
    (numberOfRight/10 *
        100).round();
  }

  List<String> resultPageCommentList = [
    '정말 멋져요! 내가 바로 음정박사🎉',
    '잘 했어요! 나는 이제 음정석사🎉',
    '힘을 내요! 나는 아직 음정학사🎉'
  ];

  String resultPageComment ;

  if (scoreResult>=70){
    resultPageComment =
        resultPageCommentList[0];
  } else if (scoreResult>=30){
    resultPageComment =
    resultPageCommentList[1];
  } else {
    resultPageComment =
    resultPageCommentList[2];
  }

  return Container(
    color: Colors.white,
    height: MediaQuery.of(context).size.height * 1.0,
    child: Center(
      child:
      SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(5.w,40.h,5.w,5.h),
          child: Column(
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h,),
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 600.w,
                              height: 500.h,
                              color: Colors.lightGreen.withOpacity(0.4),
                            ),),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              padding: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                  color: Color(0xff6aab64),
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              child: Text('CLEAR', textAlign: TextAlign.center,
                                style: TextStyle(
                                    decoration: TextDecoration.none,
                                    color: Colors.white,
                                    fontSize: 33,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 5
                                ),),
                              height: 57.h,
                              width: 200.w,),
                          ),
                        ),
                        Center(
                          child: Container(
                            child: Column(
                                children: [
                                  SizedBox(height: 100.h,),
                                  Container(
                                      child: Text('이번 문제의 점수는',
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                            decoration: TextDecoration.none,
                                        ),)),
                                  SizedBox(height: 25.h,),
                                  Stack(
                                    children:[
                                      Container(
                                        child: Lottie.asset
                                          ('assets/animation/star2.json'),
                                        height: 180.h,
                                      ),
                                        Container(
                                          child:
                                          wrongProblemMode?
                                          Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.centerRight,
                                                width: 130.w,
                                                height:100.h,
                                                child: Text
                                                  ('${scoreResult}점',
                                                    style: TextStyle(
                                                        color: Colors.black87,
                                                        decoration: TextDecoration.none,
                                                        fontSize: 60,
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 8.h,),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Text('(${numberOfRight}/${wrongProblemsSave.length})',
                                                    style: TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ):Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.centerRight,
                                                width: 130.w,
                                                height:100.h,
                                                child: Text
                                                  ('${scoreResult}점',
                                                    style: TextStyle(
                                                        fontSize: 60,
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                              ),
                                              SizedBox(height: 8.h,),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Text('(${numberOfRight}/10)',
                                                    style: TextStyle(fontSize: 20),
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                      ),
                                    ],),
                                  SizedBox(height: 17.h,),
                                  Container(
                                      child: Text(resultPageComment,
                                          style: TextStyle(
                                              decoration: TextDecoration.none,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700]
                                          ))),
                                  SizedBox(height: 30.h,),
                                  Container(
                                    height: 56.h,
                                    width: 300.w,
                                    child: wrongProblemSolveStart,
                                      // ('틀린 문제 다시 풀기'),
                                  )
                                ]),
                          ),
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 1.h, 0, 1.h),
                child: Divider(thickness: 1,
                  indent: 7,
                  endIndent: 7,),
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
                          color: Colors.grey[300],
                        ),),
                      Container(
                        margin: EdgeInsets.all(15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(child:
                            Text('계속해서 문제를 푸시겠습니까?',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold
                              ),),
                            ),
                            SizedBox(height: 17.h,),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  nextProblemResult,
                                  SizedBox(width: 40.w,),
                                  ElevatedButton(
                                    onPressed: onPressed_no,
                                    // onPressed: (){
                                    //   wrongProblems = [];
                                    //   wrongProblemMode = false ;
                                    //   numberOfRight = 0 ;
                                    //   Navigator.popUntil
                                    //     (context, ModalRoute.withName(Navigator.defaultRouteName));
                                    // },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10)
                                        )
                                    ),
                                    child: Text('아니오',
                                        style: TextStyle(
                                            color: Colors.grey[700])
                                    ),
                                  )],
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