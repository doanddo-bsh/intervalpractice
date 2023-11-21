import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lottie/lottie.dart';
import 'secondePageFunc/secondePageList.dart';
import 'secondePageFunc/secondePageFunc.dart';

class SecondePageProblem extends StatefulWidget {
  const SecondePageProblem({super.key});

  @override
  State<SecondePageProblem> createState() => _SecondePageProblemState();
}

class _SecondePageProblemState extends State<SecondePageProblem> {


  // List<double> note_height_list = [31,42,55,67.5,81,94.5,108,121.5];
  late List<double> randomItems ;
  late List<int> randomNoteNumber ;
  late List<dynamic> randomNote ;
  double downNoteLeft = 180.0;

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

  // 음정과 음정이름을 함께 보여주는 버튼을 생성하는 함수
  Widget secondeElevatedButton(String intervalName,String intervalNumber){
    return ElevatedButton(
        onPressed: (){
          setState(() {
            answerInterval = intervalNameKorEng[intervalName] + intervalNumber;
            print(answerInterval);
            showBottomResult(answerInterval!);
          });
        },
        child: Text(intervalName + intervalNumber)
    );
  }

  Widget showIntervalNameBefore(String intervalNumber){
    return SizedBox(
      child: Column(
        children: [
          Text('음정 이름을 고르세요'),
          const SizedBox(height: 10.0,),
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
          const SizedBox(height: 10.0,),
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

  Widget showAnswer(String? answerInterval){
    if (answerInterval == null){
      return SizedBox(height: 10.0,);
    } else {
      return showAnswerBefore(answerInterval);
    }
  }

  Widget showAnswerBefore(String answerInterval){

    String answerReal = randomNote[0].interval(randomNote[1]).toString();

    print('answerReal $answerReal');
    print('answerInterval $answerInterval');

    if (answerInterval == answerReal){
      print(answerInterval);
      return Text('정답입니다.');
    } else {
      print(answerInterval);
      return Text('오답입니다. 정답은' + answerReal);
    }
  }

  void showBottomResult(String answerInterval){

    String answerReal = randomNote[0].interval(randomNote[1]).toString();
    String answerRealKor = '';

    if (answerReal.length==2){
      answerRealKor = intervalNameEngKor[answerReal.substring(0, 1)] +
          answerReal.substring(1, 2);
    } else {
      answerRealKor = intervalNameEngKor[answerReal.substring(0, 2)] +
          answerReal.substring(2, 3);
    }

    if (answerInterval == answerReal){

      showModalBottomSheet<void>(
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
                  const Text('정답입니다.'),
                  (problemNumber!=10)? nextProblem('다음문제') : showResult()
                ],
              ),
            ),
          );
        },
      );

    } else {
      showModalBottomSheet<void>(
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
                  const Text('오답입니다.'),
                  Text('정답은 ${answerRealKor} 입니다.'),
                  const Text('풀이 : ...'),
                  (problemNumber!=10)? nextProblem('') : showResult()
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

          note_height_list = shuffle(
            note_height_list,
            randomItems,
          );

          setState(() {
            // 문제 적용
            randomItems = [note_height_list[0][0],note_height_list[1][0]];
            randomItems.sort();
            randomNoteNumber = [note_height_list[0][1],note_height_list[1][1]];
            randomNoteNumber.sort();
            randomNote = [note_height_list[0][2],note_height_list[1][2]];
            randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

            problemNumber += 1;
          });

          if ((note_height_list[0][1]-note_height_list[1][1]).abs()==1){
            setState(() {
              downNoteLeft = 207;
            });
          } else {
            setState(() {
              downNoteLeft = 180;
            });
          }

          Navigator.pop(context);

        }, child: Text(buttonText)
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
                                                      child: Text('85점',
                                                          style: TextStyle(
                                                              fontSize: 60,
                                                              fontWeight: FontWeight.bold
                                                          )),
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
                                                  child: Text('10문제중에서 8문제를 맞췄습니다',
                                                      style:
                                                      TextStyle(
                                                          fontSize: 20,
                                                          fontWeight: FontWeight.bold
                                                      ))),
                                              SizedBox(height: 20,),
                                              Container(
                                                height: 40,
                                                width: 300,
                                                child: ElevatedButton(
                                                  child: Text('틀린 문제 다시 풀기',
                                                    style: TextStyle(
                                                        color: Colors.grey[700]
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.yellow[200]

                                                  ),
                                                  onPressed: () {},
                                                ) ,
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
                                              ElevatedButton(onPressed: (){
                                                setState(() {
                                                  problemNumber = 1 ;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10)
                                                      )
                                                  ),
                                                  child: Text('네',
                                                    style: TextStyle(
                                                        color: Colors.grey[700]
                                                    ),)
                                              ),
                                              nextProblem('네'),
                                              SizedBox(width: 40,),
                                              ElevatedButton(onPressed: (){},
                                                  style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10)
                                                      )
                                                  ),
                                                  child: Text('아니오',
                                                      style: TextStyle(
                                                          color: Colors.grey[700]))
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
    double percent = problemNumber / 10;
    return Column(
      children: [
        // Container(
        //   alignment: FractionalOffset(percent, 1 - percent),
        //   child: FractionallySizedBox(
        //       child: Image.asset('assets/icons/cycling_person.png',
        //           width: 30, height: 30, fit: BoxFit.cover)),
        // ),
        LinearPercentIndicator(
          padding: EdgeInsets.zero,
          percent: percent,
          lineHeight: 20.h,
          center: Text(problemNumber.toString() + '/10'),
          backgroundColor: Colors.black12,
          progressColor: Colors.amber,
          width: MediaQuery.of(context).size.width-50.w,
        )
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 새로운 문제 생성
    note_height_list.shuffle();

    while (
    // 7음정 넘게 차이날 경우 다시 생성
    ((note_height_list[0][1]-note_height_list[1][1]).abs()>7)
    ){
      note_height_list.shuffle();
    }

    randomItems = [note_height_list[0][0],note_height_list[1][0]];
    randomItems.sort();
    randomNoteNumber = [note_height_list[0][1],note_height_list[1][1]];
    randomNoteNumber.sort();
    randomNote = [note_height_list[0][2],note_height_list[1][2]];
    randomNote.sort();

    print(randomItems);
    print(randomNoteNumber);
    print(randomNote);
    print(randomNote[0].interval(randomNote[1]).toString());

    if ((note_height_list[0][1]-note_height_list[1][1]).abs()==1){
      downNoteLeft = 207;
    } else {
      downNoteLeft = 180;
    }
  }

  @override
  Widget build(BuildContext context) {

    print(MediaQuery.of(context).size.width);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chart Page"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              lastRidingProgress()
            ]
          ),
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
              Positioned(
                top: randomItems[0].h,
                left: downNoteLeft.w,
                child: SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: Image.asset('assets/whole_note_lean.png'),
                ),
              ),
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
              addLineDown(randomNoteNumber[0],randomNoteNumber[1]),
            ]
          ),
          const SizedBox(height: 10.0,),
          ElevatedButton(onPressed: (){
            setState(() {
              problemNumber = 10;
            });
          }, child: Text('test')),
          Text('음정 번호를 쓰세요'),
          const SizedBox(height: 10.0,),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '1';
                        });
                      }, child: const Text('1')),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '2';
                        });
                      }, child: const Text('2')),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '3';
                        });
                      }, child: const Text('3')),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '4';
                        });
                      }, child: const Text('4')),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0,),
                SizedBox(
                  height: 30.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '5';
                        });
                      }, child: const Text('5')),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '6';
                        });
                      }, child: const Text('6')),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '7';
                        });
                      }, child: const Text('7')),
                      ElevatedButton(onPressed: (){
                        setState(() {
                          intervalNumber = '8';
                        });
                      }, child: const Text('8')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.0,),
          showIntervalName(intervalNumber),
          SizedBox(height: 30,),
          showAnswer(answerInterval),
        ],
      ),
    );
  }
}
