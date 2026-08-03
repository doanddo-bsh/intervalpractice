import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 정답/오답 직후 아래에서 올라오는 시트.
///
/// 기존에는 6개 화면에 정답용/오답용 두 벌씩, 총 12벌이 복붙되어 있었다.
class AnswerResultSheet extends StatelessWidget {
  const AnswerResultSheet({
    super.key,
    required this.isCorrect,
    required this.answerText,
    required this.commentary,
    required this.actionButton,
  });

  final bool isCorrect;

  /// "정답 : 장3도" 에서 "장3도" 부분.
  final String answerText;

  /// 툴팁으로 보여줄 해설. 빈 문자열이면 툴팁을 숨긴다.
  final String commentary;

  /// "다음문제" 또는 "결과보기" 버튼.
  final Widget actionButton;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final background = isCorrect
        ? colors.primaryContainer
        : colors.errorContainer;
    final foreground = isCorrect
        ? colors.onPrimaryContainer
        : colors.onErrorContainer;

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      height: 185.h,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 27.h),
          Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isCorrect ? '정답입니다!' : '오답입니다',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (commentary.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [_CommentaryTooltip(message: commentary)],
                ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '정답 : $answerText',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          actionButton,
        ],
      ),
    );
  }
}

class _CommentaryTooltip extends StatelessWidget {
  const _CommentaryTooltip({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Tooltip(
        message: message,
        constraints: const BoxConstraints(minHeight: 80),
        verticalOffset: -120,
        triggerMode: TooltipTriggerMode.tap,
        showDuration: const Duration(seconds: 7),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
        child: const Icon(Icons.info_outline, size: 18),
      ),
    );
  }
}
