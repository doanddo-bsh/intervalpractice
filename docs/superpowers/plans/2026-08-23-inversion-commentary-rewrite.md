# 자리바꿈(유형 3) 해설 문구 재작성 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 유형 3 해설을 "자리바꿈 **전** 음정이 뭐였는지 → 음을 **어떻게** 옮기는지(위·아래 양방향) → **그래서** 무슨 음정이 되는지" 순서로 다시 쓴다. Easy·Hard 공통.

**Architecture:** 해설은 `Commentary.forIntervalQuestion`이 문장 조각들을 `join(' ')`으로 이어 붙여 만든다. 지금은 그 맨 앞에 고정 문자열 `commentaryInversionLead` 하나가 붙는데, 이걸 **원음정 이름과 자리바꿈 후 도수를 받는 함수**로 바꾼다. 사용자에게 보이는 한국어 텍스트는 전부 `commentary_data.dart`에 모여 있다는 기존 규칙을 지킨다. 임시표 문장(`아래로 오는 음` / `위로 가는 음`)과 결론 문장(`반음이 N개이므로 …`)은 손대지 않는다.

**Tech Stack:** Dart / Flutter, `music_notes` 0.26, `flutter_test`

---

## 배경 — 왜 고치는가

현재 유형 3 해설:

```
자리바꿈하면 아래 음이 한 옥타브 위로 올라가 위아래가 바뀝니다.
아래로 오는 음에 붙은 더블플렛으로 인해 음정간 간격이 늘어나고
위로 가는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고
반음이 1개이므로 간격이 줄어들어 겹증2도 음정입니다
(장2도 음정의 기본 반음수는 0개)
```

문제 두 가지:

1. **한 방향만 말한다.** 자리바꿈은 아래 음을 한 옥타브 **올려도** 되고 위 음을 한 옥타브 **내려도** 된다. 어느 쪽이든 결과가 같다는 게 핵심인데 "아래 음이 위로 올라간다"만 적혀 있다.
2. **시작점이 없다.** 자리바꿈 **전**에 무슨 음정이었는지 한 번도 안 나온다. 학습자는 "증6도 → 감3도"라는 변환을 배워야 하는데 해설은 도착지만 알려 준다.

목표 문구 (Hard, 임시표 있음):

```
자리바꿈 전 음정은 겹감7도입니다.
자리바꿈은 아래 음을 한 옥타브 올려도 되고 위 음을 한 옥타브 내려도 됩니다. 어느 쪽이든 2도가 됩니다.
아래로 오는 음에 붙은 더블플렛으로 인해 음정간 간격이 늘어나고
위로 가는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고
반음이 1개이므로 간격이 줄어들어 겹증2도 음정입니다
(장2도 음정의 기본 반음수는 0개)
```

목표 문구 (Easy, 임시표 없음):

```
자리바꿈 전 음정은 단2도입니다.
자리바꿈은 아래 음을 한 옥타브 올려도 되고 위 음을 한 옥타브 내려도 됩니다. 어느 쪽이든 7도가 됩니다.
반음이 1개이므로 장7도 음정입니다
(장7도 음정의 기본 반음수는 1개)
```

(실제 출력은 줄바꿈 없이 한 줄로 이어진다. 위는 읽기 쉽게 쪼갠 것이다. 결론 문장 앞의 `\n`만 원본 데이터에 들어 있다.)

### 왜 "위아래가 바뀝니다"를 안 쓰는가

`ProblemGenerator._maxSlotDistance`가 7이라 **두 음이 정확히 한 옥타브 떨어진 문제가 실제로 나온다** (자리 인덱스 차 7). 그때 자리바꿈 결과는 1도다:

```
완전8도 -> 완전1도    (예: 도4 + 도5)
```

도4를 한 옥타브 올리면 두 음이 같은 도5가 되어 **위아래라는 게 없어진다.** 그래서 "위아래가 바뀝니다"는 이 경우 거짓말이 된다. 새 문구는 옮기는 동작만 서술하므로 1도가 나와도 참이다. 드문 경우가 아니다 — 자리 간격 1~7 중 하나이므로 대략 10문제에 1개꼴이다.

