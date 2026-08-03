// Characterization tests for the answer-calculation core.
//
// These tests freeze the CURRENT observed behavior of
// `lib/page/problemFunc/problemFuncDeco.dart` (getResultAllEasy,
// getResultAllHard, commentaryKeyReturn) as built on `music_notes: ^0.13.0`.
// They document what the code DOES today, not what it "should" do — every
// expected value here was captured by running a probe against the real
// music_notes 0.13.0 package and reading its actual output, not derived
// from music theory.
//
// WHY THIS FILE EXISTS
// Task 14 upgrades music_notes from 0.13.0 to 0.26.0, which has four
// breaking API changes that touch this exact code path:
//   - `PositionedNote`        -> `Pitch`
//   - `note.baseNote`         -> `note.noteName`
//   - `interval.inverted`     -> `interval.inversion`
//   - `interval.toString()`   -> was "M3"; becomes a debug repr, and the
//                                "M3" form moves to `interval.format()`
// The last change is the dangerous one: every answer comparison in this
// app is a STRING comparison against `Interval.toString()`. After the
// upgrade, that string silently becomes something like
// `Interval(size: Size(3), quality: ...)` instead of `"M3"` — the app
// would still compile, but every single answer check could break at
// runtime with no compiler error to catch it.
//
// This file is the safety net: run it before and after the Task 14
// migration and diff the results. If it fails during the music_notes
// upgrade, FIX THE IMPLEMENTATION so these values are reproduced again —
// do NOT edit the expectations in this file to match the new (broken)
// output. The whole point is that these numbers must not move.
//
// Task 18 will delete this file once `lib/domain/` replaces
// `problemFuncDeco.dart` and the six legacy problem screens are removed —
// at that point there's nothing left for this file to characterize.
//
// ignore_for_file: file_names

import 'package:flutter_test/flutter_test.dart';
import 'package:music_notes/music_notes.dart';
import 'package:intervalpractice/page/problemFunc/problemFunc.dart';
import 'package:intervalpractice/page/problemFunc/problemFuncDeco.dart';

