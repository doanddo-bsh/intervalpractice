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
import '../common/banner_ad_slot.dart';
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
            ? _actionButton('결과보기', _showFinalResult)
            : _actionButton('다음문제', _goToNextQuestion),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
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

    // 결과 화면은 Task 18에서 연결한다.
    setState(() {
      _selectedSize = null;
      _submittedAnswer = null;
    });
    _session.restart();
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
