import 'package:music_notes/music_notes.dart';
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

  return note_height_list_problem;

}


List<List<dynamic>> getProblemListNoteInit(
    List<List<dynamic>> note_height_list,
    ){

  // 새로운 문제 생성
  // note_height_list.shuffle();

  List<List<dynamic>> note_height_list_problem = [];
  note_height_list_problem =
      getRandomProblem(note_height_list);

  // 이전 문제와 동일하지 않게 방지 하는 장치
  // 동일하면 while문이 계속 실행
  while (
  // 이전 문제와 동일하지 않게 방지 하는 장치
  (note_height_list_problem[0][1]-note_height_list_problem[1][1]).abs()>7
  ){
    note_height_list_problem =
        getRandomProblem(note_height_list);
  }

  return note_height_list_problem;

}
