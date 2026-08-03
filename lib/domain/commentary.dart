import 'package:music_notes/music_notes.dart';

import 'commentary_data.dart';
import 'korean_interval.dart';

/// 정답/오답 해설 문구를 만든다.
///
/// 기존 `commentaryKeyReturn`(유형 1/3)과 `commentaryType2` 조회(유형 2)를
/// 순수 Dart로 옮긴 것이다.
abstract final class Commentary {
  /// 유형 1/3용 해설: 반음 개수와 임시표 영향을 설명한다.
  static String forIntervalQuestion(List<Pitch> sortedPitches, String korean) {
    final abbreviation = KoreanInterval.intervalAbbreviation(
      sortedPitches[0].interval(sortedPitches[1]),
    );

    final key =
        abbreviation[abbreviation.length - 1] +
        _noteLetter(sortedPitches[0]) +
        _noteLetter(sortedPitches[1]);

    final basic = commentaryBasic[key];
    if (basic == null) return '';

    final base = '${basic[0]} $korean도 ${basic[1]}';

    final lower = commentaryDownAccidental[_accidentalCode(sortedPitches[0])];
    final upper = commentaryUpAccidental[_accidentalCode(sortedPitches[1])];

    return [
      if (lower != null) lower,
      if (upper != null) upper,
      base,
    ].join(' ');
  }

  /// 유형 2용 해설: 음정 이름 자체를 설명한다.
  static String forNoteQuestion(List<Pitch> sortedPitches) {
    final interval = sortedPitches[0].interval(sortedPitches[1]);
    final korean = KoreanInterval.fromInterval(interval);

    return commentaryType2['$korean도'] ?? '';
  }

  static String _noteLetter(Pitch pitch) =>
      pitch.note.noteName.name.toLowerCase();

  static String _accidentalCode(Pitch pitch) {
    final accidental = pitch.note.accidental;

    return switch (accidental.semitones) {
      0 => 'n',
      1 => 's',
      2 => 'ds',
      -1 => 'f',
      -2 => 'df',
      _ => 'n',
    };
  }
}
