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

List<List<dynamic>> shuffle(
    List<List<dynamic>> note_height_list,
    List<double> randomItems,
    ){

  // 새로운 문제 생성
  note_height_list.shuffle();

  // 이전 문제와 동일하지 않게 방지 하는 장치
  // 동일하면 while문이 계속 실행
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

  return note_height_list;

}


