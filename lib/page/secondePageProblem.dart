import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:music_notes/music_notes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';

class SecondePageProblem extends StatefulWidget {
  const SecondePageProblem({super.key});

  @override
  State<SecondePageProblem> createState() => _SecondePageProblemState();
}

class _SecondePageProblemState extends State<SecondePageProblem> {

  // list 변경
  // before
  // List<double> note_height_list = [31,42,55,67.5,81,94.5,108,121.5];
  // after
  Map intervalNameKorEng = {
    '감' : 'd',
    '완전' : 'P',
    '증' : 'A',
    '겹감' : 'dd',
    '단' : 'm',
    '장' : 'M',
    '겹증' : 'AA',
  };

  Map intervalNameEngKor = {
    'd':'감',
    'P':'완전',
    'A':'증',
    'dd':'겹감',
    'm':'단',
    'M':'장',
    'AA':'겹증',
  };


  List<List<dynamic>> note_height_list =
  [
    [4.0,0,Note.b.inOctave(5)],
    [17.0,1,Note.a.inOctave(5)],
    [29.0,2,Note.g.inOctave(5)],
    [42.0,3,Note.f.inOctave(5)],
    [55.0,4,Note.e.inOctave(5)],
    [67.5,5,Note.d.inOctave(5)],
    [81.0,6,Note.c.inOctave(5)],
    [94.5,7,Note.b.inOctave(4)],
    [108.0,8,Note.a.inOctave(4)],
    [121.5,9,Note.g.inOctave(4)],
    [133.0,10,Note.f.inOctave(4)],
    [145.0,11,Note.e.inOctave(4)],
    [159.0,12,Note.d.inOctave(4)],
    [172.0,13,Note.c.inOctave(4)],
    [184.0,14,Note.b.inOctave(3)],
  ];
  // List<double> note_height_list = [31,42,55,67.5,81,94.5,108,121.5];
  late List<double> randomItems ;
  late List<int> randomNoteNumber ;
  late List<dynamic> randomNote ;
  double downNoteLeft = 180.0;

  bool setEquals<T>(Set<T>? a, Set<T>? b) {
    if (a == null) {
      return b == null;
    }
    if (b == null || a.length != b.length) {
      return false;
    }
    if (identical(a, b)) {
      return true;
    }
    for (final T value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }

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
                  nextProblem(),
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
                  nextProblem(),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget nextProblem(){
    return ElevatedButton(

        onPressed: (){
          if (problemNumber==10){
            print('afterProblemTen');
            afterProblemTen();
            setState(() {
              problemNumber = 0;
            });
          }

          // 새로운 문제 생성
          note_height_list.shuffle();
          // 이전 문제와 동일하지 않게 방지 하는 장치
          // 동일하면 while문이 계속 실행
          print((note_height_list[0][1]-note_height_list[1][1]).abs());
          while (
          // 이전 문제와 동일하지 않게 방지 하는 장치
          setEquals(
              [note_height_list[0][0],note_height_list[1][0]].toSet(),
              [randomItems[0],randomItems[1]].toSet())
          // 7음정 넘게 차이날 경우 다시 생성
          |((note_height_list[0][1]-note_height_list[1][1]).abs()>7)
          ){
            note_height_list.shuffle();
          }

          setState(() {
            // 문제 적용
            randomItems = [note_height_list[0][0],note_height_list[1][0]];
            randomItems.sort();
            randomNoteNumber = [note_height_list[0][1],note_height_list[1][1]];
            randomNoteNumber.sort();

            answerInterval = null;
            intervalNumber = null;

            problemNumber += 1;
          });

          print((note_height_list[0][1]-note_height_list[1][1]).abs());
          if ((note_height_list[0][1]-note_height_list[1][1]).abs()==1){
            setState(() {
              downNoteLeft = 207;
            });
          } else {
            setState(() {
              downNoteLeft = 180;
            });
          }

          randomNote = [note_height_list[0][2],note_height_list[1][2]];
          randomNote.sort();

          print(randomItems);
          print(randomNoteNumber);
          print(randomNote);
          print(randomNote[0].interval(randomNote[1]));

          Navigator.pop(context);
          // List randomItems = note_height_list.take(2).toList();
        }, child: const Text('다음문제')
    );
  }

  int problemNumber = 0 ;

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

  // 문제 10문제 다 푼 다음 창
  void afterProblemTen(){
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
          height: 600,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('열문제 다 풀었다!.'),
              ],
            ),
          ),
        );
      },
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
              Positioned(
                top: randomItems[0].h,
                left: downNoteLeft.w,
                child: SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: Image.asset('assets/whole_note_lean.png'),
                ),
              ),
              Positioned(
                top: randomItems[1].h,
                left: 180.w,
                child: SizedBox(
                  width: 50.w,
                  height: 50.h,
                  child: Image.asset('assets/whole_note_lean.png'),
                ),
              ),
              addLineDown(randomNoteNumber[0],randomNoteNumber[1]),
            ]
          ),
          const SizedBox(height: 10.0,),
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
