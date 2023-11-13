import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:music_notes/music_notes.dart';


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
  List<List<dynamic>> note_height_list =
  [
    [4.0,0,Note.b.inOctave(5)],
    [17.0,1,Note.a.inOctave(5)],
    [31.0,2,Note.g.inOctave(5)],
    [42.0,3,Note.f.inOctave(5)],
    [55.0,4,Note.e.inOctave(5)],
    [67.5,5,Note.d.inOctave(5)],
    [81.0,6,Note.c.inOctave(5)],
    [94.5,7,Note.b.inOctave(4)],
    [108.0,8,Note.a.inOctave(4)],
    [121.5,9,Note.g.inOctave(4)],
    [135.0,10,Note.f.inOctave(4)],
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
        top: 172,
        left: 180,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if (
    ((noteNumber1==13)&(noteNumber2==14))
    ){
      return Positioned(
        top: 172,
        left: 170,
        child: SizedBox(
          width: 100,
          height: 50,
          child: Image.asset('assets/five_long.png'),
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
        top: 17,
        left: 180,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if ((noteNumber1==1)&(noteNumber2==2)) {
      return Positioned(
        top: 17,
        left: 207,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Image.asset('assets/music_five_line_one.png'),
        ),
      );
    } else if ((noteNumber1==0)&(noteNumber2==1)) {
      return Positioned(
        top: 17,
        left: 170,
        child: SizedBox(
          width: 100,
          height: 50,
          child: Image.asset('assets/five_long.png'),
        ),
      );
    }
    else {
      return const SizedBox();
    }
  }

  String? intervalNumber = null;

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
                ElevatedButton(onPressed: (){
                  setState(() {
                    answerInterval = 'd' + intervalNumber;
                  });
                }, child: Text
                  ('d' + intervalNumber)),
                ElevatedButton(onPressed: (){
                  setState(() {
                    answerInterval = 'P' + intervalNumber;
                  });
                }, child: Text('P'+intervalNumber)),
                ElevatedButton(onPressed: (){
                  setState(() {
                    answerInterval = 'A' + intervalNumber;
                  });
                }, child: Text('A'+intervalNumber)),
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
                    answerInterval = 'dd' + intervalNumber;
                  });
                }, child: Text('dd'+intervalNumber)),
                ElevatedButton(onPressed: (){
                  setState(() {
                    answerInterval = 'm' + intervalNumber;
                  });
                }, child: Text('m'+intervalNumber)),
                ElevatedButton(onPressed: (){
                  setState(() {
                    answerInterval = 'M' + intervalNumber;
                  });
                }, child: Text('M'+intervalNumber)),
                ElevatedButton(onPressed: (){
                  setState(() {
                    answerInterval = 'AA' + intervalNumber;
                  });
                }, child: Text('AA'+intervalNumber)),
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
    if (answerInterval == randomNote[0].interval(randomNote[1]).toString()){
      print(answerInterval);
      return Text('정답입니다.');
    } else {
      print(answerInterval);
      return Text('오답입니다.');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    note_height_list.shuffle();

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
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 250,
                    width: 400,
                    child: Image.asset('assets/music_five_line.png'),
                    // color: Colors.redAccent,
                  ),
                ],
              ),
              Positioned(
                top: randomItems[0],
                left: downNoteLeft,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Image.asset('assets/whole_note_lean.png'),
                ),
              ),
              Positioned(
                top: randomItems[1],
                left: 180,
                child: SizedBox(
                  width: 50,
                  height: 50,
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
          ElevatedButton(
              onPressed: (){

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
                // 7넘게 차이나면 다시 생성
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

                // List randomItems = note_height_list.take(2).toList();
              }, child: const Text('다음문제')
          ),
        ],
      ),
    );
  }
}