임시표 문장의 "아래로 오는 음 / 위로 가는 음"은 그대로 둔다. 완전8도→완전1도인 경우에만 무의미해지는데, 그건 두 음의 임시표가 서로 상쇄될 때(예: 도♯4 + 도♯5)뿐이고 그때도 계산 설명 자체는 맞다.

---

## File Structure

| 파일 | 책임 | 이 계획에서 하는 일 |
|---|---|---|
| `lib/domain/commentary_data.dart` | 사용자에게 보이는 해설 한국어 텍스트 전부 | `commentaryInversionLead` 상수를 지우고 `commentaryInversionIntro(원음정, 자리바꿈도수)` 함수를 넣는다 |
| `lib/domain/commentary.dart` | 조각을 조립해 해설 한 줄을 만든다 | 원음정 한글 이름과 자리바꿈 후 도수를 계산해 위 함수에 넘긴다 |
| `test/domain/commentary_test.dart` | 해설 전문(全文) 고정 | 유형 3 기대 문자열 3곳을 갱신하고 옥타브 경계 회귀 테스트를 추가한다 |
| `pubspec.yaml` | 버전 | `1.1.6+15` → `1.1.7+16` |
| `distribution/whatsnew/whatsnew-ko-KR` | Play Console 출시 노트 | 자리바꿈 항목 문구 갱신 |

새 파일은 만들지 않는다. 두 소스 파일 모두 작고 책임이 분명해 쪼갤 이유가 없다.

---

## Task 1: 자리바꿈 도입 문구를 "전 → 어떻게 → 결과" 순서로 바꾼다

**Files:**
- Modify: `lib/domain/commentary_data.dart:100-103` (`commentaryInversionLead` 정의)
- Modify: `lib/domain/commentary.dart:23-61` (`forIntervalQuestion`)
- Test: `test/domain/commentary_test.dart:194`, `:225`, `:300`, 그리고 맨 위 import 한 줄

> **순서 주의:** 이 태스크는 테스트 세 곳을 **한 번에** 고친다. 쪼개면 안 된다.
> `commentaryInversionLead` 상수가 사라지는 순간 `commentary_test.dart:300`이
> 없는 이름을 참조해 **파일 전체가 컴파일되지 않는다.** 그러면 "이 테스트 하나만
> 실패" 상태를 만들 수 없고, 다른 테스트도 전부 못 돌린다.

- [ ] **Step 1: 기존 기대값이 어디에 박혀 있는지 확인한다**

Run:
```bash
cd /Users/s.bark/Downloads/A001_project/A007_interval_practice
grep -rn "commentaryInversionLead\|자리바꿈하면 아래 음이" lib/ test/
```

Expected: 정확히 5줄 —
```
lib/domain/commentary_data.dart:102:const String commentaryInversionLead = ...
lib/domain/commentary.dart:56:      if (inverted) commentaryInversionLead,
test/domain/commentary_test.dart:194:        '자리바꿈하면 아래 음이 …'   <- Hard 전문 비교
test/domain/commentary_test.dart:225:        '자리바꿈하면 아래 음이 …'   <- Easy 전문 비교
test/domain/commentary_test.dart:300:            startsWith(commentaryInversionLead),
```
줄 번호가 다르면 파일이 그 사이 바뀐 것이니, 문자열로 찾아서 진행한다.

- [ ] **Step 2: 실패하는 테스트를 쓴다 — Hard 전문 비교 (`:194` 근처)**

`test('실기기 화면 사례 — 도♯4 + 시bb4, 정답 겹증2도', () {` 블록의 기대 문자열을 교체한다.

