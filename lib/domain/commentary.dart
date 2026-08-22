import 'package:music_notes/music_notes.dart';

import 'commentary_data.dart';
import 'korean_interval.dart';

/// 정답/오답 해설 문구를 만든다.
///
/// 기존 `commentaryKeyReturn`(유형 1/3)과 `commentaryType2` 조회(유형 2)를
/// 순수 Dart로 옮긴 것이다.
abstract final class Commentary {
  /// 유형 1/3용 해설: 반음 개수와 임시표 영향을 설명한다.
  ///
  /// [inverted] 는 자리바꿈 문제(유형 3)인지 여부다.
  ///
  /// **원본 앱의 버그를 여기서 고친다.** 원본은 해설 키를 항상 자리바꿈하지
  /// 않은 음정에서 뽑으면서 문구에는 자리바꿈된 이름을 끼워 넣었다. 그래서
  /// 유형 3에서 "장7도 음정입니다 (장2도 음정의 기본 반음수는 0개)" 처럼
  /// 앞뒤가 어긋나는 해설이 나왔다. 실제 사용자 리뷰로 제보된 문제다.
  ///
  /// 자리바꿈 음정은 위 음에서 아래 음(옥타브 위)까지를 재는 것이므로
  /// 음이름 순서가 뒤집히고 도수도 자리바꿈 값이 된다. 임시표 설명의
  /// 위/아래 방향도 함께 뒤집힌다.
  static String forIntervalQuestion(
    List<Pitch> sortedPitches,
    String korean, {
    bool inverted = false,
  }) {
    final low = inverted ? sortedPitches[1] : sortedPitches[0];
    final high = inverted ? sortedPitches[0] : sortedPitches[1];

    var interval = sortedPitches[0].interval(sortedPitches[1]);
    if (inverted) interval = interval.inversion;
    final abbreviation = KoreanInterval.intervalAbbreviation(interval);

    final key = abbreviation[abbreviation.length - 1] +
        _noteLetter(low) +
        _noteLetter(high);

    final basic = commentaryBasic[key];
    if (basic == null) return '';

    final base = '${basic[0]} $korean도 ${basic[1]}';

    // 자리바꿈 문제는 위/아래가 화면과 반대라, 그 음을 화면에서 짚을 수 있게
    // 부르는 전용 문구를 쓴다 (commentary_data.dart 주석 참고).
    final lower = inverted
        ? commentaryInvertedDownAccidental[_accidentalCode(low)]
        : commentaryDownAccidental[_accidentalCode(low)];
    final upper = inverted
        ? commentaryInvertedUpAccidental[_accidentalCode(high)]
        : commentaryUpAccidental[_accidentalCode(high)];

    return [
      // Easy 유형 3은 임시표가 없어 아래 두 줄이 비므로, 이 도입 문장이
      // 없으면 자리바꿈 문제인데 해설에 자리바꿈 얘기가 하나도 안 나온다.
      if (inverted) commentaryInversionLead,
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
