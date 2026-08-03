/// 난이도 — 임시표(#, b, ##, bb) 사용 여부를 결정한다.
enum Difficulty {
  /// 임시표 없는 기본 계이름만 출제한다.
  easy,

  /// 임시표를 무작위로 붙여 출제한다.
  hard;

  bool get usesAccidentals => this == Difficulty.hard;
}

/// 문제 유형 — 무엇을 묻는지 결정한다.
enum QuestionType {
  /// 유형 1: 악보의 두 음을 보고 음정 이름을 고른다.
  nameTheInterval,

  /// 유형 2: 한 음과 음정이 주어지고 나머지 계이름을 고른다.
  nameTheNote,

  /// 유형 3: 두 음의 자리바꿈 음정을 고른다.
  invertedInterval;

  bool get usesInvertedAnswer => this == QuestionType.invertedInterval;
}

/// 난이도 × 문제유형 조합. 기존 6개 화면 파일을 대체하는 파라미터.
final class ProblemMode {
  const ProblemMode({required this.difficulty, required this.questionType});

  final Difficulty difficulty;
  final QuestionType questionType;

  bool get usesAccidentals => difficulty.usesAccidentals;
  bool get usesInvertedAnswer => questionType.usesInvertedAnswer;

  /// AppBar에 표시할 제목.
  String get title => switch (difficulty) {
    Difficulty.easy => 'Easy',
    Difficulty.hard => 'Hard',
  };

  /// 홈 화면 목록에 표시할 문제 제목.
  String get listTitle => switch (questionType) {
    QuestionType.nameTheInterval => '음정 문제 1',
    QuestionType.nameTheNote => '음정 문제 2',
    QuestionType.invertedInterval => '음정 문제 3',
  };

  /// 홈 화면 목록에 표시할 설명 2줄.
  List<String> get listDescription => switch (questionType) {
    QuestionType.nameTheInterval => const ['악보 위의 음정을 계산하여', '정답을 맞춰보세요'],
    QuestionType.nameTheNote => const ['주어진 음정을 보고 알맞은', '계이름을 계산하여 맞춰보세요'],
    QuestionType.invertedInterval => const ['주어진 음정의 자리바꿈 음정을', '계산하여 정답을 맞춰보세요'],
  };

  /// 가능한 6가지 조합 전부.
  static const all = <ProblemMode>[
    ProblemMode(
      difficulty: Difficulty.easy,
      questionType: QuestionType.nameTheInterval,
    ),
    ProblemMode(
      difficulty: Difficulty.easy,
      questionType: QuestionType.nameTheNote,
    ),
    ProblemMode(
      difficulty: Difficulty.easy,
      questionType: QuestionType.invertedInterval,
    ),
    ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.nameTheInterval,
    ),
    ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.nameTheNote,
    ),
    ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.invertedInterval,
    ),
  ];

  /// 난이도별 목록 (홈 화면 탭에 사용).
  static List<ProblemMode> forDifficulty(Difficulty difficulty) =>
      all.where((mode) => mode.difficulty == difficulty).toList();

  @override
  bool operator ==(Object other) =>
      other is ProblemMode &&
      other.difficulty == difficulty &&
      other.questionType == questionType;

  @override
  int get hashCode => Object.hash(difficulty, questionType);

  @override
  String toString() => 'ProblemMode(${difficulty.name}, ${questionType.name})';
}
