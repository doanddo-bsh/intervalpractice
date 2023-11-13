import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    [4.0,0],
    [17.0,1],
    [31.0,2],
    [42.0,3],
    [55.0,4],
    [67.5,5],
    [81.0,6],
    [94.5,7],
    [108.0,8],
    [121.5,9],
    [135.0,10],
    [145.0,11],
    [159.0,12],
    [172.0,13],
    [184.0,14],
  ];
  // List<double> note_height_list = [31,42,55,67.5,81,94.5,108,121.5];
  late List<double> randomItems ;
  late List<int> randomNoteNumber ;
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

  int? intervalNumber = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    note_height_list.shuffle();

    randomItems = [note_height_list[0][0],note_height_list[1][0]];
    randomItems.sort();
    randomNoteNumber = [note_height_list[0][1],note_height_list[1][1]];
    randomNoteNumber.sort();

    print(randomItems);
    print(randomNoteNumber);

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
          ElevatedButton(onPressed: (){

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

            print(randomItems);
            print(randomNoteNumber);

            // List randomItems = note_height_list.take(2).toList();
          }, child: const Text('버튼')),
          const SizedBox(height: 10.0,),
          SizedBox(
            height: 30.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: (){}, child: const Text('1')),
                ElevatedButton(onPressed: (){}, child: const Text('2')),
                ElevatedButton(onPressed: (){}, child: const Text('3')),
                ElevatedButton(onPressed: (){}, child: const Text('4')),
              ],
            ),
          ),
          const SizedBox(height: 10.0,),
          SizedBox(
            height: 30.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: (){}, child: const Text('5')),
                ElevatedButton(onPressed: (){}, child: const Text('6')),
                ElevatedButton(onPressed: (){}, child: const Text('7')),
                ElevatedButton(onPressed: (){}, child: const Text('8')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
