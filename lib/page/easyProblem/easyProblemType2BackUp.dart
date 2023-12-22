import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lottie/lottie.dart';
import '../problemFunc/problemFunc.dart';
import '../problemFunc/problemVarList.dart';
import 'dart:math';
// import '../secondePageFunc/problemFunc.dart';

class EasyProblemType2 extends StatefulWidget {
  const EasyProblemType2({super.key});

  @override
  State<EasyProblemType2> createState() => _EasyProblemType2State();
}

class _EasyProblemType2State extends State<EasyProblemType2> {


  // List<double> note_height_list = [31,42,55,67.5,81,94.5,108,121.5];
  late List<double> randomItems ;
  late List<int> randomNoteNumber ;
  late List<dynamic> randomNote ;

  int upDown = 0 ;

  List<List<int>> wrongProblems = [];
  List<List<int>> wrongProblemsSave = [];

  bool wrongProblemMode = false ;

  double downNoteLeft = 180.0;

  int numberOfRight = 0 ;

  // 도 에서 추가 줄 만들기
  Widget addLineDown(int noteNumber){
    if ((noteNumber==13)){
      return Positioned(
        top: 172.h,
        left: 155.w,
        child: SizedBox(
          width: 50.w,
          height: 50.h,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if ((noteNumber==13)){
      return Positioned(
        top: 172.h,
        left: 155.w,
        child: SizedBox(
          width: 50.w,
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
          setState(() {
            intervalNumber = number;
            // print();
            showBottomResult(intervalNumber!);
          });
        } :
            (){
          // print('정답이 이미 들어옴');
        },
        child: Text(number),
        style: ElevatedButton.styleFrom(
          backgroundColor:
          intervalNumber==number ?
          Color(0xffccccff) :
          Theme.of(context).colorScheme.onTertiary,
        )
    );
  }

  String? answerInterval = null;

  void showBottomResult(String answerPitchName){

    String answerReal = randomNote[0].interval(randomNote[1]).toString();
    String answerRealKor = '';

    if (answerReal.length==2){
      answerRealKor = intervalNameEngKor[answerReal.substring(0, 1)] +
          answerReal.substring(1, 2);
    } else {
      answerRealKor = intervalNameEngKor[answerReal.substring(0, 2)] +
          answerReal.substring(2, 3);
    }

    var ptichNameReal = (upDown == 0)? randomNote[1]:randomNote[0];

    String ptichNameRealKr = pitchNameEngToKr[ptichNameReal] ;

    if (answerPitchName == ptichNameRealKr){

      setState(() {
        numberOfRight += 1 ;
      });

      showModalBottomSheet<void>(
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(answerPitchName,
                    style: TextStyle(
                      fontSize : 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('정답입니다.'),
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
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(ptichNameRealKr,
                    style: TextStyle(
                      fontSize : 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('오답입니다.'),
                  Text('정답은 ${ptichNameRealKr} 입니다.'),
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
            randomItems.sort();
            randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
            randomNoteNumber.sort();
            randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
            randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

            problemNumber += 1;
          });

          setState(() {
            upDown = Random().nextInt(2);
          });

          // if ((randomNoteNumber[0]-randomNoteNumber[1]).abs()==1){
          //   setState(() {
          //     downNoteLeft = 207.w;
          //   });
          // } else if ((randomNoteNumber[0]-randomNoteNumber[1
          // ]).abs()==0){
          //   setState(() {
          //     downNoteLeft = 207.w;
          //   });
          // } else {
          //   setState(() {
          //     downNoteLeft = 180.w;
          //   });
          // }

          print(randomNote[0].interval(randomNote[1]).toString());

          Navigator.pop(context);

        }, child: Text(buttonText)
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
            randomItems.sort();
            randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
            randomNoteNumber.sort();
            randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
            randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

          });

          setState(() {
            upDown = Random().nextInt(2);
          });

          // if ((note_height_list_problem[0][1]-note_height_list_problem[1][1]).abs()==1){
          //   setState(() {
          //     downNoteLeft = 207.w;
          //   });
          // } else if ((randomNoteNumber[0]-randomNoteNumber[1
          // ]).abs()==0){
          //   setState(() {
          //     downNoteLeft = 207.w;
          //   });
          // } else {
          //   setState(() {
          //     downNoteLeft = 180.w;
          //   });
          // }

          print(randomNote[0].interval(randomNote[1]).toString());

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
            // 문제 적용
            randomNoteNumber = wrongProblemsSave[problemNumber];
            randomNoteNumber.sort();

            randomItems =
            [note_height_list_fix[randomNoteNumber[0]][0],
              note_height_list_fix[randomNoteNumber[1]][0]];
            randomItems.sort();
            randomNote =
            [note_height_list_fix[randomNoteNumber[0]][2],
              note_height_list_fix[randomNoteNumber[1]][2]];
            randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

            problemNumber += 1;

          });

          if ((randomNoteNumber[0]-randomNoteNumber[1]).abs()==1){
            setState(() {
              downNoteLeft = 207.w;
            });
          } else if ((randomNoteNumber[0]-randomNoteNumber[1
          ]).abs()==0){
            setState(() {
              downNoteLeft = 207.w;
            });
          } else {
            setState(() {
              downNoteLeft = 180.w;
            });
          }

          print(randomNote[0].interval(randomNote[1]).toString());

          Navigator.pop(context);

        }, child: Text(buttonText)
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
          randomNoteNumber.sort();

          randomItems =
          [note_height_list_fix[randomNoteNumber[0]][0],
            note_height_list_fix[randomNoteNumber[1]][0]];
          randomItems.sort();
          randomNote =
          [note_height_list_fix[randomNoteNumber[0]][2],
            note_height_list_fix[randomNoteNumber[1]][2]];
          randomNote.sort();

          answerInterval = null;
          intervalNumber = null;

        });

        if ((randomNoteNumber[0]-randomNoteNumber[1]).abs()==1){
          setState(() {
            downNoteLeft = 207.w;
          });
        } else if ((randomNoteNumber[0]-randomNoteNumber[1
        ]).abs()==0){
          setState(() {
            downNoteLeft = 207.w;
          });
        } else {
          setState(() {
            downNoteLeft = 180.w;
          });
        }

        setState(() {
          problemNumber = 1 ;
          wrongProblemMode = true ;
        });

        print(randomNote[0].interval(randomNote[1]).toString());

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

  Widget lastRidingProgress() {

    double percent =
    wrongProblemMode?
    double.parse((problemNumber / wrongProblemsSave.length).toStringAsFixed
      (1)) :
    problemNumber / 10 ;

    print(percent);
    print('problemNumber $problemNumber');
    print('wrongProblemsSave.length ${wrongProblemsSave.length}');

    return Column(
      children: [
        Center(
          child: Container(
            // color: Colors.black12,
            width: MediaQuery.of(context).size.width-15.w,
            alignment: FractionalOffset(percent, 1 - percent),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: Container(
                // color: Colors.red,
                  child: Image.asset('assets/noteToProgress.png',
                      width: 20, height: 20, fit: BoxFit.cover)
              ),
            ),
          ),
        ),
        SizedBox(height: 3,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width-50.w,
              padding: EdgeInsets.zero,
              percent: percent,
              lineHeight: 20.h,
              center: wrongProblemMode?
              Text(problemNumber.toString() + '/' + wrongProblemsSave.length
                  .toString()) :
              Text(problemNumber.toString() + '/10') ,
              backgroundColor: Colors.black12,
              progressColor: Colors.amber,
            ),
          ],
        )
      ],
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 새로운 문제 생성

