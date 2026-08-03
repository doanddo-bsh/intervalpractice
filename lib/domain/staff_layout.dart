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
  final Pitch pitch;

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

  static final List<Pitch> _pitches = [
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

  static const _koreanNoteNames = <NoteName, String>{
    NoteName.c: '도',
    NoteName.d: '레',
    NoteName.e: '미',
    NoteName.f: '파',
    NoteName.g: '솔',
    NoteName.a: '라',
    NoteName.b: '시',
  };

  /// 한글 계이름 ("도", "레", ...). 임시표는 무시한다.
  static String koreanNameOf(Pitch pitch) =>
      _koreanNoteNames[pitch.note.noteName]!;

  /// 한글 계이름 전체 목록 (정답 버튼 배열용).
  static const koreanNoteNames = <String>['도', '레', '미', '파', '솔', '라', '시'];
}
