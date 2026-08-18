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
    this.givenInterval,
    this.hiddenNoteIsAbove = true,
  });

  /// 유형 2에서 화면에 보여줄 "주어진 음정" (예: `단3도`).
  ///
  /// 이게 없으면 사용자는 음표 하나만 보고 계이름 7개 중 찍어야 한다.
  final String? givenInterval;

  /// 유형 2에서 가려진 음이 보이는 음보다 위인지.
  final bool hiddenNoteIsAbove;

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
        givenInterval: givenInterval,
        hiddenNoteIsAbove: hiddenNoteIsAbove,
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
    required this.givenInterval,
    required this.hiddenNoteIsAbove,
  });

  final String? submittedAnswer;
  final ValueChanged<String> onSelected;
  final Difficulty difficulty;
  final String? givenInterval;
  final bool hiddenNoteIsAbove;

  @override
  Widget build(BuildContext context) {
    const names = StaffLayout.koreanNoteNames;

    return Column(
      children: [
        // 주어진 음정과 방향이 없으면 이 문제는 풀 수 없다. 원본 앱은 둘 다
        // 보여줬는데 리팩토링 과정에서 빠졌었다.
        if (givenInterval != null) ...[
          Text(
            '[ 주어진 음정 : $givenInterval ]',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.givenIntervalText,
            ),
          ),
          SizedBox(height: 14.0.h),
        ],
        Text(
          hiddenNoteIsAbove
              ? '주어진 음정을 위해 필요한 위↑ 계이름은?'
              : '주어진 음정을 위해 필요한 아래↓ 계이름은?',
          style: Theme.of(context).textTheme.titleSmall,
        ),
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
      height: 44.0.h,
      child: Row(
        // stretch 가 없으면 Row 기본 정렬(center)이 세로를 느슨하게 주고,
        // minimumSize: Size.zero 와 겹쳐 버튼이 글자 높이(약 22pt)로
        // 쪼그라든다. 지정한 높이를 그대로 채우게 한다.
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