바꾸기 전:
```dart
      expect(
        grading.commentary,
        '자리바꿈하면 아래 음이 한 옥타브 위로 올라가 위아래가 바뀝니다. '
        '아래로 오는 음에 붙은 더블플렛으로 인해 음정간 간격이 늘어나고 '
        '위로 가는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고 '
        '반음이 1개이므로 간격이 줄어들어 겹증2도 음정입니다 '
        '\n(장2도 음정의 기본 반음수는 0개)',
      );
```
바꾼 뒤:
```dart
      expect(
        grading.commentary,
        '자리바꿈 전 음정은 겹감7도입니다. '
        '자리바꿈은 아래 음을 한 옥타브 올려도 되고 위 음을 한 옥타브 내려도 됩니다. '
        '어느 쪽이든 2도가 됩니다. '
        '아래로 오는 음에 붙은 더블플렛으로 인해 음정간 간격이 늘어나고 '
        '위로 가는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고 '
        '반음이 1개이므로 간격이 줄어들어 겹증2도 음정입니다 '
        '\n(장2도 음정의 기본 반음수는 0개)',
      );
```

- [ ] **Step 3: 실패하는 테스트를 쓴다 — Easy 전문 비교 (`:225` 근처)**

`test('Easy 유형 3 — 임시표가 없어도 자리바꿈 도입 문장이 붙는다', () {` 블록에서 테스트 이름과 기대 문자열을 모두 교체한다.

테스트 이름 (바꾸기 전 → 바꾼 뒤):
```dart
    test('Easy 유형 3 — 임시표가 없어도 자리바꿈 도입 문장이 붙는다', () {
```
```dart
    test('Easy 유형 3 — 자리바꿈 전 음정과 옮기는 방법을 먼저 알려 준다', () {
```

기대 문자열 (바꾸기 전):
```dart
      expect(
        grading.commentary,
        // 장7도의 기본 반음수도 1개라 "간격이 줄어들어"가 붙지 않는다.
        '자리바꿈하면 아래 음이 한 옥타브 위로 올라가 위아래가 바뀝니다. '
        '반음이 1개이므로 장7도 음정입니다 '
        '\n(장7도 음정의 기본 반음수는 1개)',
      );
```
바꾼 뒤:
```dart
      expect(
        grading.commentary,
        // 장7도의 기본 반음수도 1개라 "간격이 줄어들어"가 붙지 않는다.
        '자리바꿈 전 음정은 단2도입니다. '
        '자리바꿈은 아래 음을 한 옥타브 올려도 되고 위 음을 한 옥타브 내려도 됩니다. '
        '어느 쪽이든 7도가 됩니다. '
        '반음이 1개이므로 장7도 음정입니다 '
        '\n(장7도 음정의 기본 반음수는 1개)',
      );
```

- [ ] **Step 4: 스윕 테스트가 새 문구를 검사하게 바꾼다 (`:300` 근처)**

`test('생성 가능한 모든 유형 3 문제에서 자리바꿈 전용 문구만 쓴다', () {` 블록 안의 두 번째 `expect`를 교체한다. 이게 사라져야 `commentaryInversionLead`를 지울 수 있다.

바꾸기 전:
```dart
          expect(
            commentary,
            startsWith(commentaryInversionLead),
            reason: '$mode 해설이 자리바꿈 설명 없이 시작한다: $commentary',
          );
```
바꾼 뒤:
```dart
          expect(
            commentary,
            startsWith('자리바꿈 전 음정은 '),
            reason: '$mode 해설이 자리바꿈 전 음정 없이 시작한다: $commentary',
          );
          expect(
            commentary,
            contains('아래 음을 한 옥타브 올려도 되고 위 음을 한 옥타브 내려도 됩니다'),
            reason: '$mode 해설이 옮기는 방향을 한쪽만 설명한다: $commentary',
          );
```

- [ ] **Step 5: 쓰지 않게 된 import를 지운다**

`test/domain/commentary_test.dart` 맨 위(12줄 근처)의 아래 줄을 지운다. Step 4로 `commentaryInversionLead` 참조가 사라져 이 import를 쓰는 곳이 남지 않는다.

```dart
import 'package:intervalpractice/domain/commentary_data.dart';
```

- [ ] **Step 6: 실패를 확인한다**

Run:
```bash
flutter test test/domain/commentary_test.dart
```

