import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResultTestPage extends StatefulWidget {
  const ResultTestPage({Key? key}) : super(key: key);

  @override
  State<ResultTestPage> createState() => _ResultTestPageState();
}

class _ResultTestPageState extends State<ResultTestPage> {
  @override
  Widget build(BuildContext context) {

    bool wrongProblemMode = true ;
    int numberOfRight = 5 ;
    List wrongProblemsSave = [1,2,3,4,5,6,7,8,9,10];

    Widget wrongProblemSolveStart(String buttonText){
      return ElevatedButton(

        onPressed: () {
        },
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[200]
        ),
        child: Text('틀린 문제 다시 풀기',
          style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 15
          ),
        ),
      );
    };

    Widget nextProblemResult(){
      return ElevatedButton(
          onPressed: (){
          },  style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          )
      ),
          child: Text('네',
            style: TextStyle(
                color: Colors.grey[700]
            ),
          )
      );
    };

    return Container(
      color: Colors.white,
      // decoration: const BoxDecoration(
      //   borderRadius: BorderRadius.only(
      //     topLeft: Radius.circular(30),
      //     topRight: Radius.circular(30),
      //   ),
      // ),
      height: MediaQuery.of(context).size.height * 1.0,
      child: Center(
        child:
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Column(
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 40,),
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
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    letterSpacing: 5
                                ),),
                                height: 46,
                                width: 200,),
                            ),
                          ),
                          Center(
                            child: Container(
                              child: Column(
                                  children: [
                                    SizedBox(height: 80,),
                                    Container(
                                        child: Text('이번 문제의 점수는',
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.grey[700],
                                              decoration: TextDecoration.none,
                                          ),)),
                                    // SizedBox(height: 30,),
                                    Stack(
                                      children:[
                                        Container(
                                          child: Lottie.asset
                                            ('assets/animation/star2.json'),
                                          height: 160,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(15, 35, 0,0),
                                          child: Container(
                                            child:
                                            wrongProblemMode?
                                            Column(
                                              children: [
                                                Text
                                                  ('${
                                                    (numberOfRight/wrongProblemsSave.length *
                                                        100).round()}점',
                                                    style: TextStyle(
                                                      color: Colors.black87,
                                                        decoration: TextDecoration.none,
                                                        fontSize: 60,
                                                        fontWeight: FontWeight.bold
                                                    )
                                                ),
                                                Text('(5/10)',style: TextStyle(fontSize: 15),)
                                              ],
                                            ):Text
                                              ('${
                                                (numberOfRight/10 *
                                                    100).round()}점',
                                                style: TextStyle(
                                                    fontSize: 60,
                                                    fontWeight: FontWeight.bold
                                                )
                                            ),
                                          ),
                                        ),
                                      ],),
                                    SizedBox(height: 15,),
                                    Container(
                                        child: Text('정말 멋져요! 내가바로 음정고수🎉',
                                            style: TextStyle(
                                                decoration: TextDecoration.none,
                                                fontSize: 18,
                                                color: Colors.grey[700]
                                            ))),
                                    SizedBox(height: 5,),
                                    // Container(
                                    //     child: wrongProblemMode?
                                    //     Text
                                    //       ('${wrongProblemsSave.length
                                    //         .toString()}문제 중 '
                                    //         '${numberOfRight}문제를 '
                                    //         '맞췄습니다',
                                    //         style:
                                    //         TextStyle(
                                    //             color: Colors.grey[700],
                                    //             decoration: TextDecoration.none,
                                    //             fontSize: 18,
                                    //             fontWeight: FontWeight.bold
                                    //         )
                                    //     ) : Text
                                    //       ('10문제중에서 '
                                    //         '${numberOfRight}문제를 '
                                    //         '맞췄습니다',
                                    //         style:
                                    //         TextStyle(
                                    //             fontSize: 20,
                                    //             fontWeight: FontWeight.bold
                                    //         )
                                    //     )
                                    // ),
                                    SizedBox(height: 20,),
                                    Container(
                                      height: 40,
                                      width: 300,
                                      child: wrongProblemSolveStart
                                        ('틀린 문제 다시 풀기'),
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
                  padding: const EdgeInsets.fromLTRB(0, 1, 0, 2),
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
                            width: 600,
                            height: 400,
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
                                    color: Colors.black87,
                                    decoration: TextDecoration.none,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold
                                ),),
                              ),
                              SizedBox(height: 13,),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    nextProblemResult(),
                                    SizedBox(width: 40,),
                                    ElevatedButton(
                                      onPressed: (){
                                        // wrongProblems = [];
                                        // wrongProblemMode = false ;
                                        // numberOfRight = 0 ;
                                        Navigator.popUntil
                                          (context, ModalRoute.withName(Navigator.defaultRouteName));
                                      },
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
}
