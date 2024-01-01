import 'package:music_notes/music_notes.dart';
import 'problemVarList.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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


List<List<dynamic>> getRandomProblem(List<List<dynamic>> note_height_list){

  int number1 = Random().nextInt(note_height_list.length);
  int number2 = Random().nextInt(note_height_list.length);

  return [note_height_list[number1],note_height_list[number2]];

}

List<List<dynamic>> getProblemListNote(
    List<List<dynamic>> note_height_list,
    List<double> randomItems,
    ){

  // 새로운 문제 생성
  // note_height_list.shuffle();

  List<List<dynamic>> note_height_list_problem = [];
  note_height_list_problem =
    getRandomProblem(note_height_list);

  // 이전 문제와 동일하지 않게 방지 하는 장치
  // 동일하면 while문이 계속 실행
  if (randomItems.isEmpty){
    while (
    // 이전 문제와 동일하지 않게 방지 하는 장치
    (note_height_list_problem[0][1]-note_height_list_problem[1][1]).abs()>7
    ){
      note_height_list_problem =
          getRandomProblem(note_height_list);
    }
  } else {
    while (
    // 이전 문제와 동일하지 않게 방지 하는 장치
    setEquals(
        [note_height_list_problem[0][0],note_height_list_problem[1][0]].toSet(),
        [randomItems[0],randomItems[1]].toSet())
    // 7음정 넘게 차이날 경우 다시 생성
    |((note_height_list_problem[0][1]-note_height_list_problem[1][1]).abs()>7)
    ){
      note_height_list_problem =
          getRandomProblem(note_height_list);
    }
  }
  return note_height_list_problem;
}

// one both none
String accidentalsWhere(){
  // 양쪽음에 한쪽만 50, 양쪽다 30, 아무것도 20
  Random r1 = new Random();
  if (r1.nextDouble() <=0.5){
    return 'one';
  } else if (r1.nextDouble() <=0.8){
    return 'both';
  } else {
    return 'none';
  }
}

// return sharp, flat, double flat, double sharp
String accidentals(){
  Random r2 = new Random();
  if (r2.nextDouble() <=0.35){
    return 'sharp';
  } else if (r2.nextDouble() <=0.70){
    return 'flat';
  } else if (r2.nextDouble() <=0.85){
    return 'double flat';
  } else {
    return 'double sharp';
  }
}

// return sharp, flat
String accidentalsNoDouble(){
  Random r2 = new Random();
  if (r2.nextDouble() <=0.5){
    return 'sharp';
  } else{
    return 'flat';
  }
}

List<String> accidentalsFinal(List<PositionedNote> randomNote){

  String accidentalWhere = accidentalsWhere();
  Random r3 = new Random();

  var randomNote2 = [randomNote[1],randomNote[0]];

  if (accidentalWhere == 'none'){
    return ['none','none'];
  } else if (accidentalWhere == 'one'){
    if (r3.nextDouble() <=0.5){
      return [accidentals(),'none'];
    } else {
      return ['none',accidentals()];
    }
  } else {
    // no double
    if (noDiffDoubleList.contains(randomNote)|
        noDiffDoubleList.contains(randomNote2)){
      print('nonolist 포함');
      String fixAccidental = accidentalsNoDouble();
      return [fixAccidental,fixAccidental];
    } else {
      print('nonolist 미포함');
      return [accidentalsNoDouble(),accidentalsNoDouble()];
    }
  }
}


PositionedNote addAccidental(PositionedNote inputNote, String accidental){
  if (accidental == 'none'){
    return inputNote;
  } else if (accidental == 'sharp'){
    return inputNote.note.sharp.inOctave(inputNote.octave);
  } else if (accidental == 'double sharp'){
    return inputNote.note.sharp.sharp.inOctave(inputNote.octave);
  } else if (accidental == 'flat'){
    return inputNote.note.flat.inOctave(inputNote.octave);
  } else {
    return inputNote.note.flat.flat.inOctave(inputNote.octave);
  }
}

// add line 시리즈
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

Widget addLineBasic(){
  return Container(
    color: Colors.black,
    height: 2.0.h,
    width: 50.w,
  );
}

// 덧줄용1
Widget addLine1(PositionedNote randomNote){

  print('addLine1 2.0.h ${2.0.h}');
  print('addLine1 50.w ${50.w}');
  print('addLine1 randomNote ${randomNote}');

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
        child: addLineBasic(),
      );
  } else if (lowLine.contains(randomNote)) {
    return
      Positioned(
        top: 24.5.h,
        child: addLineBasic(),
      );
  } else if (highLine.contains(randomNote)){
    return
      Positioned(
        child: addLineBasic(),
      );
  }
  else {
    return SizedBox();
  }
}

