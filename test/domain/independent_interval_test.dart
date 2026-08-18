// 음정 계산의 **독립 검증**.
//
// 왜 필요한가:
// 지금까지의 검증은 "새 코드가 옛 코드와 같은 답을 낸다"까지였다
// (13,671건 대조, 차이 0건). 하지만 그건 **옛 코드가 애초에 음악적으로
// 맞았다는 전제** 위에 있다. 2년간 출시돼 있었지만 아무도 독립적으로
// 검증한 적이 없다.
//
// 이 파일은 `music_notes` 라이브러리를 **전혀 쓰지 않고**, 음악 이론
// 제1원리(음이름 간 도수 + 반음 개수)로 음정 이름을 계산한다.
// 라이브러리를 쓰는 쪽(AnswerChecker)과 안 쓰는 쪽(여기)이 독립적으로
// 같은 답을 내면 그것이 정확성의 실질적 근거가 된다.
//
// 검증 방식:
//   도수  = 음이름 위치 차이 + 1              (C→E 는 3도)
//   반음  = 실제 반음 개수                     (C→E 는 4반음)
//   품질  = 그 도수의 "기본 반음수"와의 차이   (장3도=4반음 → 4-4=0 → 장)
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/answer_checker.dart';
import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/domain/staff_layout.dart';

/// 음이름의 자연음 반음 위치 (C 기준).
const _naturalSemitones = <String, int>{
  '도': 0, // C
  '레': 2, // D
  '미': 4, // E
  '파': 5, // F
  '솔': 7, // G
  '라': 9, // A
  '시': 11, // B
};

/// 음이름의 순서 (도수 계산용).
const _letterOrder = <String>['도', '레', '미', '파', '솔', '라', '시'];

/// 임시표가 더하는 반음.
const _accidentalSemitones = <String, int>{
  'none': 0,
  'sharp': 1,
  'double sharp': 2,
  'flat': -1,
  'double flat': -2,
};

/// 완전음정(1·4·5·8도)의 기본 반음수.
const _perfectBase = <int, int>{1: 0, 4: 5, 5: 7, 8: 12};

/// 장음정(2·3·6·7도)의 기본 반음수.
const _majorBase = <int, int>{2: 2, 3: 4, 6: 9, 7: 11};

/// 제1원리로 음정 이름을 계산한다. music_notes 를 쓰지 않는다.
///
/// [slotIndex] 는 StaffLayout 의 자리 인덱스(0=위, 18=아래)이며,
/// 여기서는 음이름과 옥타브만 뽑아 쓴다.
String? independentIntervalName({
  required String lowerLetter,
  required int lowerOctave,
  required String lowerAccidental,
  required String upperLetter,
  required int upperOctave,
  required String upperAccidental,
}) {
  // --- 도수: 음이름 위치 + 옥타브로 계산 ---
  final lowerPos =
      _letterOrder.indexOf(lowerLetter) + lowerOctave * _letterOrder.length;
  final upperPos =
      _letterOrder.indexOf(upperLetter) + upperOctave * _letterOrder.length;
  final size = (upperPos - lowerPos).abs() + 1;

  // --- 반음 개수: 자연음 위치 + 임시표 ---
  final lowerSemi = _naturalSemitones[lowerLetter]! +
      lowerOctave * 12 +
      _accidentalSemitones[lowerAccidental]!;
  final upperSemi = _naturalSemitones[upperLetter]! +
      upperOctave * 12 +
      _accidentalSemitones[upperAccidental]!;
  final semitones = (upperSemi - lowerSemi).abs();

  // --- 품질: 기본 반음수와의 차이 ---
  final simpleSize = size > 8 ? size - 7 : size;

  if (_perfectBase.containsKey(simpleSize)) {
    final diff = semitones - _perfectBase[simpleSize]!;
    final quality = switch (diff) {
      -2 => '겹감',
      -1 => '감',
      0 => '완전',
      1 => '증',
      2 => '겹증',
      _ => null,
    };
    return quality == null ? null : '$quality$simpleSize';
  }

  if (_majorBase.containsKey(simpleSize)) {
    final diff = semitones - _majorBase[simpleSize]!;
    final quality = switch (diff) {
      -3 => '겹감',
      -2 => '감',
      -1 => '단',
      0 => '장',
      1 => '증',
      2 => '겹증',
      _ => null,
    };
    return quality == null ? null : '$quality$simpleSize';
  }

  return null;
}

