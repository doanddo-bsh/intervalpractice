import 'dart:math';

import 'korean_interval.dart';
import 'problem.dart';
import 'problem_mode.dart';
import 'staff_layout.dart';

/// 문제를 무작위 생성한다.
///
/// [Random]을 주입받으므로 테스트에서 seed를 고정해 재현할 수 있다.
/// 기존 `getProblemListNote`가 내부에서 `Random()`을 새로 만들던 문제를 해결한다.
final class ProblemGenerator {
  ProblemGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// 두 음 사이 허용 최대 자리 간격. 넘으면 다시 뽑는다.
  static const _maxSlotDistance = 7;

  /// 재시도 상한 — 무한 루프 방지.
  static const _maxAttempts = 1000;

  IntervalProblem next({
    required ProblemMode mode,
    IntervalProblem? previous,
  }) {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final first =
          StaffLayout.slots[_random.nextInt(StaffLayout.slots.length)];
      final second =
          StaffLayout.slots[_random.nextInt(StaffLayout.slots.length)];

      if (first.index == second.index) continue;
      if ((first.index - second.index).abs() > _maxSlotDistance) continue;

      if (previous != null && _isSamePair(first, second, previous)) continue;

      final problem = IntervalProblem(
        lower: first,
        upper: second,
        accidentals: mode.usesAccidentals
            ? _randomAccidentals(first, second)
            : const ['none', 'none'],
      );

      // Final safety net: `_forbidsDoubleAccidentals` below only guards the
      // double-accidental branch, but simple sharp/flat on both notes of a
      // semitone-boundary pair (E-F, B-C) can *also* land on an unanswerable
      // quality (e.g. E5-sharp + F5-flat -> descending dd2, no answer
      // button). Verifying the actual candidate here — rather than trying to
      // special-case every heuristic that could produce one — is what
      // actually closes the crash.
      if (!_isAnswerable(problem)) continue;

      return problem;
    }

    throw StateError('Failed to generate a problem after $_maxAttempts tries');
  }

  bool _isSamePair(StaffSlot a, StaffSlot b, IntervalProblem previous) =>
      {a.index, b.index}.difference(previous.slotIndices.toSet()).isEmpty;

  /// 임시표 배정: 한쪽만 50%, 양쪽 30%, 없음 20%.
  ///
  /// **원본 버그 수정.** 기존 `accidentalsFinal()`은 겹임시표 금지 목록
  /// (`noDiffDoubleList`)을 "양쪽 모두" 분기에서만 검사했다. 그런데 겹임시표를
  /// 생성할 수 있는 것은 "한쪽만" 분기뿐이라(`accidentals()`), 가드가 아무것도
  /// 막지 못했다. 그 결과 도달 가능한 Hard 조합 1,680개 중 8개가 앱을
  /// 크래시시켰고(`intervalNameEngKor[...]`가 null 반환 → `+` 호출),
  /// 16개는 정답이 빈칸으로 표시됐다. 여기서는 가드를 **겹임시표를 쓰는
  /// 분기에** 건다.
  List<String> _randomAccidentals(StaffSlot first, StaffSlot second) {
    final where = _random.nextDouble();

    if (where > 0.8) return const ['none', 'none'];

    final allowDouble = !_forbidsDoubleAccidentals(first, second);

    if (where <= 0.5) {
      // 한쪽에만 붙인다. 겹임시표는 이 분기에서만 나올 수 있으므로
      // 가드를 반드시 여기에 적용해야 한다.
      final accidental = allowDouble ? _anyAccidental() : _simpleAccidental();
      return _random.nextBool() ? [accidental, 'none'] : ['none', accidental];
    }

    // 양쪽 모두 — 원본과 동일하게 홑임시표만 쓴다.
    return [_simpleAccidental(), _simpleAccidental()];
  }

  String _anyAccidental() {
    final roll = _random.nextDouble();
    if (roll <= 0.35) return 'sharp';
    if (roll <= 0.70) return 'flat';
    if (roll <= 0.85) return 'double flat';
    return 'double sharp';
  }

  String _simpleAccidental() => _random.nextBool() ? 'sharp' : 'flat';

  /// 겹임시표를 붙였을 때 **사용자가 답할 수 없는** 음정이 되는 조합인지.
  ///
  /// 정답 버튼이 제공하는 품질은 감/겹감/단/장/완전/증/겹증 7종뿐이다.
  /// 반음 경계(E-F, B-C)나 이미 증·감인 음정에 겹임시표를 얹으면
  /// `ddd5`, `AAA4` 같은 세 겹 음정이 나오는데, 이건 버튼에 없어서
  /// 출제 자체가 잘못이다. 휴리스틱으로 짐작하지 말고 **실제로 계산해서**
  /// 답 가능 집합에 드는지 확인한다.
  bool _forbidsDoubleAccidentals(StaffSlot a, StaffSlot b) {
    for (final accidental in const ['double sharp', 'double flat']) {
      for (final order in const [true, false]) {
        final accidentals = order ? [accidental, 'none'] : ['none', accidental];
        final problem = IntervalProblem(
          lower: a,
          upper: b,
          accidentals: accidentals,
        );
        if (!_isAnswerable(problem)) return true;
      }
    }
    return false;
  }

  /// 이 문제의 정답이 UI 버튼으로 입력 가능한지.
  ///
  /// 자리바꿈 문제(유형 3)는 inverted 음정이 정답이므로 그쪽도 확인한다.
  bool _isAnswerable(IntervalProblem problem) {
    final pitches = problem.sortedPitches;
    final interval = pitches[0].interval(pitches[1]);

    return KoreanInterval.isAnswerable(interval) &&
        KoreanInterval.isAnswerable(interval.inversion);
  }
}