// 덧줄용3
Widget addLine3(PositionedNote randomNote, double left){

  // 위의 도 레 거나 high line
  List<PositionedNote> highLine = [
    Note.d.inOctave(6),
    Note.c.inOctave(6),
  ];
  // 아래의 라 솔 인 경우 low line
  List<PositionedNote> lowLine = [
    Note.a.inOctave(3),
    Note.g.inOctave(3),
  ];

  if (highLine.contains(randomNote)){
    return
      Positioned(
        top: 50.75.h, // [50.75,3,Note.a.inOctave(5)],
        left: left,
        child: SizedBox(
          height: 26.5.h,
          child: Stack(
            children: [
              // ColorFiltered(
              //   colorFilter:
              //   ColorFilter.mode(Colors.white, BlendMode.color),
              //   child: Image.asset('assets/whole_note_lean.png'),
              // ),
              // Container(
              //   color: Colors.red,
              //   child: Image.asset('assets/whole_note_lean.png'),
              // ),
              Image.asset('assets/whole_note_lean_all_white.png'),
              Positioned(
                top: 12.75.h,
                child: addLineBasic(),
              )
            ],
          ),
        ),
      );
      Positioned(
        top: 12.75.h,
        child: addLineBasic(),
      );
  } else if (lowLine.contains(randomNote)) {
    return
      Positioned(
        top: 209.75.h, // [50.75,3,Note.a.inOctave(5)],
        left: left,
        child: SizedBox(
          height: 26.5.h,
          child: Stack(
            children: [
              Image.asset('assets/whole_note_lean_all_white.png'),
              Positioned(
                top: 12.75.h,
                child: addLineBasic(),
              )
            ],
          ),
        ),
      );
  }
  else {
    return SizedBox();
  }
}


// 덧줄용2
Widget addLine2(PositionedNote randomNote, double left){

  print('addLine2 2.0.h ${2.0.h}');
  print('addLine2 50.w ${50.w}');
  print('addLine2 randomNote ${randomNote}');
  print('addLine2 left ${left}');

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
        child: addLineBasic(),
      );
  } else if (lowLowLine.contains(randomNote)) {
    return
      Positioned(
        top: 222.5.h,
        left: left,
        child: addLineBasic(),
      );
  }
  else {
    return SizedBox();
  }
}

// 변화표 추가
Widget addAccidentals(String whatAccidental, double top, double left){

  if (whatAccidental == 'none'){
    return SizedBox();
  } else if (whatAccidental == 'sharp'){
    return Positioned(
      top: top,
      left: left,
      child: SizedBox(
        height: 30,
        width: 15,
        child: Image(
          image: AssetImage('assets/sharp1.png',
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  } else if (whatAccidental == 'double sharp'){
    return Positioned(
      top: top,
      left: left,
      child: SizedBox(
        height: 30,
        width: 15,
        child: Image(
          image: AssetImage('assets/doubleSharp.png',
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  } else if (whatAccidental == 'flat'){
    return Positioned(
      top: top,
      left: left,
      child: SizedBox(
        height: 30,
        width: 15,
        child: Image(
          image: AssetImage('assets/flat1.png',
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  } else {
    return Positioned(
      top: top,
      left: left,
      child: SizedBox(
        height: 30,
        width: 15,
        child: Image(
          image: AssetImage('assets/doubleFlat.png',
          ),
          fit: BoxFit.fill,
        ),
      ),
    );
  }


}

// List<List<dynamic>> getProblemListNoteInit(
//     List<List<dynamic>> note_height_list,
//     ){
//
//   // 새로운 문제 생성
//   // note_height_list.shuffle();
//
//   List<List<dynamic>> note_height_list_problem = [];
//   note_height_list_problem =
//       getRandomProblem(note_height_list);
//
//   // 이전 문제와 동일하지 않게 방지 하는 장치
//   // 동일하면 while문이 계속 실행
//   while (
//   // 이전 문제와 동일하지 않게 방지 하는 장치
//   (note_height_list_problem[0][1]-note_height_list_problem[1][1]).abs()>7
//   ){
//     note_height_list_problem =
//         getRandomProblem(note_height_list);
//   }
//
//   return note_height_list_problem;
//
// }