/// 자리바꿈 음정을 **제1원리로** 계산한다. music_notes 를 쓰지 않는다.
///
/// 자리바꿈 규칙 (음악 이론):
///   도수  N  →  9 - N       (2도↔7도, 3도↔6도, 4도↔5도, 1도↔8도)
///   품질  장 ↔ 단, 증 ↔ 감, 겹증 ↔ 겹감, 완전 ↔ 완전
String? independentInversion(String korean) {
  final match = RegExp(r'^(완전|겹감|겹증|장|단|증|감)(\d)$').firstMatch(korean);
  if (match == null) return null;

  const flip = {
    '완전': '완전',
    '장': '단',
    '단': '장',
    '증': '감',
    '감': '증',
    '겹증': '겹감',
    '겹감': '겹증',
  };

  final quality = flip[match.group(1)!];
  final size = 9 - int.parse(match.group(2)!);
  if (quality == null || size < 1 || size > 8) return null;

  return '$quality$size';
}

void main() {
  group('제1원리 계산기 자체 검증 (교과서 값)', () {
    final cases = <(String, int, String, String, int, String, String)>[
      ('도', 4, 'none', '미', 4, 'none', '장3'),
      ('도', 4, 'none', '솔', 4, 'none', '완전5'),
      ('미', 4, 'none', '파', 4, 'none', '단2'),
      ('시', 3, 'none', '도', 4, 'none', '단2'),
      ('도', 4, 'none', '도', 4, 'none', '완전1'),
      ('도', 4, 'none', '도', 5, 'none', '완전8'),
      ('파', 4, 'none', '시', 4, 'none', '증4'),
      ('시', 3, 'none', '파', 4, 'none', '감5'),
      ('도', 4, 'none', '미', 4, 'flat', '단3'),
      ('도', 4, 'sharp', '미', 4, 'none', '단3'),
      ('도', 4, 'none', '솔', 4, 'sharp', '증5'),
      ('도', 4, 'none', '라', 4, 'none', '장6'),
      ('도', 4, 'none', '시', 4, 'none', '장7'),
      ('도', 4, 'none', '레', 4, 'none', '장2'),
      ('도', 4, 'none', '파', 4, 'none', '완전4'),
    ];

    for (final c in cases) {
      test('${c.$1}${c.$2}(${c.$3}) - ${c.$4}${c.$5}(${c.$6}) = ${c.$7}', () {
        expect(
          independentIntervalName(
            lowerLetter: c.$1,
            lowerOctave: c.$2,
            lowerAccidental: c.$3,
            upperLetter: c.$4,
            upperOctave: c.$5,
            upperAccidental: c.$6,
          ),
          c.$7,
        );
      });
    }
  });

  test('앱의 정답과 제1원리 계산이 모든 조합에서 일치한다', () {
    const accidentals = [
      'none',
      'sharp',
      'flat',
      'double sharp',
      'double flat',
    ];
    const mode = ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.nameTheInterval,
    );

    var compared = 0;
    var skipped = 0;
    final mismatches = <String>[];

    for (final a in StaffLayout.slots) {
      for (final b in StaffLayout.slots) {
        if (a.index == b.index) continue;
        // 생성기가 내는 범위(7자리 이내)만 본다.
        if ((a.index - b.index).abs() > 7) continue;

        for (final accA in accidentals) {
          for (final accB in accidentals) {
            final problem = IntervalProblem(
              lower: a,
              upper: b,
              accidentals: [accA, accB],
            );

            // 음높이(반음)로 낮은 음/높은 음을 정한다.
            final semA = _naturalSemitones[StaffLayout.koreanNameOf(a.pitch)]! +
                a.pitch.octave * 12 +
                _accidentalSemitones[accA]!;
            final semB = _naturalSemitones[StaffLayout.koreanNameOf(b.pitch)]! +
                b.pitch.octave * 12 +
                _accidentalSemitones[accB]!;
            final aIsLower = semA <= semB;

            final lowSlot = aIsLower ? a : b;
            final highSlot = aIsLower ? b : a;
            final lowAcc = aIsLower ? accA : accB;
            final highAcc = aIsLower ? accB : accA;

            // 음이름 순서가 음높이 순서와 어긋나면(임시표로 뒤집힌 경우)
            // 도수 자체가 정의되지 않는다 — 생성기도 내지 않는 조합이다.
            final lowLetterPos =
                _letterOrder.indexOf(StaffLayout.koreanNameOf(lowSlot.pitch)) +
                    lowSlot.pitch.octave * 7;
            final highLetterPos =
                _letterOrder.indexOf(StaffLayout.koreanNameOf(highSlot.pitch)) +
                    highSlot.pitch.octave * 7;
            if (highLetterPos < lowLetterPos) {
              skipped++;
              continue;
            }

            final expected = independentIntervalName(
              lowerLetter: StaffLayout.koreanNameOf(lowSlot.pitch),
              lowerOctave: lowSlot.pitch.octave,
              lowerAccidental: lowAcc,
              upperLetter: StaffLayout.koreanNameOf(highSlot.pitch),
              upperOctave: highSlot.pitch.octave,
              upperAccidental: highAcc,
            );

            if (expected == null) {
              skipped++;
              continue; // 답 버튼에 없는 음정 — 생성기가 걸러낸다
            }

            String actual;
            try {
              final grading = AnswerChecker.grade(
                problem: problem,
                mode: mode,
                submitted: '',
              );
              actual = grading.correctAnswerText.replaceAll('도', '');
            } on FormatException {
              // 앱도 답할 수 없다고 판단한 조합 — 생성기가 걸러낸다.
              skipped++;
              continue;
            }

            compared++;
            if (actual != expected) {
              mismatches.add(
                '$a + $b [$accA,$accB] → 앱="$actual" 제1원리="$expected"',
              );
            }
          }
        }
      }
    }

    // ignore: avoid_print
    print(
      'independent_interval: $compared건 비교, $skipped건 제외(답 불가), '
      '불일치 ${mismatches.length}건',
    );
    for (final m in mismatches.take(10)) {
      // ignore: avoid_print
      print('  $m');
    }

    expect(compared, greaterThan(1000), reason: '비교 표본이 너무 적다');
    expect(mismatches, isEmpty, reason: '앱의 음정 계산이 음악 이론과 어긋난다');
  });

  test('자리바꿈(유형 3) 정답도 제1원리 자리바꿈 규칙과 일치한다', () {
    const accidentals = [
      'none',
      'sharp',
      'flat',
      'double sharp',
      'double flat'
    ];
    const plain = ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.nameTheInterval,
    );
    const inverted = ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.invertedInterval,
    );

    var compared = 0;
    final mismatches = <String>[];

    for (final a in StaffLayout.slots) {
      for (final b in StaffLayout.slots) {
        if (a.index == b.index) continue;
        if ((a.index - b.index).abs() > 7) continue;

        for (final accA in accidentals) {
          for (final accB in accidentals) {
            final problem = IntervalProblem(
              lower: a,
              upper: b,
              accidentals: [accA, accB],
            );

            String? plainAnswer;
            String? invertedAnswer;
            try {
              plainAnswer = AnswerChecker.grade(
                problem: problem,
                mode: plain,
                submitted: '',
              ).correctAnswerText.replaceAll('도', '');
              invertedAnswer = AnswerChecker.grade(
                problem: problem,
                mode: inverted,
                submitted: '',
              ).correctAnswerText.replaceAll('도', '');
            } on FormatException {
              continue; // 답 불가 조합 — 생성기가 걸러낸다
            }

            final expected = independentInversion(plainAnswer);
            if (expected == null) continue;

            compared++;
            if (invertedAnswer != expected) {
              mismatches.add(
                '$a + $b [$accA,$accB] 원래=$plainAnswer '
                '앱자리바꿈=$invertedAnswer 제1원리=$expected',
              );
            }
          }
        }
      }
    }

    // ignore: avoid_print
    print('inversion: $compared건 비교, 불일치 ${mismatches.length}건');
    for (final m in mismatches.take(8)) {
      // ignore: avoid_print
      print('  $m');
    }

    expect(compared, greaterThan(1000));
    expect(mismatches, isEmpty, reason: '자리바꿈 정답이 음악 이론과 어긋난다');
  });
}
