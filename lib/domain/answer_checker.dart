import 'commentary.dart';
import 'korean_interval.dart';
import 'problem.dart';
import 'problem_mode.dart';
import 'staff_layout.dart';

/// 채점 결과.
final class Grading {
  const Grading({
    required this.isCorrect,
    required this.correctAnswerText,
    required this.commentary,
  });

  final bool isCorrect;

  /// 사용자에게 보여줄 정답 문자열 ("장3도" 또는 "솔").
  final String correctAnswerText;

  /// 해설. 없으면 빈 문자열.
  final String commentary;
}

abstract final class AnswerChecker {
  /// 유형 2(계이름 맞히기)에서 화면에 보여줄 "주어진 음정" 이름.
  ///
  /// 유형 2는 한 음을 가리고 나머지 계이름을 묻는다. **어떤 음정인지 알려주지
  /// 않으면 답을 알아낼 방법이 없다** — 7개 중 찍는 문제가 된다.
  static String givenIntervalText(IntervalProblem problem) {
    final pitches = problem.sortedPitches;
    return '${KoreanInterval.fromInterval(pitches[0].interval(pitches[1]))}도';
  }

  /// 유형 2에서 **가려진 음이 보이는 음보다 위**인지.
  ///
  /// `StaffLayout` 인덱스는 0이 맨 위(D6)이므로 인덱스가 작을수록 높은 음이다.
  /// 가려지는 것은 항상 [IntervalProblem.upper] 다.
  static bool hiddenNoteIsAbove(IntervalProblem problem) =>
      problem.upper.index < problem.lower.index;

  /// 유형 2에서 사용자가 골라야 하는 임시표 기호들. UI 버튼 순서와 같다.
  ///
  /// 원본 앱의 표기를 그대로 쓴다: `b` 플랫, `bb` 겹플랫, `#` 샵, `x` 겹샵.
  static const accidentalSymbols = <String>['b', '없음', '#', 'bb', 'x'];

  /// 유형 2의 정답 문자열.
  ///
  /// Easy 는 계이름만(`솔`), Hard 는 임시표까지 포함한다(`솔#`).
  /// **Hard 에서 임시표를 빼면 정답을 특정할 수 없다** — 가려진 음이 솔인지
  /// 솔♯인지 구분이 안 되기 때문이다.
  static String noteAnswer(IntervalProblem problem, ProblemMode mode) {
    final letter = StaffLayout.koreanNameOf(problem.upper.pitch);
    if (!mode.usesAccidentals) return letter;

    return letter + accidentalSymbolOf(problem.hiddenAccidental);
  }

  /// 생성기가 쓰는 임시표 이름을 버튼 기호로 바꾼다.
  static String accidentalSymbolOf(String accidental) => switch (accidental) {
        'sharp' => '#',
        'double sharp' => 'x',
        'flat' => 'b',
        'double flat' => 'bb',
        _ => '',
      };

  /// 버튼 기호를 정답 문자열 조각으로 바꾼다. `없음`은 빈 문자열이다.
  static String answerFragmentOf(String symbol) => symbol == '없음' ? '' : symbol;

  static Grading grade({
    required IntervalProblem problem,
    required ProblemMode mode,
    required String submitted,
  }) {
    // 임시표 적용 + 정렬은 IntervalProblem이 안다 (Task 13에서 추가됨).
    final pitches = problem.sortedPitches;

    if (mode.questionType == QuestionType.nameTheNote) {
      final answer = noteAnswer(problem, mode);

      return Grading(
        isCorrect: submitted == answer,
        // Hard 는 어떤 음인지 분명히 보이도록 영문 표기를 함께 준다
        // (원본도 `솔#(G♯)` 형태였다).
        correctAnswerText: mode.usesAccidentals
            ? '$answer(${problem.hiddenPitch.note.format()})'
            : answer,
        commentary: Commentary.forNoteQuestion(pitches),
      );
    }

    var interval = pitches[0].interval(pitches[1]);
    if (mode.usesInvertedAnswer) interval = interval.inversion;

    final korean = KoreanInterval.fromInterval(interval);

    return Grading(
      isCorrect: submitted == korean,
      correctAnswerText: '$korean도',
      commentary: Commentary.forIntervalQuestion(
        pitches,
        korean,
        inverted: mode.usesInvertedAnswer,
      ),
    );
  }
}