Expected: FAIL — 유형 3 테스트 3개(Hard 전문, Easy 전문, 스윕)가 깨진다. 컴파일은 되어야 한다. 예:
```
Expected: '자리바꿈 전 음정은 겹감7도입니다. 자리바꿈은 아래 음을 …'
  Actual: '자리바꿈하면 아래 음이 한 옥타브 위로 올라가 위아래가 바뀝니다. …'
```
`Error: Undefined name 'commentaryInversionLead'` 같은 **컴파일 에러가 나면 Step 4나 5를 빠뜨린 것**이다. 돌아가서 마저 고친다.

- [ ] **Step 7: `commentary_data.dart`의 상수를 함수로 바꾼다**

`lib/domain/commentary_data.dart`에서 아래 블록을 찾는다:

```dart
/// 유형 3 해설 맨 앞에 붙는 도입 문장.
const String commentaryInversionLead = '자리바꿈하면 아래 음이 한 옥타브 위로 올라가 '
    '위아래가 바뀝니다.';
```

이걸 통째로 아래로 교체한다:

```dart
/// 유형 3 해설 맨 앞에 붙는 도입 문장 두 개.
///
/// [originalKorean] 은 자리바꿈 **전** 음정의 한글 이름("겹감7" 처럼 "도"가
/// 빠진 형태), [invertedSize] 는 자리바꿈 **후** 도수 한 글자("2")다.
///
/// 자리바꿈은 아래 음을 한 옥타브 올리는 것으로도, 위 음을 한 옥타브 내리는
/// 것으로도 할 수 있고 결과가 같다. 한쪽만 적어 두면 "반대로 옮기면 어떻게
/// 되나"라는 질문이 남으므로 둘 다 적는다.
///
/// "위아래가 바뀐다"고는 쓰지 않는다. `ProblemGenerator._maxSlotDistance`가
/// 7이라 두 음이 정확히 한 옥타브 떨어진 문제가 나오는데(대략 10문제에 1개),
/// 그때 자리바꿈 결과는 1도라 위아래라는 게 사라진다. 옮기는 동작만 서술하면
/// 그 경우에도 문장이 참이다.
String commentaryInversionIntro(String originalKorean, String invertedSize) =>
    '자리바꿈 전 음정은 $originalKorean도입니다. '
    '자리바꿈은 아래 음을 한 옥타브 올려도 되고 위 음을 한 옥타브 내려도 됩니다. '
    '어느 쪽이든 $invertedSize도가 됩니다.';
```

- [ ] **Step 8: `commentary.dart`가 새 함수를 쓰게 한다**

`lib/domain/commentary.dart`의 `forIntervalQuestion`에서 아래 두 곳을 고친다.

(a) 원음정을 따로 붙잡아 둔다. 현재 코드:
```dart
    var interval = sortedPitches[0].interval(sortedPitches[1]);
    if (inverted) interval = interval.inversion;
    final abbreviation = KoreanInterval.intervalAbbreviation(interval);
```
바꾼 뒤:
```dart
    final original = sortedPitches[0].interval(sortedPitches[1]);
    final interval = inverted ? original.inversion : original;
    final abbreviation = KoreanInterval.intervalAbbreviation(interval);

    // 도수는 항상 마지막 한 글자다. 품질(d/dd/m/M/P/A/AA)이 앞에 오고
    // 도수는 1~8 한 자리뿐이기 때문이다(KoreanInterval.isAnswerable 이 보장).
    final invertedSize = abbreviation[abbreviation.length - 1];
```

(b) 조립부. 현재 코드:
```dart
    return [
      // Easy 유형 3은 임시표가 없어 아래 두 줄이 비므로, 이 도입 문장이
      // 없으면 자리바꿈 문제인데 해설에 자리바꿈 얘기가 하나도 안 나온다.
      if (inverted) commentaryInversionLead,
      if (lower != null) lower,
      if (upper != null) upper,
      base,
    ].join(' ');
```
바꾼 뒤:
```dart
    return [
      // Easy 유형 3은 임시표가 없어 아래 두 줄이 비므로, 이 도입 문장이
      // 없으면 자리바꿈 문제인데 해설에 자리바꿈 얘기가 하나도 안 나온다.
      if (inverted)
        commentaryInversionIntro(
          KoreanInterval.fromInterval(original),
          invertedSize,
        ),
      if (lower != null) lower,
      if (upper != null) upper,
      base,
    ].join(' ');
```