    List<List<dynamic>> note_height_list_problem = getProblemListNote(
        note_height_list,randomItems
    );

    randomItems = [note_height_list_problem[0][0],note_height_list_problem[1][0]];
    randomItems.sort();
    randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
    randomNoteNumber.sort();
    randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
    randomNote.sort();

    upDown = Random().nextInt(2);

    // if ((note_height_list_problem[0][1]-note_height_list_problem[1][1]).abs()==1){
    //   downNoteLeft = 207.w;
    // } else if ((note_height_list_problem[0][1]-note_height_list_problem[1][1
    // ]).abs()==0){
    //   downNoteLeft = 207.w;
    // } else {
    //   downNoteLeft = 180.w;
    // }
  }

  @override
  Widget build(BuildContext context) {

    print(MediaQuery.of(context).size.width);

    return Scaffold(
      appBar: AppBar(
        title: wrongProblemMode? Text("오답 풀이 중") : Text("문제 풀이 중"),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          lastRidingProgress(),
          Stack(
              alignment: Alignment.center,
              children: [
                // 악보
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height:250.h,
                      width: 375.w,
                      child: Image.asset(
                        'assets/music_five_line.png',
                        // fit: BoxFit.fitWidth,
                        // alignment: Alignment.center,
                      ),
                    ),
                  ],
                ),
                // 음표 1
                (upDown != 0)?
                Positioned(
                  top: randomItems[0].h,
                  left: 180.w,
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Image.asset('assets/whole_note_lean.png'),
                  ),
                ):
                // 음표 2
                Positioned(
                  top: randomItems[1].h,
                  left: 180.w,
                  child: SizedBox(
                    width: 50.w,
                    height: 50.h,
                    child: Image.asset('assets/whole_note_lean.png'),
                  ),
                ),
                // 필요시 덧줄
                (upDown != 0)?
                addLineDown(randomNoteNumber[0]):
                addLineDown(randomNoteNumber[1]),
              ]
          ),
          const SizedBox(height: 10.0,),
          ElevatedButton(onPressed: (){
            setState(() {
              problemNumber = 10;
            });
          }, child: Text('test')),
          (randomNote[0].interval(randomNote[1]).toString().length==2)?
          Text('주어진 음정 ${intervalNameEngKor[randomNote[0].interval(randomNote[1]).toString().substring(0, 1)] +
              randomNote[0].interval(randomNote[1]).toString().substring(1,
                  2)}'):
          Text('주어진 음정 ${intervalNameEngKor[randomNote[0].interval(randomNote[1]).toString().substring(0, 2)] +
              randomNote[0].interval(randomNote[1]).toString().substring(2, 3)}'),
          (upDown != 0)?
          Text('주어진 음정을 만들려면 필요한 아래 계이름은?'):
          Text('주어진 음정을 만들려면 필요한 위에 계이름은?'),
          const SizedBox(height: 10.0,),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      intervalNumberButton('도'),
                      intervalNumberButton('레'),
                      intervalNumberButton('미'),
                      intervalNumberButton('파'),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0,),
                SizedBox(
                  height: 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      intervalNumberButton('솔'),
                      intervalNumberButton('라'),
                      intervalNumberButton('시'),
                      // intervalNumberButton('8'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
