import 'package:music_notes/music_notes.dart';
import 'easyProblemType1List.dart';
import 'dart:math';

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
      String fixAccidental = accidentalsNoDouble();
      return [fixAccidental,fixAccidental];
    } else {
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