void main() {
  group('getResultAllEasy - no accidentals', () {
    test('unison C4-C4', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.c.inOctave(4)], false);
      expect(result[0].toString(), '[C4, C4]');
      expect(result[1], 'P1');
      expect(result[2], '완전1');
      expect(result[3], '완전8');
    });

    test('2nd C4-D4', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.d.inOctave(4)], false);
      expect(result[0].toString(), '[C4, D4]');
      expect(result[1], 'M2');
      expect(result[2], '장2');
      expect(result[3], '단7');
    });

    test('3rd C4-E4', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.e.inOctave(4)], false);
      expect(result[0].toString(), '[C4, E4]');
      expect(result[1], 'M3');
      expect(result[2], '장3');
      expect(result[3], '단6');
    });

    test('4th C4-F4', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.f.inOctave(4)], false);
      expect(result[0].toString(), '[C4, F4]');
      expect(result[1], 'P4');
      expect(result[2], '완전4');
      expect(result[3], '완전5');
    });

    test('5th C4-G4', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.g.inOctave(4)], false);
      expect(result[0].toString(), '[C4, G4]');
      expect(result[1], 'P5');
      expect(result[2], '완전5');
      expect(result[3], '완전4');
    });

    test('6th C4-A4', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.a.inOctave(4)], false);
      expect(result[0].toString(), '[C4, A4]');
      expect(result[1], 'M6');
      expect(result[2], '장6');
      expect(result[3], '단3');
    });

    test('7th C4-B4', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.b.inOctave(4)], false);
      expect(result[0].toString(), '[C4, B4]');
      expect(result[1], 'M7');
      expect(result[2], '장7');
      expect(result[3], '단2');
    });

    test('octave C4-C5', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.c.inOctave(5)], false);
      expect(result[0].toString(), '[C4, C5]');
      expect(result[1], 'P8');
      expect(result[2], '완전8');
      expect(result[3], '완전1');
    });

    test('E-F semitone boundary is a minor 2nd, not major', () {
      final result = getResultAllEasy(
          [Note.e.inOctave(4), Note.f.inOctave(4)], false);
      expect(result[0].toString(), '[E4, F4]');
      expect(result[1], 'm2');
      expect(result[2], '단2');
      expect(result[3], '장7');
    });

    test('B-C semitone boundary is a minor 2nd, not major', () {
      final result = getResultAllEasy(
          [Note.b.inOctave(3), Note.c.inOctave(4)], false);
      expect(result[0].toString(), '[B3, C4]');
      expect(result[1], 'm2');
      expect(result[2], '단2');
      expect(result[3], '장7');
    });

    test('B3-F4 tritone is naturally diminished 5th (not perfect)', () {
      final result = getResultAllEasy(
          [Note.b.inOctave(3), Note.f.inOctave(4)], false);
      expect(result[0].toString(), '[B3, F4]');
      expect(result[1], 'd5');
      expect(result[2], '감5');
      expect(result[3], '증4');
    });

    test('widest allowed pair: D6-D5 (7 staff slots apart) is an octave',
        () {
      final result = getResultAllEasy(
          [Note.d.inOctave(6), Note.d.inOctave(5)], false);
      expect(result[0].toString(), '[D5, D6]');
      expect(result[1], 'P8');
      expect(result[2], '완전8');
      expect(result[3], '완전1');
    });

    test('argument order does not affect the result (internal sort)', () {
      final forward = getResultAllEasy(
          [Note.c.inOctave(4), Note.e.inOctave(4)], false);
      final backward = getResultAllEasy(
          [Note.e.inOctave(4), Note.c.inOctave(4)], false);
      expect(backward[0].toString(), forward[0].toString());
      expect(backward[1], forward[1]);
      expect(backward[2], forward[2]);
      expect(backward[3], forward[3]);
    });

    test('argument order does not affect the result (D6/D5 pair)', () {
      final forward = getResultAllEasy(
          [Note.d.inOctave(6), Note.d.inOctave(5)], false);
      final backward = getResultAllEasy(
          [Note.d.inOctave(5), Note.d.inOctave(6)], false);
      expect(backward[0].toString(), forward[0].toString());
      expect(backward[1], forward[1]);
      expect(backward[2], forward[2]);
    });

    test('inverseTF=true swaps answerReal/answerRealOriginal (C4-D4)', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.d.inOctave(4)], true);
      expect(result[0].toString(), '[C4, D4]');
      expect(result[1], 'm7');
      expect(result[2], '단7');
      expect(result[3], '장2');
    });

    test('inverseTF=true swaps answerReal/answerRealOriginal (B3-F4)', () {
      final result = getResultAllEasy(
          [Note.b.inOctave(3), Note.f.inOctave(4)], true);
      expect(result[0].toString(), '[B3, F4]');
      expect(result[1], 'A4');
      expect(result[2], '증4');
      expect(result[3], '감5');
    });

    test('inverseTF=true on unison', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.c.inOctave(4)], true);
      expect(result[1], 'P8');
      expect(result[2], '완전8');
      expect(result[3], '완전1');
    });
  });

  group('getResultAllHard - with accidentals', () {
    test('none/none behaves like getResultAllEasy', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.e.inOctave(4)], ['none', 'none'], false);
      expect(result[0].toString(), '[C4, E4]');
      expect(result[1], 'M3');
      expect(result[2], '장3');
    });

    test('sharp on lower note narrows M3 to m3', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.e.inOctave(4)], ['sharp', 'none'], false);
      expect(result[0].toString(), '[C♯4, E4]');
      expect(result[1], 'm3');
      expect(result[2], '단3');
    });

    test('sharp on upper note widens M3 to A3', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.e.inOctave(4)], ['none', 'sharp'], false);
      expect(result[0].toString(), '[C4, E♯4]');
      expect(result[1], 'A3');
      expect(result[2], '증3');
    });

    test('sharp on both notes leaves M3 unchanged', () {
      final result = getResultAllHard([Note.c.inOctave(4), Note.e.inOctave(4)],
          ['sharp', 'sharp'], false);
      expect(result[0].toString(), '[C♯4, E♯4]');
      expect(result[1], 'M3');
      expect(result[2], '장3');
    });

    test('flat on lower note widens M3 to A3', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.e.inOctave(4)], ['flat', 'none'], false);
      expect(result[0].toString(), '[C♭4, E4]');
      expect(result[1], 'A3');
      expect(result[2], '증3');
    });

    test('flat on upper note narrows M3 to m3', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.e.inOctave(4)], ['none', 'flat'], false);
      expect(result[0].toString(), '[C4, E♭4]');
      expect(result[1], 'm3');
      expect(result[2], '단3');
    });

    test('flat on both notes leaves M3 unchanged', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.e.inOctave(4)], ['flat', 'flat'], false);
      expect(result[0].toString(), '[C♭4, E♭4]');
      expect(result[1], 'M3');
      expect(result[2], '장3');
    });

    test('double sharp on lower note narrows M3 to d3', () {
      final result = getResultAllHard([Note.c.inOctave(4), Note.e.inOctave(4)],
          ['double sharp', 'none'], false);
      expect(result[0].toString(), '[C𝄪4, E4]');
      expect(result[1], 'd3');
      expect(result[2], '감3');
    });

    test('double sharp on upper note widens M3 to AA3', () {
      final result = getResultAllHard([Note.c.inOctave(4), Note.e.inOctave(4)],
          ['none', 'double sharp'], false);
      expect(result[0].toString(), '[C4, E𝄪4]');
      expect(result[1], 'AA3');
      expect(result[2], '겹증3');
    });

    test('double sharp on both notes leaves M3 unchanged', () {
      final result = getResultAllHard([Note.c.inOctave(4), Note.e.inOctave(4)],
          ['double sharp', 'double sharp'], false);
      expect(result[0].toString(), '[C𝄪4, E𝄪4]');
      expect(result[1], 'M3');
      expect(result[2], '장3');
    });

    test('double flat on lower note widens M3 to AA3', () {
      final result = getResultAllHard([Note.c.inOctave(4), Note.e.inOctave(4)],
          ['double flat', 'none'], false);
      expect(result[0].toString(), '[C𝄫4, E4]');
      expect(result[1], 'AA3');
      expect(result[2], '겹증3');
    });

    test('double flat on upper note narrows M3 to d3', () {
      final result = getResultAllHard([Note.c.inOctave(4), Note.e.inOctave(4)],
          ['none', 'double flat'], false);
      expect(result[0].toString(), '[C4, E𝄫4]');
      expect(result[1], 'd3');
      expect(result[2], '감3');
    });

    test('double flat on both notes leaves M3 unchanged', () {
      final result = getResultAllHard([Note.c.inOctave(4), Note.e.inOctave(4)],
          ['double flat', 'double flat'], false);
      expect(result[0].toString(), '[C𝄫4, E𝄫4]');
      expect(result[1], 'M3');
      expect(result[2], '장3');
    });

    test('accidental combined with the E-F semitone boundary', () {
      final result = getResultAllHard(
          [Note.e.inOctave(4), Note.f.inOctave(4)], ['sharp', 'none'], false);
      expect(result[0].toString(), '[E♯4, F4]');
      expect(result[1], 'd2');
      expect(result[2], '감2');
    });

    test('inverseTF=true with an accidental applied', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.e.inOctave(4)], ['sharp', 'none'], true);
      expect(result[0].toString(), '[C♯4, E4]');
      expect(result[1], 'M6');
      expect(result[2], '장6');
      expect(result[3], '단3');
    });
  });

  group('3-character abbreviation edge cases (dd/AA quality prefixes)', () {
    test('AA4: flat lower + sharp upper on a P4 pair', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.f.inOctave(4)], ['flat', 'sharp'], false);
      expect(result[0].toString(), '[C♭4, F♯4]');
      expect(result[1], 'AA4');
      expect(result[2], '겹증4');
    });

    test('dd4: sharp lower + flat upper on a P4 pair', () {
      final result = getResultAllHard(
          [Note.c.inOctave(4), Note.f.inOctave(4)], ['sharp', 'flat'], false);
      expect(result[0].toString(), '[C♯4, F♭4]');
      expect(result[1], 'dd4');
      expect(result[2], '겹감4');
    });

    // PRE-EXISTING BEHAVIOR, NOT A REGRESSION TO FIX: when both notes get a
    // double accidental in opposing directions, the resulting abbreviation
    // can be 4 characters long ("ddd4"). getResultAllHard's Korean-name
    // branch only handles answerReal.length == 2 or == 3
    // (problemFuncDeco.dart lines 406-412) and has no `else` — so for
    // length 4 the Korean string is left as its initial empty value. This
    // looks like a real gap in the original code, but per this task's
    // characterization mandate we freeze the observed behavior rather than
    // fixing it. Flagged in the report for the controller to triage.
    test('length-4 abbreviation ("ddd4") yields an EMPTY Korean string', () {
      final result = getResultAllHard([Note.f.inOctave(4), Note.b.inOctave(4)],
          ['double sharp', 'double flat'], false);
      expect(result[0].toString(), '[F𝄪4, B𝄫4]');
      expect(result[1], 'ddd4');
      expect(result[1].length, 4);
      expect(result[2], '');
    });
  });

  group('commentaryKeyReturn', () {
    test('plain M3 with no accidentals', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.e.inOctave(4)], false);
      final commentary = commentaryKeyReturn(result[0], result[2]);
      expect(
        commentary,
        '반음이 0개이므로 장3도 음정입니다 \n(장3도 음정의 기본 반음수는 0개)',
      );
    });

    test('unison with no accidentals', () {
      final result = getResultAllEasy(
          [Note.c.inOctave(4), Note.c.inOctave(4)], false);
      final commentary = commentaryKeyReturn(result[0], result[2]);
      expect(
        commentary,
        '반음이 0개이므로 완전1도 음정입니다 \n(완전1도 음정의 기본 반음수는 0개)',
      );
    });

    test('sharp on the lower note adds a prefix clause', () {
      final pair = [
        addAccidental(Note.c.inOctave(4), 'sharp'),
        Note.e.inOctave(4),
      ];
      final result = getResultAllEasy(pair, false);
      final commentary = commentaryKeyReturn(result[0], result[2]);
      expect(
        commentary,
        '아래에 있는 음에 붙은 샵으로 인해 음정간 간격이 줄어들고  '
        '반음이 0개이므로 단3도 음정입니다 \n(장3도 음정의 기본 반음수는 0개)',
      );
    });

    test('flat on the upper note adds a prefix clause', () {
      final pair = [
        Note.c.inOctave(4),
        addAccidental(Note.e.inOctave(4), 'flat'),
      ];
      final result = getResultAllEasy(pair, false);
      final commentary = commentaryKeyReturn(result[0], result[2]);
      expect(
        commentary,
        '위에 있는 음에 붙은 플렛으로 인해 음정간 간격이 줄어들고 '
        '반음이 0개이므로 단3도 음정입니다 \n(장3도 음정의 기본 반음수는 0개)',
      );
    });
  });

  group('determinism', () {
    test('getResultAllEasy returns identical output across repeated calls',
        () {
      final pair = [Note.c.inOctave(4), Note.g.inOctave(4)];
      final first = getResultAllEasy(pair, false);
      for (var i = 0; i < 10; i++) {
        final again = getResultAllEasy(pair, false);
        expect(again[0].toString(), first[0].toString());
        expect(again[1], first[1]);
        expect(again[2], first[2]);
        expect(again[3], first[3]);
      }
    });

    test('getResultAllHard returns identical output across repeated calls',
        () {
      final pair = [Note.c.inOctave(4), Note.e.inOctave(4)];
      final accidentals = ['sharp', 'flat'];
      final first = getResultAllHard(pair, accidentals, false);
      for (var i = 0; i < 10; i++) {
        final again = getResultAllHard(pair, accidentals, false);
        expect(again[0].toString(), first[0].toString());
        expect(again[1], first[1]);
        expect(again[2], first[2]);
        expect(again[3], first[3]);
      }
    });
  });
}
