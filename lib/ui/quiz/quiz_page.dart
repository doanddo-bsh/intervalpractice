import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../ads/ad_ids.dart';
import '../../ads/ad_service.dart';
import '../../domain/answer_checker.dart';
import '../../domain/problem_generator.dart';
import '../../domain/problem_mode.dart';
import '../../state/ad_counter.dart';
import '../../state/quiz_session.dart';
import '../../theme/app_theme.dart';
import '../common/banner_ad_slot.dart';
import '../result/result_page.dart';
import 'answer_pad.dart';
import 'progress_bar.dart';
import 'result_sheet.dart';
import 'staff_view.dart';

/// 기존 easyProblemType1/2/3, hardProblemType1/2/3 여섯 화면을 대체한다.
class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.mode});

  final ProblemMode mode;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final QuizSession _session = QuizSession(
    mode: widget.mode,
    generator: ProblemGenerator(),
  );
  final _interstitial = InterstitialAdService();

  String? _selectedSize;
  String? _submittedAnswer;

  @override
  void initState() {
    super.initState();
    _interstitial.preload();
  }

  @override
  void dispose() {
    _interstitial.dispose();
    _session.dispose();
    super.dispose();
  }

  void _submit(String answer) {
    context.read<AdCounter>().increment();

    setState(() => _submittedAnswer = answer);

    final grading = AnswerChecker.grade(
      problem: _session.current,
      mode: widget.mode,
      submitted: answer,
    );

    _session.recordAnswer(isCorrect: grading.isCorrect);
    _showResultSheet(grading);
  }

  void _showResultSheet(Grading grading) {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => AnswerResultSheet(
        isCorrect: grading.isCorrect,
        answerText: grading.correctAnswerText,
        commentary: grading.commentary,
        actionButton: _session.isFinished
            ? _actionButton(
                '결과보기',
                _showFinalResult,
                isCorrect: grading.isCorrect,
              )
            : _actionButton(
                '다음문제',
                _goToNextQuestion,
                isCorrect: grading.isCorrect,
              ),
      ),
    );
  }

  /// 결과 시트의 진행 버튼.
  ///
  /// 원본 앱과 같이 정답이면 초록, 오답이면 주황이다. 오답 시트에 초록
  /// 버튼이 놓이면 결과와 어긋나 보인다.
  ///
  /// [isCorrect] 를 생략하면 결과와 무관한 버튼(결과 화면의 "네" 등)으로
  /// 보고 초록을 쓴다.
  Widget _actionButton(
    String label,
    VoidCallback onPressed, {
    bool isCorrect = true,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCorrect ? AppTheme.easyAccent : AppTheme.hardAccent,
        foregroundColor: Colors.white,
        elevation: 3,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  void _goToNextQuestion() {
    Navigator.pop(context);
    setState(() {
      _selectedSize = null;
      _submittedAnswer = null;
    });
    _session.nextQuestion();
  }

  void _showFinalResult() {
    Navigator.pop(context);

    final counter = context.read<AdCounter>();
    if (counter.solvedCount >= AdIds.interstitialThreshold) {
      if (_interstitial.showIfReady()) counter.reset();
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      builder: (_) => resultPage(
        context,
        wrongProblemMode: _session.isReviewMode,
        numberOfRight: _session.correctCount,
        totalQuestions: _session.totalQuestions,
        nextProblemResult: _actionButton('네', _restartRound),
        wrongProblemSolveStart: _wrongProblemSolveStartButton(),
        onPressedNo: _goHome,
      ),
    );
  }

  Widget _wrongProblemSolveStartButton() {
    final colors = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: _session.canStartReview ? _startReview : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.secondaryContainer,
      ),
      child: Text(
        '틀린 문제 다시 풀기',
        style: TextStyle(
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          color: colors.onSecondaryContainer,
        ),
      ),
    );
  }

  void _restartRound() {
    Navigator.pop(context);
    setState(() {
      _selectedSize = null;
      _submittedAnswer = null;
    });
    _session.restart();
  }

  void _startReview() {
    Navigator.pop(context);
    setState(() {
      _selectedSize = null;
      _submittedAnswer = null;
    });
    _session.startReview();
  }

  /// 기존 코드는 `Navigator.popUntil(context,
  /// ModalRoute.withName("/FirstProblemTypeList"))`로 홈까지 되돌아갔다.
  /// 그 이름 붙은 라우트는 실제로 등록된 적이 없어 동작하지 않았다 — 홈은
  /// `LoadingPage` -> `InitializeScreen` -> `HomePage`로 이어지는
  /// `pushReplacement` 체인의 끝이라 항상 첫 번째 라우트다.
  void _goHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(_session.isReviewMode ? '오답문제' : widget.mode.title),
          ),
          body: Column(
            children: [
              QuizProgressBar(session: _session),
              StaffView(
                problem: _session.current,
                hideUpperNote:
                    widget.mode.questionType == QuestionType.nameTheNote,
              ),
              AnswerPad(
                mode: widget.mode,
                selectedSize: _selectedSize,
                submittedAnswer: _submittedAnswer,
                onSizeSelected: (size) => setState(() => _selectedSize = size),
                // AnswerPad가 이미 "장3" 형태로 조립해 넘겨준다.
                onQualitySelected: _submit,
                onNoteSelected: _submit,
                givenInterval:
                    widget.mode.questionType == QuestionType.nameTheNote
                        ? AnswerChecker.givenIntervalText(_session.current)
                        : null,
                hiddenNoteIsAbove: AnswerChecker.hiddenNoteIsAbove(
                  _session.current,
                ),
              ),
              const Expanded(child: SizedBox()),
              const BannerAdSlot(),
              SizedBox(height: 30.h),
            ],
          ),
        );
      },
    );
  }
}
