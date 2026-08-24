import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/problem_mode.dart';
import '../../state/quiz_session.dart';

class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({super.key, required this.session});

  final QuizSession session;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = session.mode.difficulty == Difficulty.easy
        ? colors.primary
        : colors.tertiary;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 20.h,
          width: double.infinity,
          child: LinearProgressIndicator(
            value: session.progress,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Text(
          '${session.questionNumber}/${session.totalQuestions}',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
