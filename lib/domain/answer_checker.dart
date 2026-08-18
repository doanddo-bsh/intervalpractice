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
  static Grading grade({
    required IntervalProblem problem,
    required ProblemMode mode,
    required String submitted,
  }) {
    // 임시표 적용 + 정렬은 IntervalProblem이 안다 (Task 13에서 추가됨).
    final pitches = problem.sortedPitches;

    if (mode.questionType == QuestionType.nameTheNote) {
      // 화면에 가려진 음(upper)의 계이름이 정답이다.
      final answer = StaffLayout.koreanNameOf(problem.upper.pitch);

      return Grading(
        isCorrect: submitted == answer,
        correctAnswerText: answer,
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
