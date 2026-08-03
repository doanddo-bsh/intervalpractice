import 'package:music_notes/music_notes.dart';

/// 음정의 한글 표기와 영문 약칭(`M3`, `P5`, `dd7`) 사이를 변환한다.
///
/// 영문 약칭은 music_notes가 내보내는 형식과 동일하다:
/// 품질(d/dd/m/M/P/A/AA) + 도수(1~8).
abstract final class KoreanInterval {
  /// 한글 품질 이름 -> 영문 약칭.
  static const _koreanToAbbreviation = <String, String>{
    '감': 'd',
    '겹감': 'dd',
    '단': 'm',
    '장': 'M',
    '완전': 'P',
    '증': 'A',
    '겹증': 'AA',
  };

  /// 영문 약칭 -> 한글 품질 이름.
  static const _abbreviationToKorean = <String, String>{
    'd': '감',
    'dd': '겹감',
    'm': '단',
    'M': '장',
    'P': '완전',
    'A': '증',
    'AA': '겹증',
  };

  /// `Interval`을 `"장3"` 같은 한글 표기로 바꾼다. ("도"는 붙이지 않는다.)
  static String fromInterval(Interval interval) =>
      fromAbbreviation(intervalAbbreviation(interval));

  /// 이 음정을 정답 버튼으로 입력할 수 있는가.
  ///
  /// UI가 제공하는 품질은 위 7종과 1~8도뿐이다. 겹임시표가 반음 경계에
  /// 얹히면 `ddd5`, `AAA4` 같은 세 겹 음정이 나오는데 버튼에 없다.
  /// **원본 앱은 이런 문제를 실제로 출제했고**, 그 결과 정답 계산에서
  /// `intervalNameEngKor[...]`가 null을 반환해 크래시하거나(8개 조합)
  /// 정답이 빈칸으로 표시됐다(16개 조합).
  static bool isAnswerable(Interval interval) {
    final abbreviation = intervalAbbreviation(interval);
    final digitIndex = abbreviation.indexOf(RegExp(r'\d'));
    if (digitIndex <= 0) return false;

    final quality = abbreviation.substring(0, digitIndex);
    final size = abbreviation.substring(digitIndex);

    return _abbreviationToKorean.containsKey(quality) &&
        const {'1', '2', '3', '4', '5', '6', '7', '8'}.contains(size);
  }

  /// `"M3"` -> `"장3"`.
  ///
  /// 품질 부분은 1~2글자이므로 뒤에서부터 도수를 떼어낸다.
  static String fromAbbreviation(String abbreviation) {
    final digitIndex = abbreviation.indexOf(RegExp(r'\d'));
    if (digitIndex <= 0) {
      throw FormatException('Invalid interval abbreviation', abbreviation);
    }

    final quality = abbreviation.substring(0, digitIndex);
    final size = abbreviation.substring(digitIndex);

    final korean = _abbreviationToKorean[quality];
    if (korean == null) {
      throw FormatException('Unknown interval quality', abbreviation);
    }

    return '$korean$size';
  }

  /// `("장", "3")` -> `"M3"`.
  static String toAbbreviation(String koreanQuality, String size) {
    final abbreviation = _koreanToAbbreviation[koreanQuality];
    if (abbreviation == null) {
      throw FormatException('Unknown Korean quality', koreanQuality);
    }

    return '$abbreviation$size';
  }

  /// music_notes 버전 차이를 흡수하는 단일 지점.
  ///
  /// 0.13에서는 `toString()`이, 0.26 이후로는 `format()`이 `"M3"` 형태를 낸다.
  /// 마이그레이션 시 이 메서드 한 곳만 고치면 된다.
  static String intervalAbbreviation(Interval interval) => interval.toString();
}
