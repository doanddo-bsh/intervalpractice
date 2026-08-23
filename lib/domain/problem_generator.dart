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
            ? _randomAccidentals()
            : const ['none', 'none'],
      );

      // 답할 수 있는 문제인지는 **실제 후보를 계산해서** 판정한다.
      //
      // 예전에는 겹임시표를 만들기 전에 자리 조합을 보고 미리 막는
      // 휴리스틱(`_forbidsDoubleAccidentals`)이 있었는데, 두 가지가
      // 문제였다. (1) 그 가드는 한쪽에만 겹임시표를 붙인 경우만 검사해서
      // 반음 경계(E-F, B-C)에 홑임시표를 양쪽에 붙인 조합(E♯–F♭ 하행 겹감2도
      // 등)은 그냥 통과했고, (2) 겹임시표를 홑임시표로 조용히 강등시켜
      // 겹임시표 출현율을 명목값보다 낮게 끌어내렸다.
      //
      // 여기서 후보 전체를 검증하고 통과하지 못하면 자리부터 다시 뽑는다.
      // 강등이 없으므로 임시표 분포가 의도한 비율에 가깝게 유지된다.
      if (!_isAnswerable(problem)) continue;

      return problem;
    }

    throw StateError('Failed to generate a problem after $_maxAttempts tries');
  }

  bool _isSamePair(StaffSlot a, StaffSlot b, IntervalProblem previous) =>
      {a.index, b.index}.difference(previous.slotIndices.toSet()).isEmpty;

  /// 임시표를 어디에 붙일지: 한쪽에만 62.5%, 양쪽 모두 37.5%.
  ///
  /// **Hard 는 두 음 다 임시표가 없는 문제를 절대 내지 않는다.** 그런 문제는
  /// 같은 유형의 Easy 문제와 글자 하나 다르지 않아 난이도 구분이 사라진다.
  /// (원래는 20% 확률로 나왔고, 그 몫을 아래 두 분기가 원래 비율 50:30 을
  /// 유지한 채 나눠 가져 62.5:37.5 가 됐다.)
  ///
  /// 유형 2의 `없음` 버튼은 이래도 살아 있다. 한쪽에만 붙이는 분기에서
  /// 임시표가 **보이는 음**에 갈 수도 있고, 그러면 가려진 음의 정답은
  /// `없음`이 된다. 전체의 약 31%가 그 경우다.
  List<String> _randomAccidentals() {
    if (_random.nextDouble() <= 0.625) {
      final accidental = _anyAccidental();
      return _random.nextBool() ? [accidental, 'none'] : ['none', accidental];
    }

    return [_anyAccidental(), _anyAccidental()];
  }

  /// 임시표 한 개를 고른다. 네 종류를 고르게 섞으려고 홑 30% / 겹 20%씩 준다.
  ///
  /// 겹임시표에 홑임시표보다 낮은 가중치를 주는 이유는, 겹임시표가 낀 후보가
  /// [_isAnswerable] 에서 더 자주 탈락하기 때문이 아니라 — 그건 재추첨으로
  /// 보정된다 — 겹임시표만 잔뜩 나오면 문제가 실제 악보에서 볼 일 없는
  /// 모양이 되기 때문이다. 명목값과 실제 출현율은
  /// `test/domain/problem_generator_test.dart` 에서 검증한다.
  String _anyAccidental() {
    final roll = _random.nextDouble();
    if (roll < 0.30) return 'sharp';
    if (roll < 0.60) return 'flat';
    if (roll < 0.80) return 'double sharp';
    return 'double flat';
  }

  /// 이 문제의 정답이 UI 버튼으로 입력 가능한지.
  ///
  /// 정답 버튼이 제공하는 품질은 감/겹감/단/장/완전/증/겹증 7종뿐이다.
  /// 반음 경계(E-F, B-C)나 이미 증·감인 음정에 겹임시표를 얹으면
  /// `ddd5`, `AAA4` 같은 세 겹 음정이 나오는데, 버튼에 없으니 출제 자체가
  /// 잘못이다.
  ///
  /// 자리바꿈 문제(유형 3)는 inverted 음정이 정답이므로 그쪽도 확인한다.
  bool _isAnswerable(IntervalProblem problem) {
    final pitches = problem.sortedPitches;
    final interval = pitches[0].interval(pitches[1]);

    return KoreanInterval.isAnswerable(interval) &&
        KoreanInterval.isAnswerable(interval.inversion);
  }
}
