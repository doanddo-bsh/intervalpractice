import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem_mode.dart';

void main() {
  group('ProblemMode', () {
    test('easy 난이도는 임시표를 쓰지 않는다', () {
      const mode = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.nameTheInterval,
      );

      expect(mode.usesAccidentals, isFalse);
    });

    test('hard 난이도는 임시표를 쓴다', () {
      const mode = ProblemMode(
        difficulty: Difficulty.hard,
        questionType: QuestionType.nameTheInterval,
      );

      expect(mode.usesAccidentals, isTrue);
    });

    test('자리바꿈 유형만 inverted 정답을 요구한다', () {
      const inversion = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.invertedInterval,
      );
      const plain = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.nameTheInterval,
      );

      expect(inversion.usesInvertedAnswer, isTrue);
      expect(plain.usesInvertedAnswer, isFalse);
    });

    test('6가지 조합이 모두 정의된다', () {
      expect(ProblemMode.all, hasLength(6));
      expect(ProblemMode.all.toSet(), hasLength(6));
    });

    test('appBar 제목은 난이도를 따른다', () {
      expect(
        const ProblemMode(
          difficulty: Difficulty.easy,
          questionType: QuestionType.nameTheInterval,
        ).title,
        'Easy',
      );
      expect(
        const ProblemMode(
          difficulty: Difficulty.hard,
          questionType: QuestionType.nameTheInterval,
        ).title,
        'Hard',
      );
    });
  });
}
