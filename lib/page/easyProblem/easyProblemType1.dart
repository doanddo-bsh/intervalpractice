import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intervalpractice/page/problemFunc/colorList.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lottie/lottie.dart';
import '../problemFunc/problemFunc.dart';
import '../problemFunc/problemVarList.dart';
// import '../secondePageFunc/problemFunc.dart';
import 'package:music_notes/music_notes.dart';
import '../problemFunc/problemFuncDeco.dart';

class EasyProblemType1 extends StatefulWidget {
  const EasyProblemType1({super.key});

  @override
  State<EasyProblemType1> createState() => _EasyProblemType1State();
}

class _EasyProblemType1State extends State<EasyProblemType1> {


  // List<double> note_height_list = [31,42,55,67.5,81,94.5,108,121.5];
  List<double> randomItems = [];
  late List<int> randomNoteNumber ;
  late List<dynamic> randomNote ;

  List<List<int>> wrongProblems = [];
  List<List<int>> wrongProblemsSave = [];

  bool wrongProblemMode = false ;

  // double downNoteLeft = 180.0;

  int numberOfRight = 0 ;

  // 도 에서 추가 줄 만들기
  Widget addLineDown(int noteNumber1,int noteNumber2){
    if (
    ((noteNumber1==11)&(noteNumber2==13))
    |((noteNumber1==12)&(noteNumber2==14))
    |((noteNumber1==11)&(noteNumber2==14))
    |((noteNumber1==12)&(noteNumber2==13))
    ){
      return Positioned(
        top: 172.h,
        left: 180.w,
        child: SizedBox(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if (
    ((noteNumber1==13)&(noteNumber2==14))
    ){
      return Positioned(
        top: 172.h,
        left: 170.w,
        child: SizedBox(
          width: 100.w,
          height: 50.h,
          child: Image.asset('assets/five_long.png'),
        ),
      );
    } else if (
    ((noteNumber2==13))
    ){
      return Positioned(
        top: 172.h,
        left: 155.w,
        child: SizedBox(
          width: 100.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    }  else if (
    ((noteNumber2==14))
    ){
      return Positioned(
        top: 172.h,
        left: 155.w,
        child: SizedBox(
          width: 100.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if (
    (noteNumber1==0)&(noteNumber2==3)
    |(noteNumber1==1)&(noteNumber2==3)
    |(noteNumber1==0)&(noteNumber2==2)
    // |(noteNumber1==0)&(noteNumber2==1)
    // |(noteNumber1==1)&(noteNumber2==2)
    ) {
      return Positioned(
        top: 17.h,
        left: 180.w,
        child: SizedBox(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if ((noteNumber1==1)&(noteNumber2==2)) {
      return Positioned(
        top: 17.h,
        left: 207.w,
        child: SizedBox(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if ((noteNumber1==0)&(noteNumber2==1)) {
      return Positioned(
        top: 17.h,
        left: 170.w,
        child: SizedBox(
          width: 100.w,
          height: 50.h,
          child: Image.asset('assets/five_long.png'),
        ),
      );
    } else if ((noteNumber1==1)) {
      return Positioned(
        top: 17.h,
        left: 155.w,
        child: SizedBox(
          width: 100.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if ((noteNumber1==0)) {
      return Positioned(
        top: 17.h,
        left: 155.w,
        child: SizedBox(
          width: 100.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    }
    else {
      return const SizedBox();
    }
  }

  String? intervalNumber = null;

  Widget intervalNumberButton(String number){
    return ElevatedButton(
        onPressed: answerInterval==null?
            (){
          setState(() {intervalNumber = number;});
        } :
            (){
          // print('정답이 이미 들어옴');
        },
        child: Text(
          number,
          style: answerButtonTextDesign,
        ),
        style: answerButtonDesign(intervalNumber,number,'easy',context)
        // ElevatedButton.styleFrom(
        //   backgroundColor:
        //   intervalNumber==number ?
        //   Color(0xffdcdcdc) :
        //   Theme.of(context).colorScheme.onTertiary,
        //   foregroundColor: Color(0xff7e8d7e)
        // )
    );
  }

  // 음정과 음정이름을 함께 보여주는 버튼을 생성하는 함수
  Widget secondeElevatedButton(String intervalName,String intervalNumber){
    return ElevatedButton(
        onPressed: answerInterval==null?
            () {
                setState(() {
                  answerInterval = intervalNameKorEng[intervalName] + intervalNumber;

                  showBottomResult(answerInterval!);
                });
              }:
            (){
              // print('정답이 이미 들어옴');
            },
        child: Text(
            intervalName + intervalNumber + '도',
            style: answerButtonTextDesign
        ),
        style: answerButtonDesign(answerInterval,intervalNameKorEng[intervalName] + intervalNumber,'easy',context)
        // ElevatedButton.styleFrom(
        //   backgroundColor:
        //   answerInterval==intervalNameKorEng[intervalName] + intervalNumber ?
        //   Color(0xffccccff) :
        //   Theme.of(context).colorScheme.onTertiary,
        //     foregroundColor: Color(0xff7e8d7e)
        // )
    );
  }

  Widget showIntervalNameBefore(String intervalNumber){
    return SizedBox(
      child: Column(
        children: [
          Text('음정의 이름을 고르세요',style: explainTextStyle),
          const SizedBox(height: 25.0,),
          SizedBox(
            height: 30.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                secondeElevatedButton(
                    '감',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '완전',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '증',
                    intervalNumber
                ),
              ],
            ),
          ),
          const SizedBox(height: 13.0,),
          SizedBox(
            height: 30.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                secondeElevatedButton(
                    '겹감',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '단',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '장',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '겹증',
                    intervalNumber
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showIntervalName(String? intervalNumber){
    if (intervalNumber == null){
      return SizedBox(height: 100,);
    } else {
      return showIntervalNameBefore(intervalNumber);
    }
  }

  String? answerInterval = null;

  void showBottomResult(String answerInterval){

    List<dynamic> randomNoteAnswer = [] ;

    randomNoteAnswer.add(randomNote[0]);
    randomNoteAnswer.add(randomNote[1]);

    randomNoteAnswer.sort();

    String answerReal = randomNoteAnswer[0].interval(randomNoteAnswer[1]).toString();
    String answerRealKor = '';

    if (answerReal.length==2){
      answerRealKor = intervalNameEngKor[answerReal.substring(0, 1)] +
          answerReal.substring(1, 2);
    } else {
      answerRealKor = intervalNameEngKor[answerReal.substring(0, 2)] +
          answerReal.substring(2, 3);
    }

    if (answerInterval == answerReal){

      setState(() {
        numberOfRight += 1 ;
      });

      showModalBottomSheet<void>(
        backgroundColor: color5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0)
          )
        ),
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 7),
                  Text(answerRealKor + '도',
                      style: TextStyle(
                        color: color4,
                        fontSize : 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                  SizedBox(height: 7,),
                  Text('정답입니다!',
                          style: TextStyle(
                            color: color4,
                            fontWeight: FontWeight.bold
                          ),),
                  SizedBox(height: 7,),
                  wrongProblemMode?
                  (wrongProblemsSave.length != problemNumber)?
                  wrongProblemNextProblem('다음문제') :
                  showResult() :
                  (problemNumber!=10)?
                  nextProblem('다음문제') :
                  showResult(),
                  // (problemNumber!=10)? nextProblem('다음문제') : showResult()
                ],
              ),
            ),
          );
        },
      );

    } else {

      wrongProblems += [randomNoteNumber] ;

      print('wrongProblems $wrongProblems');

      showModalBottomSheet<void>(
        backgroundColor: Color(0xffd7b1b1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            )
        ),
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(answerRealKor + '도',
                    style: TextStyle(
                      fontSize : 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('오답입니다.'),
                  Text('정답은 ${answerRealKor} 입니다.'),
                  const Text('풀이 : ...'),
                  wrongProblemMode?
                  (wrongProblemsSave.length != problemNumber)?
                  wrongProblemNextProblem('다음문제') :
                  showResult() :
                  (problemNumber!=10)?
                  nextProblem('다음문제') :
                  showResult(),
                  // (problemNumber!=10)? nextProblem('다음문제') : showResult()
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget nextProblem(String buttonText){
    return ElevatedButton(

        onPressed: (){
          if (problemNumber==10){
            setState(() {
              problemNumber = 0;
            });
          }

          List<List<dynamic>> note_height_list_problem = getProblemListNote(
            note_height_list,
            randomItems,
          );

          setState(() {
            // 문제 적용
            randomItems = [note_height_list_problem[0][0],note_height_list_problem[1][0]];
            // randomItems.sort();
            randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
            // randomNoteNumber.sort();
            randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
            // randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

            problemNumber += 1;
          });

          // if ((randomNoteNumber[0]-randomNoteNumber[1]).abs()==1){
          //   setState(() {
          //     downNoteLeft = 207;
          //   });
          // } else if ((randomNoteNumber[0]-randomNoteNumber[1
          // ]).abs()==0){
          //   setState(() {
          //     downNoteLeft = 207;
          //   });
          // } else {
          //   setState(() {
          //     downNoteLeft = 180;
          //   });
          // }

          Navigator.pop(context);

        },
      style: nextProblemButtonStyle('easy'),
      child: Text(buttonText,
        style: nextProblemButtonTextStyle,
      ),
    );
  }


  Widget nextProblemResult(){
    return ElevatedButton(

        onPressed: (){

          numberOfRight = 0 ;
          wrongProblems = [];
          wrongProblemMode = false ;

          List<List<dynamic>> note_height_list_problem = getProblemListNote(
            note_height_list,
            randomItems,
          );

          setState(() {
            // 문제 적용
            randomItems = [note_height_list_problem[0][0],note_height_list_problem[1][0]];
            // randomItems.sort();
            randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
            // randomNoteNumber.sort();
            randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
            // randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

          });

          setState(() {
            problemNumber = 1 ;
          });

          Navigator.pop(context);


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
  }


  Widget wrongProblemNextProblem(String buttonText){
    return ElevatedButton(
        onPressed: (){

          setState(() {

            problemNumber += 1;

            // 문제 적용
            randomNoteNumber = wrongProblemsSave[problemNumber-1];
            // randomNoteNumber.sort();

            randomItems =
            [note_height_list_fix[randomNoteNumber[0]][0],
              note_height_list_fix[randomNoteNumber[1]][0]];
            // randomItems.sort();
            randomNote =
            [note_height_list_fix[randomNoteNumber[0]][2],
              note_height_list_fix[randomNoteNumber[1]][2]];
            // randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

          });

          Navigator.pop(context);

        },
        style: nextProblemButtonStyle('easy'),
        child: Text(buttonText,
          style: nextProblemButtonTextStyle,
        ),
    );
  }


  Widget wrongProblemSolveStart(String buttonText){
    return ElevatedButton(

        onPressed: (wrongProblems.isEmpty) ? null:(){

          numberOfRight = 0 ;
          // back up
          wrongProblemsSave = wrongProblems ;
          print('wrongProblemsSave $wrongProblemsSave');
          print('wrongProblems $wrongProblems');
          wrongProblems = [] ;

          setState(() {
            // 문제 적용
            randomNoteNumber = wrongProblemsSave[0];
            // randomNoteNumber.sort();

            randomItems =
            [note_height_list_fix[randomNoteNumber[0]][0],
              note_height_list_fix[randomNoteNumber[1]][0]];
            // randomItems.sort();
            randomNote =
            [note_height_list_fix[randomNoteNumber[0]][2],
              note_height_list_fix[randomNoteNumber[1]][2]];
            // randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

          });

          setState(() {
            problemNumber = 1 ;
            wrongProblemMode = true ;
          });

          Navigator.pop(context);
        },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.yellow[200]
      ),
        child: Text('틀린 문제 다시 풀기',
          style: TextStyle(
              color: Colors.grey[700]
          ),
        ),
    );
  }

  Widget showResult(){

    // Navigator.pop(context);

    return ElevatedButton(
        onPressed: (){

          Navigator.pop(context);

          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                height: MediaQuery.of(context).size.height * 1.0,
                child: Center(
                  child:
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                          height: 450.h,
                                          color: Colors.lightGreen.withOpacity(0.4),
                                        ),),
                                    ),
                                    Center(
                                      child: Container(
                                        child: Column(
                                            children: [
                                              SizedBox(height: 60,),
                                              Container(
                                                  child: Text('이번 문제의 점수는',
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.grey[700]
                                                    ),)),
                                              // SizedBox(height: 30,),
                                              Stack(
                                                children:[
                                                  Container(
                                                    child: Lottie.asset
                                                      ('assets/animation/star2.json'),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.fromLTRB(40, 60, 0, 0),
                                                    child: Container(
                                                      child:
                                                      wrongProblemMode?
                                                      Text
                                                        ('${
                                                        (numberOfRight/wrongProblemsSave.length *
                                                          100).round()}점',
                                                          style: TextStyle(
                                                              fontSize: 60,
                                                              fontWeight: FontWeight.bold
                                                          )
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
                                              // SizedBox(height: 30,),
                                              Container(
                                                  child: Text('정말 멋져요! 내가바로 음정고수🎉',
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: Colors.grey[700]
                                                      ))),
                                              SizedBox(height: 20,),
                                              Container(
                                                  child: wrongProblemMode?
                                                  Text
                                                    ('${wrongProblemsSave.length
                                                      .toString()}문제중에서 '
                                                      '${numberOfRight}문제를 '
                                                      '맞췄습니다',
                                                      style:
                                                      TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold
                                                      )
                                                  ) : Text
                                                    ('10문제중에서 '
                                                      '${numberOfRight}문제를 '
                                                      '맞췄습니다',
                                                      style:
                                                      TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold
                                                      )
                                                  )
                                              ),
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
                                                    wrongProblems = [];
                                                    wrongProblemMode = false ;
                                                    numberOfRight = 0 ;
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
            },
          );
        },
        child: Text('결과보기')
    );
  }

  int problemNumber = 1 ;

  Widget returnLine(double top){
    return Positioned(
        top: top.h,
        left: 10.w,
        right: 10.w,
        child:
        Container(
          color: Colors.black,
          width: double.infinity,
          height: 2.0.h,
        )
    );
  }

  // 덧줄용1
  Widget addLine1(PositionedNote randomNote){

    // middle line
    List<PositionedNote> middleLine = [
      Note.a.inOctave(5),
      Note.f.inOctave(5),
      Note.d.inOctave(5),
      Note.b.inOctave(4),
      Note.g.inOctave(4),
      Note.e.inOctave(4),
      Note.c.inOctave(4),
      Note.a.inOctave(3),
      Note.c.inOctave(6),
    ];
    // low line
    List<PositionedNote> lowLine = [
      Note.b.inOctave(5),
      Note.d.inOctave(6),
    ];

    // high line
    List<PositionedNote> highLine = [
      Note.b.inOctave(3),
      Note.g.inOctave(3)
    ];

    if (middleLine.contains(randomNote)){
      return
        Positioned(
        top: 12.75.h,
        child: Container(
          color: Colors.black,
          height: 2.0.h,
          width: 50.w,
        ),
      );
    } else if (lowLine.contains(randomNote)) {
      return
        Positioned(
          top: 24.5.h,
          child: Container(
            color: Colors.black,
            height: 2.0.h,
            width: 50.w,
          ),
        );
    } else if (highLine.contains(randomNote)){
      return
        Positioned(
          child: Container(
            color: Colors.black,
            height: 2.0.h,
            width: 50.w,
          ),
        );
    }
    else {
      return SizedBox();
    }
  }


  // 덧줄용2
  Widget addLine2(PositionedNote randomNote, double left){

    // highhigh line
    List<PositionedNote> highHighLine = [
      Note.d.inOctave(6),
      Note.c.inOctave(6),
    ];
    // lowlow line
    List<PositionedNote> lowLowLine = [
      Note.a.inOctave(3),
      Note.g.inOctave(3),
    ];

    if (highHighLine.contains(randomNote)){
      return
        Positioned(
          top: 63.5.h,
          left: left,
          child: Container(
            color: Colors.black,
            height: 2.0.h,
            width: 50.w,
          ),
        );
    } else if (lowLowLine.contains(randomNote)) {
      return
        Positioned(
          top: 222.5.h,
          left: left,
          child: Container(
            color: Colors.black,
            height: 2.0.h,
            width: 50.w,
          ),
        );
    }
    else {
      return SizedBox();
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 새로운 문제 생성

    List<List<dynamic>> note_height_list_problem = getProblemListNote(
      note_height_list, randomItems
    );

    randomItems = [note_height_list_problem[0][0],note_height_list_problem[1][0]];
    // randomItems.sort();
    randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
    // randomNoteNumber.sort();
    randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
    // randomNote.sort();

  }

  @override
  Widget build(BuildContext context) {

    print('randomNote $randomNote');


    List<dynamic> randomNoteAnswerTemp = [] ;

    randomNoteAnswerTemp.add(randomNote[0]);
    randomNoteAnswerTemp.add(randomNote[1]);

    randomNoteAnswerTemp.sort();

    String answerRealTemp = randomNoteAnswerTemp[0].interval
      (randomNoteAnswerTemp[1]).toString();
    String answerRealKorTemp = '';

    if (answerRealTemp.length==2){
      answerRealKorTemp = intervalNameEngKor[answerRealTemp.substring(0, 1)] +
          answerRealTemp.substring(1, 2);
    } else {
      answerRealKorTemp = intervalNameEngKor[answerRealTemp.substring(0, 2)] +
          answerRealTemp.substring(2, 3);
    }

    print('answerRealTemp $answerRealTemp');
    print('answerRealKorTemp $answerRealKorTemp');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: wrongProblemMode?
        Text("오답문제",
            style: appBarTitleStyle
        ) :
        Text("Easy",
          style: appBarTitleStyle,
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: appBarIcon,
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          lastRidingProgress(
            wrongProblemMode,
            problemNumber,
            wrongProblemsSave,
            'easy',
            context,
          ),
          // SizedBox(height: 5,),
          Container(
            height: 300.h,
            width: double.infinity,
            decoration: BoxDecoration(
              // border: Border.all(color: Colors.black)
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0.h,
                  bottom: 0.h,
                  left: 10.0.w,
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child:Image.asset('assets/treble_clef_ff_cut.png',
                        height: 180.h,
                      ),
                  ),
                ),
                returnLine(90.0),
                returnLine(116.5),
                returnLine(143.0),
                returnLine(169.5),
                returnLine(196.0),
                Positioned(
                  top: randomItems[0].h,
                  left: 130.w,
                  child: SizedBox(
                    height: 26.5.h,
                    child: Stack(
                      children: [
                        Image.asset('assets/whole_note_lean.png'),
                        addLine1(randomNote[0]),
                      ],
                    ),
                  ),
                ),
                addLine2(randomNote[0],130.w),
                // 음표 2
                Positioned(
                  top: randomItems[1].h,
                  left: 230.w,
                  child: SizedBox(
                    height: 26.5.h,
                    child: Stack(
                      children: [
                        Image.asset('assets/whole_note_lean.png'),
                        addLine1(randomNote[1]),
                      ],
                    ),
                  ),
                ),
                addLine2(randomNote[1],230.w),
              ],
            ),
          ),
          // const SizedBox(height: 10.0,),
          // ElevatedButton(onPressed: (){
          //   setState(() {
          //     problemNumber = 10;
          //   });
          // }, child: Text('test')),
          Text('음정의 간격을 고르세요',style: explainTextStyle),
          const SizedBox(height: 25.0,),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      intervalNumberButton('1'),
                      intervalNumberButton('2'),
                      intervalNumberButton('3'),
                      intervalNumberButton('4'),
                    ],
                  ),
                ),
                const SizedBox(height: 13.0,),
                SizedBox(
                  height: 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      intervalNumberButton('5'),
                      intervalNumberButton('6'),
                      intervalNumberButton('7'),
                      intervalNumberButton('8'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50.0,),
          showIntervalName(intervalNumber),
          SizedBox(height: 30,),
        ],
      ),
    );
  }
}
