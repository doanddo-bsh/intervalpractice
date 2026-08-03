import 'package:music_notes/music_notes.dart';

/// 오선지 위의 한 음자리. 화면 Y좌표와 음높이를 함께 갖는다.
final class StaffSlot {
  const StaffSlot({
    required this.top,
    required this.index,
    required this.pitch,
  });

  /// 오선지 컨테이너 기준 Y 오프셋 (설계 기준 375x844 기준값).
  final double top;

  /// 위에서부터 0번, 아래로 갈수록 증가. 오답노트 저장에 쓰인다.
  final int index;

  /// 이 자리에 해당하는 음높이.
  //
  // 0.13 호환 임시 조정 (Task 12 Step 3-b): music_notes 0.26의 `Pitch`
  // 대신 0.13의 `PositionedNote`를 쓴다. Task 14에서 `Pitch`로 되돌린다.
  final PositionedNote pitch;

  @override
  String toString() => 'StaffSlot($index, $pitch, top: $top)';
}

/// 높은음자리표 오선지의 음자리 배치.
///
/// 기존 `note_height_list` / `note_height_list_fix` 두 개의 동일한
/// `List<List<dynamic>>`를 하나의 타입 안전한 테이블로 대체한다.
abstract final class StaffLayout {
  static const _topStart = 11.0;
  static const _gap = 13.25;

  /// 위(D6)에서 아래(G3)로 내려가는 순서.
  static final List<StaffSlot> slots = List.unmodifiable([
    for (var i = 0; i < _pitches.length; i++)
      StaffSlot(top: _topStart + _gap * i, index: i, pitch: _pitches[i]),
  ]);

  // 0.13 호환 임시 조정 (Task 12 Step 3-b): `List<Pitch>` 대신
  // `List<PositionedNote>`. Task 14에서 되돌린다.
  static final List<PositionedNote> _pitches = [
    Note.d.inOctave(6),
    Note.c.inOctave(6),
    Note.b.inOctave(5),
    Note.a.inOctave(5),
    Note.g.inOctave(5),
    Note.f.inOctave(5),
    Note.e.inOctave(5),
    Note.d.inOctave(5),
    Note.c.inOctave(5),
    Note.b.inOctave(4),
    Note.a.inOctave(4),
    Note.g.inOctave(4),
    Note.f.inOctave(4),
    Note.e.inOctave(4),
    Note.d.inOctave(4),
    Note.c.inOctave(4),
    Note.b.inOctave(3),
    Note.a.inOctave(3),
    Note.g.inOctave(3),
  ];

  static StaffSlot byIndex(int index) => slots[index];

  // 0.13 호환 임시 조정 (Task 12 Step 3-b): `NoteName` 대신 `BaseNote`.
  // Task 14에서 되돌린다.
  static const _koreanNoteNames = <BaseNote, String>{
    BaseNote.c: '도',
    BaseNote.d: '레',
    BaseNote.e: '미',
    BaseNote.f: '파',
    BaseNote.g: '솔',
    BaseNote.a: '라',
    BaseNote.b: '시',
  };

  /// 한글 계이름 ("도", "레", ...). 임시표는 무시한다.
  //
  // 0.13 호환 임시 조정 (Task 12 Step 3-b): `pitch.note.noteName` 대신
  // `pitch.note.baseNote`. Task 14에서 되돌린다.
  static String koreanNameOf(PositionedNote pitch) =>
      _koreanNoteNames[pitch.note.baseNote]!;

  /// 한글 계이름 전체 목록 (정답 버튼 배열용).
  static const koreanNoteNames = <String>['도', '레', '미', '파', '솔', '라', '시'];
}
