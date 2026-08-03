import 'package:music_notes/music_notes.dart';

import 'staff_layout.dart';

/// 출제된 문제 하나. 화면에 그릴 정보와 채점에 필요한 정보를 모두 갖는다.
final class IntervalProblem {
  const IntervalProblem({
    required this.lower,
    required this.upper,
    required this.accidentals,
  });

  /// 화면상 위쪽에 그려지는 자리 (index가 작음 = 높은 음).
  final StaffSlot lower;

  /// 화면상 아래쪽에 그려지는 자리.
  final StaffSlot upper;

  /// `[lower, upper]` 순서의 임시표.
  /// 값은 `'none' | 'sharp' | 'flat' | 'double sharp' | 'double flat'`.
  final List<String> accidentals;

  /// 오답노트 저장용 식별자 — 자리 인덱스 쌍.
  List<int> get slotIndices => [lower.index, upper.index];

  /// 임시표를 적용한 실제 음높이 두 개를, 낮은 음부터 정렬해 반환한다.
  ///
  /// 문제가 자기 음높이를 아는 것이 자연스럽고, 생성기(Task 13)와
  /// 채점기(Task 17)가 같은 계산을 중복하지 않게 한다.
  ///
  /// **music_notes 0.13 호환 주의:** 반환 타입은 0.13에서 `PositionedNote`,
  /// 0.26에서 `Pitch`다. Task 14에서 일괄 치환된다.
  List<PositionedNote> get sortedPitches => [
    _withAccidental(lower.pitch, accidentals[0]),
    _withAccidental(upper.pitch, accidentals[1]),
  ]..sort();

  static PositionedNote _withAccidental(
    PositionedNote pitch,
    String accidental,
  ) => switch (accidental) {
    'sharp' => pitch.note.sharp.inOctave(pitch.octave),
    'double sharp' => pitch.note.sharp.sharp.inOctave(pitch.octave),
    'flat' => pitch.note.flat.inOctave(pitch.octave),
    'double flat' => pitch.note.flat.flat.inOctave(pitch.octave),
    _ => pitch,
  };

  @override
  String toString() =>
      'IntervalProblem(${lower.pitch} ${accidentals[0]}, '
      '${upper.pitch} ${accidentals[1]})';
}
