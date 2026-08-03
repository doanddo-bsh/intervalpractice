// Differential parity test: the new domain layer (AnswerChecker + Commentary)
// vs. the legacy answer-calculation core (getResultAllEasy, getResultAllHard,
// commentaryKeyReturn / commentaryType2) that
// test/characterization/answer_calculation_test.dart pins.
//
// Sweeps every staff-slot pair within the generator's 7-slot distance limit,
// crossed with every accidental combination the generator can produce
// (easy: none/none; hard: the 5x5 grid of {none, sharp, flat, double sharp,
// double flat} on lower x upper), and checks that the new pipeline's answer
// text and commentary agree with the legacy pipeline's — for every question
// type (name-the-interval, name-the-note, inverted-interval).
//
// Combinations the generator would never emit (unanswerable qualities like
// `ddd4`) are skipped via `KoreanInterval.isAnswerable`, matching Task 13's
// documented fix — parity there is neither possible nor wanted (see
// test/characterization/answer_calculation_test.dart's "length-4
// abbreviation" case).
//
// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/answer_checker.dart';
import 'package:intervalpractice/domain/commentary.dart';
import 'package:intervalpractice/domain/korean_interval.dart';
import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/domain/staff_layout.dart';

import 'package:intervalpractice/page/problemFunc/problemFuncDeco.dart';

const _accidentalValues = ['none', 'sharp', 'flat', 'double sharp', 'double flat'];
const _maxSlotDistance = 7;

class _Divergence {
  _Divergence(this.description, this.expected, this.actual);

  final String description;
  final String expected;
  final String actual;

  @override
  String toString() => '$description\n  legacy: $expected\n  new   : $actual';
}

void main() {
  final divergences = <_Divergence>[];
  var comparisons = 0;
  var skipped = 0;

  for (final a in StaffLayout.slots) {
    for (final b in StaffLayout.slots) {
      if ((a.index - b.index).abs() > _maxSlotDistance) continue;

      for (final lowerAcc in _accidentalValues) {
        for (final upperAcc in _accidentalValues) {
          // Only sweep the full 5x5 grid for genuinely "hard" cases; treat
          // none/none as the single "easy" case (tested once, not 25x).
          final accidentals = [lowerAcc, upperAcc];

          final problem = IntervalProblem(
            lower: a,
            upper: b,
            accidentals: accidentals,
          );

          final pitches = problem.sortedPitches;
          final baseInterval = pitches[0].interval(pitches[1]);

          if (!KoreanInterval.isAnswerable(baseInterval) ||
              !KoreanInterval.isAnswerable(baseInterval.inversion)) {
            skipped++;
            continue;
          }

          final rawPair = [a.pitch, b.pitch];

          // --- Type 1 / type 3 share the same legacy call, differing only
          // in inverseTF.
          for (final inverted in [false, true]) {
            comparisons++;

            final legacy = getResultAllHard(rawPair, accidentals, inverted);
            final legacyKorean = legacy[2] as String;
            final legacyCommentary = commentaryKeyReturn(
              legacy[0] as List<dynamic>,
              legacyKorean,
            );

            final mode = ProblemMode(
              difficulty: lowerAcc == 'none' && upperAcc == 'none'
                  ? Difficulty.easy
                  : Difficulty.hard,
              questionType: inverted
                  ? QuestionType.invertedInterval
                  : QuestionType.nameTheInterval,
            );

            final grading = AnswerChecker.grade(
              problem: problem,
              mode: mode,
              submitted: legacyKorean,
            );

            final desc =
                'pair=(${a.pitch.format()}${lowerAcc == 'none' ? '' : ' $lowerAcc'}, '
                '${b.pitch.format()}${upperAcc == 'none' ? '' : ' $upperAcc'}) '
                'inverted=$inverted';

            if (grading.correctAnswerText != '$legacyKorean도') {
              divergences.add(
                _Divergence(
                  '$desc answer text',
                  '$legacyKorean도',
                  grading.correctAnswerText,
                ),
              );
            }
            if (grading.commentary != legacyCommentary) {
              divergences.add(
                _Divergence(
                  '$desc commentary',
                  legacyCommentary,
                  grading.commentary,
                ),
              );
            }
          }

          // --- Type 2 (name-the-note): only the commentary is comparable
          // across pipelines (the answer itself is a solfège letter, not an
          // interval computation).
          comparisons++;
          final legacyBase = getResultAllHard(rawPair, accidentals, false);
          final legacyBaseKorean = legacyBase[2] as String;
          final legacyType2Commentary =
              commentaryType2['$legacyBaseKorean도'] ?? '';
          final newType2Commentary = Commentary.forNoteQuestion(pitches);

          if (newType2Commentary != legacyType2Commentary) {
            divergences.add(
              _Divergence(
                'pair=(${a.pitch.format()} $lowerAcc, ${b.pitch.format()} $upperAcc) type2 commentary',
                legacyType2Commentary,
                newType2Commentary,
              ),
            );
          }
        }
      }
    }
  }

  test('AnswerChecker + Commentary agree with legacy getResultAllHard/commentaryKeyReturn/commentaryType2', () {
    print(
      'answer_checker_parity: $comparisons comparisons, '
      '$skipped combinations skipped (unanswerable), '
      '${divergences.length} divergences',
    );

    if (divergences.isNotEmpty) {
      print('First 20 divergences:');
      for (final d in divergences.take(20)) {
        print(d);
      }
    }

    expect(
      divergences,
      isEmpty,
      reason: '${divergences.length} divergence(s) out of $comparisons comparisons',
    );
  });
}
