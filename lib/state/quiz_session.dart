import 'package:flutter/foundation.dart';

import '../domain/problem.dart';
import '../domain/problem_generator.dart';
import '../domain/problem_mode.dart';

/// 한 판(10문제)의 진행 상태와 오답노트를 관리한다.
///
/// 기존에는 이 상태가 6개 화면에 각각 복제되어 있었다.
final class QuizSession extends ChangeNotifier {
  QuizSession({required this.mode, required ProblemGenerator generator})
      : _generator = generator {
    _current = _generator.next(mode: mode);
  }

  static const questionsPerRound = 10;

  final ProblemMode mode;
  final ProblemGenerator _generator;

  late IntervalProblem _current;
  int _questionNumber = 1;
  int _correctCount = 0;

  /// 이번 판에서 틀린 문제들 — 다음 복습 대상.
  final List<IntervalProblem> _wrongProblems = [];

  /// 복습 모드일 때 풀고 있는 문제 목록.
  List<IntervalProblem> _reviewQueue = [];
  bool _isReviewMode = false;

  IntervalProblem get current => _current;
  int get questionNumber => _questionNumber;
  int get correctCount => _correctCount;
  bool get isReviewMode => _isReviewMode;
  List<IntervalProblem> get wrongProblems => List.unmodifiable(_wrongProblems);

  int get totalQuestions =>
      _isReviewMode ? _reviewQueue.length : questionsPerRound;

  bool get isFinished => _questionNumber >= totalQuestions;

  bool get canStartReview => _wrongProblems.isNotEmpty;

  double get progress =>
      totalQuestions == 0 ? 0 : _questionNumber / totalQuestions;

  /// 채점 결과를 기록한다. 문제를 넘기지는 않는다.
  void recordAnswer({required bool isCorrect}) {
    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongProblems.add(_current);
    }
    notifyListeners();
  }

  /// 다음 문제로 넘어간다.
  void nextQuestion() {
    _questionNumber++;

    if (_isReviewMode) {
      final index = _questionNumber - 1;
      if (index < _reviewQueue.length) _current = _reviewQueue[index];
    } else {
      _current = _generator.next(mode: mode, previous: _current);
    }

    notifyListeners();
  }

  /// 이번 판의 오답만 다시 출제하는 복습 모드로 전환한다.
  void startReview() {
    if (_wrongProblems.isEmpty) return;

    _reviewQueue = List.of(_wrongProblems);
    _wrongProblems.clear();
    _isReviewMode = true;
    _questionNumber = 1;
    _correctCount = 0;
    _current = _reviewQueue.first;

    notifyListeners();
  }

  /// 새 10문제를 처음부터 시작한다.
  void restart() {
    _wrongProblems.clear();
    _reviewQueue = [];
    _isReviewMode = false;
    _questionNumber = 1;
    _correctCount = 0;
    _current = _generator.next(mode: mode);

    notifyListeners();
  }
}