주의: 기존 `key` 조립부는 `abbreviation[abbreviation.length - 1]`을 그대로 쓰고 있다. 이제 그 값이 `invertedSize` 변수에 들어 있으므로, 아래처럼 변수를 재사용하도록 바꾼다.

현재 코드:
```dart
    final key = abbreviation[abbreviation.length - 1] +
        _noteLetter(low) +
        _noteLetter(high);
```
바꾼 뒤:
```dart
    final key = invertedSize + _noteLetter(low) + _noteLetter(high);
```

- [ ] **Step 9: 테스트 통과와 정적 분석을 확인한다**

Run:
```bash
flutter test test/domain/commentary_test.dart
flutter analyze
```

Expected: `All tests passed!` 그리고 `No issues found!`

- [ ] **Step 10: 커밋**

```bash
git add lib/domain/commentary_data.dart lib/domain/commentary.dart test/domain/commentary_test.dart
git commit -m "feat(commentary): 유형 3 해설이 자리바꿈 전 음정과 옮기는 방향을 먼저 알려 준다"
```

---

## Task 2: 옥타브 경계(완전8도 → 완전1도) 회귀 테스트

Task 1에서 "위아래가 바뀝니다"라는 표현을 뺀 이유를 코드로 못 박는다. 이게 없으면 나중에 누군가 문장이 밋밋하다며 그 표현을 되살릴 수 있다.

**Files:**
- Test: `test/domain/commentary_test.dart`

- [ ] **Step 1: 옥타브 경계 회귀 테스트를 추가한다**

같은 `group('자리바꿈(유형 3) 해설은 …')` 안, `test('유형 1·2 에는 자리바꿈 도입 문장이 붙지 않는다', …)` **바로 앞**에 아래 테스트를 넣는다.

```dart
    test('완전8도 -> 완전1도 — "위아래가 바뀐다"고 말하지 않는다', () {
      // 자리 인덱스 차가 7(한 옥타브)인 문제는 실제로 출제된다. 그때
      // 자리바꿈 결과는 1도이고, 아래 음을 한 옥타브 올리면 두 음이 같은
      // 음이 되어 위아래라는 게 사라진다. 도입 문구가 "위아래가 바뀝니다"라고
      // 단언하면 이 경우 거짓이 된다.
      final problem = IntervalProblem(
        lower: StaffLayout.byIndex(8), // C5 — 악보에서 위
        upper: StaffLayout.byIndex(15), // C4 — 악보에서 아래
        accidentals: const ['none', 'none'],
      );
      const mode = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.invertedInterval,
      );

      final grading = AnswerChecker.grade(
        problem: problem,
        mode: mode,
        submitted: '',
      );

      expect(grading.correctAnswerText, '완전1도');
      expect(
        grading.commentary,
        '자리바꿈 전 음정은 완전8도입니다. '
        '자리바꿈은 아래 음을 한 옥타브 올려도 되고 위 음을 한 옥타브 내려도 됩니다. '
        '어느 쪽이든 1도가 됩니다. '
        '반음이 0개이므로 완전1도 음정입니다 '
        '\n(완전1도 음정의 기본 반음수는 0개)',
      );
      expect(grading.commentary, isNot(contains('위아래')));
    });
```

- [ ] **Step 2: 전체 테스트와 정적 분석**

Run:
```bash
flutter analyze
flutter test
flutter test --tags golden
```

Expected:
- `No issues found!`
- `All tests passed!` (기존 137개 + 새 테스트 1개 = 138개)
- 골든 18개 통과 (해설은 결과 시트 안이라 골든 이미지에 안 잡힌다. 깨지면 안 된다.)

- [ ] **Step 3: 커밋**

```bash
git add test/domain/commentary_test.dart
git commit -m "test(commentary): 완전8도 -> 완전1도에서 위아래 표현이 안 나오는지 고정"
```

---

## Task 3: 릴리즈 준비

**Files:**
- Modify: `pubspec.yaml:19` (`version:` 줄)
- Modify: `distribution/whatsnew/whatsnew-ko-KR`

