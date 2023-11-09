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
    // [17.0,1],
    // [31.0,2],
    // [42.0,3],
    // [55.0,4],
    // [67.5,5],
    // [81.0,6],
    // [94.5,7],
    // [108.0,8],
    // [121.5,9],
    // [135.0,10],
    // [145.0,11],
    [159.0,12],
    [172.0,13],
    [184.0,14],
  ];
  // List<double> note_height_list = [31,42,55,67.5,81,94.5,108,121.5];
  List randomItems = [30,50];
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
    if ((noteNumber1==13)|(noteNumber1==14)
    |(noteNumber2==13)|(noteNumber2==14)
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
    } else {
      return SizedBox();
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    note_height_list.shuffle();
    print([note_height_list[0][0],note_height_list[1][0]]);
    randomItems = [note_height_list[0][0],note_height_list[1][0]];
    randomItems.sort();
    if ((note_height_list[0][1]-note_height_list[1][1]).abs()==1){
      downNoteLeft = 207;
    } else {
      downNoteLeft = 180;
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Chart Page"),
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 250,
                // width: 100,
                child: Image.asset('assets/music_five_line.png'),
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
              addLineDown(note_height_list[0][1],note_height_list[1][1]),
            ]
          ),
          ElevatedButton(onPressed: (){

            // 새로운 문제 생성
            note_height_list.shuffle();
            // 이전 문제와 동일하지 않게 방지 하는 장치
            // 동일하면 while문이 계속 실행
            print((note_height_list[0][1]-note_height_list[1][1]).abs());
            while (
            setEquals(
                [note_height_list[0][0],note_height_list[1][0]].toSet(),
                [randomItems[0],randomItems[1]].toSet())
            |((note_height_list[0][1]-note_height_list[1][1]).abs()>7)
            ){
              note_height_list.shuffle();
            }

            setState(() {
              // 문제 적용
              randomItems = [note_height_list[0][0],note_height_list[1][0]];
              randomItems.sort();
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
            // List randomItems = note_height_list.take(2).toList();
          }, child: Text('버튼'))
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = Colors.black // 색은 보라색
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..strokeWidth = 4.0; // 선의 굵기는 4.0

    Offset p1 = Offset(0.0, 0.0); // 선을 그리기 위한 좌표값을 만듬.
    Offset p2 = Offset(size.width, size.height);
    canvas.drawLine(p1, p2, paint); // 선을 그림.
    canvas.drawLine(Offset(30.0, 30.0), Offset(180.0, 30.0), paint); // 선을 그림.
    canvas.drawLine(Offset(30.0, 50.0), Offset(180.0, 50.0), paint); // 선을 그림.
    canvas.drawLine(Offset(30.0, 70.0), Offset(180.0, 70.0), paint); // 선을 그림.
    canvas.drawLine(Offset(30.0, 90.0), Offset(180.0, 90.0), paint); // 선을 그림.
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final angle = math.pi / 4;
    Color paintColor = Colors.black;
    Paint circlePaint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    print(size);
    canvas.save();
    canvas.translate(size.width * 1, size.height * 0.5);
    canvas.rotate(angle);
    canvas.drawOval(Rect.fromCenter(
        center: Offset.zero,
        width: 15, height: 30), circlePaint
    );
    canvas.restore();
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

