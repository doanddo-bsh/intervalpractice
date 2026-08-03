import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/problem_mode.dart';
import '../../domain/staff_layout.dart';

/// 문제 유형에 따라 다른 정답 입력 UI를 제공한다.
///
/// - 유형 1, 3: 도수(1~8) 선택 후 품질(감/완전/증/...) 선택
/// - 유형 2: 계이름(도~시) 선택
class AnswerPad extends StatelessWidget {
  const AnswerPad({
    super.key,
    required this.mode,
    required this.selectedSize,
    required this.submittedAnswer,
    required this.onSizeSelected,
    required this.onQualitySelected,
    required this.onNoteSelected,
  });

  final ProblemMode mode;

  /// 유형 1/3에서 먼저 고른 도수. 아직 안 골랐으면 null.
  final String? selectedSize;

  /// 최종 제출된 답. 제출 후에는 버튼을 잠근다.
  final String? submittedAnswer;

  final ValueChanged<String> onSizeSelected;
  final ValueChanged<String> onQualitySelected;
  final ValueChanged<String> onNoteSelected;

  static const _sizes = ['1', '2', '3', '4', '5', '6', '7', '8'];
  static const _perfectQualities = ['감', '완전', '증'];
  static const _imperfectQualities = ['겹감', '단', '장', '겹증'];

  @override
  Widget build(BuildContext context) {
    if (mode.questionType == QuestionType.nameTheNote) {
      return _NotePad(
        submittedAnswer: submittedAnswer,
        onSelected: onNoteSelected,
      );
    }

    return Column(
      children: [
        Text('음정의 간격을 고르세요', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 25.0.h),
        _ButtonRow(
          labels: _sizes.sublist(0, 4),
          selected: selectedSize,
          enabled: submittedAnswer == null,
          onTap: onSizeSelected,
        ),
        SizedBox(height: 13.0.h),
        _ButtonRow(
          labels: _sizes.sublist(4),
          selected: selectedSize,
          enabled: submittedAnswer == null,
          onTap: onSizeSelected,
        ),
        SizedBox(height: 30.0.h),
        if (selectedSize != null) ...[
          Text('음정의 이름을 고르세요', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: 30.0.h),
          // values는 제출값과 같은 형식("장3")이어야 선택 하이라이트가 맞는다.
          _ButtonRow(
            labels: _perfectQualities.map((q) => '$q$selectedSize도').toList(),
            values: _perfectQualities.map((q) => '$q$selectedSize').toList(),
            selected: submittedAnswer,
            enabled: submittedAnswer == null,
            onTap: onQualitySelected,
          ),
          SizedBox(height: 13.0.h),
          _ButtonRow(
            labels: _imperfectQualities.map((q) => '$q$selectedSize도').toList(),
            values: _imperfectQualities.map((q) => '$q$selectedSize').toList(),
            selected: submittedAnswer,
            enabled: submittedAnswer == null,
            onTap: onQualitySelected,
          ),
        ],
      ],
    );
  }
}

class _NotePad extends StatelessWidget {
  const _NotePad({required this.submittedAnswer, required this.onSelected});

  final String? submittedAnswer;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    const names = StaffLayout.koreanNoteNames;

    return Column(
      children: [
        Text('알맞은 계이름을 고르세요', style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: 25.0.h),
        _ButtonRow(
          labels: names.sublist(0, 4),
          selected: submittedAnswer,
          enabled: submittedAnswer == null,
          onTap: onSelected,
        ),
        SizedBox(height: 13.0.h),
        _ButtonRow(
          labels: names.sublist(4),
          selected: submittedAnswer,
          enabled: submittedAnswer == null,
          onTap: onSelected,
        ),
      ],
    );
  }
}

class _ButtonRow extends StatelessWidget {
  const _ButtonRow({
    required this.labels,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.values,
  });

  final List<String> labels;

  /// 콜백에 넘길 값. 생략하면 labels를 그대로 쓴다.
  final List<String>? values;
  final String? selected;
  final bool enabled;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final actualValues = values ?? labels;

    return SizedBox(
      height: 35.0.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < labels.length; i++)
            _AnswerButton(
              label: labels[i],
              isSelected: selected == actualValues[i],
              onPressed: enabled ? () => onTap(actualValues[i]) : null,
            ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? colors.secondaryContainer
            : colors.surfaceContainerHighest,
        foregroundColor: colors.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label),
    );
  }
}
