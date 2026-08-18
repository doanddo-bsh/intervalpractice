import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/problem_mode.dart';
import '../../domain/staff_layout.dart';
import '../../theme/app_theme.dart';

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
        difficulty: mode.difficulty,
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
          difficulty: mode.difficulty,
        ),
        SizedBox(height: 13.0.h),
        _ButtonRow(
          labels: _sizes.sublist(4),
          selected: selectedSize,
          enabled: submittedAnswer == null,
          onTap: onSizeSelected,
          difficulty: mode.difficulty,
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
            difficulty: mode.difficulty,
          ),
          SizedBox(height: 13.0.h),
          _ButtonRow(
            labels: _imperfectQualities.map((q) => '$q$selectedSize도').toList(),
            values: _imperfectQualities.map((q) => '$q$selectedSize').toList(),
            selected: submittedAnswer,
            enabled: submittedAnswer == null,
            onTap: onQualitySelected,
            difficulty: mode.difficulty,
          ),
        ],
      ],
    );
  }
}

class _NotePad extends StatelessWidget {
  const _NotePad({
    required this.submittedAnswer,
    required this.onSelected,
    required this.difficulty,
  });

  final String? submittedAnswer;
  final ValueChanged<String> onSelected;
  final Difficulty difficulty;

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
          difficulty: difficulty,
        ),
        SizedBox(height: 13.0.h),
        _ButtonRow(
          labels: names.sublist(4),
          selected: submittedAnswer,
          enabled: submittedAnswer == null,
          onTap: onSelected,
          difficulty: difficulty,
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
    required this.difficulty,
    this.values,
  });

  final Difficulty difficulty;

  final List<String> labels;

  /// 콜백에 넘길 값. 생략하면 labels를 그대로 쓴다.
  final List<String>? values;
  final String? selected;
  final bool enabled;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final actualValues = values ?? labels;

    // 버튼이 고유 폭을 요구하면 "겹감3도"처럼 긴 라벨 4개가 한 줄에 들어갈 때
    // 좁은 기기(375pt: iPhone SE, 13 mini 등)에서 가로로 넘친다. 남는 폭을
    // 균등하게 나눠 갖게 하고, 라벨은 필요하면 축소되도록 한다.
    return SizedBox(
      // 원본 앱과 같은 높이. 폭은 Expanded 로 나눠 갖게 해서
      // 좁은 기기(375pt)에서 넘치지 않게 한다 — 원본은 여기서 넘쳤다.
      height: 35.0.h,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: _AnswerButton(
                  label: labels[i],
                  isSelected: selected == actualValues[i],
                  onPressed: enabled ? () => onTap(actualValues[i]) : null,
                  difficulty: difficulty,
                ),
              ),
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
    required this.difficulty,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onPressed;
  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    // 원본 앱의 색 조합을 그대로 쓴다 — M3 가 뽑는 색보다 보기 좋다는 판단.
    // 잉크(누를 때 번지는 색)만 난이도를 따라간다.
    final accent = difficulty == Difficulty.easy
        ? AppTheme.easyAccent
        : AppTheme.hardAccent;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? AppTheme.answerButtonSelected
            : AppTheme.answerButtonBackground,
        foregroundColor: accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        // Material 기본 최소 폭(64)이 Expanded 안에서도 하한으로 작동해
        // 좁은 기기에서 넘침을 유발한다.
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: AutoSizeText(
        label,
        maxLines: 1,
        style: TextStyle(fontSize: 14.sp, color: AppTheme.answerButtonText),
        // 좁은 기기에서는 줄어들되 너무 작아지지는 않게 한다.
        minFontSize: 10,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