- [ ] **Step 1: 버전을 올린다**

```bash
cd /Users/s.bark/Downloads/A001_project/A007_interval_practice
sed -i '' 's/^version: 1.1.6+15$/version: 1.1.7+16/' pubspec.yaml
grep '^version' pubspec.yaml
```

Expected: `version: 1.1.7+16`

- [ ] **Step 2: 출시 노트 셋째 줄을 갱신한다**

`distribution/whatsnew/whatsnew-ko-KR`의 셋째 줄을 아래로 교체한다.

바꾸기 전:
```
• 자리바꿈 문제 해설이 어느 음을 말하는지 분명해졌습니다. 자리를 바꾸면 위아래가 뒤집힌다는 설명을 함께 보여줍니다.
```
바꾼 뒤:
```
• 자리바꿈 문제 해설을 다시 썼습니다. 자리바꿈 전 음정이 무엇이었는지, 아래 음을 올리거나 위 음을 내리는 두 방법 중 어느 쪽이든 결과가 같다는 것까지 순서대로 보여줍니다.
```

글자 수를 확인한다:
```bash
wc -m distribution/whatsnew/whatsnew-ko-KR
```
Expected: 250 미만 (Play Console 한도 500자)

- [ ] **Step 3: 릴리즈 빌드**

```bash
flutter build appbundle --release
flutter build apk --release
```

Expected: 둘 다 `✓ Built …`

- [ ] **Step 4: 서명과 버전을 확인한다**

```bash
rm -f ~/Downloads/intervalpractice-1.1.6-15.aab
cp build/app/outputs/bundle/release/app-release.aab ~/Downloads/intervalpractice-1.1.7-16.aab
keytool -printcert -jarfile ~/Downloads/intervalpractice-1.1.7-16.aab 2>/dev/null | grep -m1 SHA1
rm -rf /tmp/aabchk
unzip -o -q ~/Downloads/intervalpractice-1.1.7-16.aab base/manifest/AndroidManifest.xml -d /tmp/aabchk
python3 -c "
d=open('/tmp/aabchk/base/manifest/AndroidManifest.xml','rb').read()
for t in (b'versionCode',b'versionName'):
    i=d.find(t); j=i+len(t)
    print(t.decode(),'=',d[j+2:j+2+d[j+1]].decode())"
```

Expected:
```
SHA1: E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93
versionCode = 16
versionName = 1.1.7
```
SHA1이 다르면 **업로드하지 말고 멈춘다** — Play Console이 거부한다.

- [ ] **Step 5: 실기기 확인**

기기가 연결되어 있으면(`adb devices`에 기기가 보이면) 설치해 Easy 3번과 Hard 3번을 각각 한 문제씩 풀고 `i` 버튼으로 해설을 본다.

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

확인할 것:
- 해설 첫 문장이 `자리바꿈 전 음정은 …도입니다.`로 시작하는가
- 둘째 문장에 `올려도 되고` / `내려도 됩니다`가 **둘 다** 있는가
- 어디에도 `위아래가 바뀝니다`가 남아 있지 않은가

기기가 없으면 이 단계는 건너뛰고, 보고할 때 **실기기 미확인**이라고 분명히 적는다.

- [ ] **Step 6: 커밋과 푸시**

```bash
git add pubspec.yaml distribution/whatsnew/whatsnew-ko-KR
git commit -m "chore(release): 1.1.7+16 — 자리바꿈 해설 재작성"
git push
```

---

## 완료 기준

- [ ] `flutter analyze` 무오류
- [ ] `flutter test` 138개 통과, `flutter test --tags golden` 18개 통과
- [ ] Easy·Hard 유형 3 해설이 모두 `자리바꿈 전 음정은 …`으로 시작한다
- [ ] 모든 유형 3 해설에 `올려도 되고` / `내려도 됩니다` 양방향 설명이 들어 있다
- [ ] 유형 1·2 해설에는 `자리바꿈`이라는 단어가 없다 (기존 테스트가 지킨다)
- [ ] `~/Downloads/intervalpractice-1.1.7-16.aab` 가 업로드 키로 서명돼 있고 versionCode 16이다
