# 재출시 인수인계

**브랜치:** `revival/2026-modernization` (48 커밋, `master`에 아직 미병합)
**버전:** `1.1.0+6` (이전 `1.0.4+5`)

`flutter test` 71개 통과 · `flutter analyze` 이슈 0건 · `dart format` clean · 양 플랫폼 릴리즈 빌드 성공.

---

## 아직 사람이 해야 하는 일

### 1. 실기기 확인 — 아직 아무도 앱을 실행해본 적이 없다

작업 환경에 시뮬레이터·에뮬레이터가 없어 **컴파일과 테스트만 검증했다.** UI가 실제로 어떻게 보이는지는 검증되지 않았다.

```bash
flutter run
```

확인 경로: 홈 → Easy 1/2/3 → Hard 1/2/3 각 2문제 → 10문제 완주 → 결과 화면 → 틀린 문제 다시 풀기 → 설정.
**라이트/다크 각각 한 번씩** 통과할 것.

다크모드에서 특히 볼 것 (위젯 테스트로는 "색 필터가 적용됐다"까지만 증명됨, "읽을 만한가"는 미검증):

- [ ] 오선 5줄이 배경과 구분되는가
- [ ] 음표 머리가 뭉개지지 않는가
- [ ] 임시표 `#` `♭` `𝄪` `𝄫` 가 읽히는가
- [ ] 높은음자리표가 읽히는가
- [ ] 정답/오답 시트가 양쪽 모드에서 읽히는가
- [ ] 결과 화면의 반투명 오버레이(`alpha: 0.6`)가 적절한가

### 2. Play Console 업로드 키 대조 — 되돌리기 어려움

빌드된 AAB에서 추출한 서명 지문:

```
SHA-1: E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93
Owner: CN=seohwalee, OU=nowaa, O=nowaa, L=seoul, ST=korea, C=kr
Alias: key_intervalpractice
```

**Play Console → 설정 → 앱 무결성 → 앱 서명 → 업로드 키 인증서**와 대조할 것.
불일치 상태로 업로드하면 거부되고 복구에 구글 지원 요청이 필요하다.

### 3. Play Console 데이터 보안 양식 갱신

`firebase_core` / `firebase_analytics`를 제거했다 — 코드 호출부가 0곳이었고 `google-services.json`도 저장소에 없어 실제로 동작한 적이 없다.
기존 신고 내용에 Analytics 항목이 있다면 실제 구성과 어긋나므로 내려야 한다.

### 4. GitHub Secrets 등록 후 배포

- Android: [`android-release-setup.md`](./android-release-setup.md) — Secret 5개
- iOS: [`ios-release-setup.md`](./ios-release-setup.md) — Secret 9개, **애플 자산 필요**

워크플로는 만들었으나 **푸시하지도, 실행하지도 않았다.** 실제 앱이 올라간 저장소이므로 그 결정은 소유자 몫이다.

### 5. iOS 배포에 필요한 자산 (아직 없음)

제공된 `keyfiles/`에는 안드로이드 자산만 있었다. iOS 자동 배포에는 아래가 필요하다:

- App Store Connect API Key (`.p8`) + Key ID + Issuer ID
- 배포 인증서 (`.p12`) + 내보내기 암호
- 프로비저닝 프로파일 (`.mobileprovision`) + 프로파일 **이름**
- Apple Team ID

`release-ios.yml`은 이것들이 없어 **한 번도 실행된 적이 없다.** 자산이 준비되면 그대로 동작하도록 작성돼 있으나, 미검증 항목이 가이드 부록에 명시돼 있다.

---

## 알아둘 결정 사항

**minSdk 21 → 24.** Android 5.0/5.1(API 21–22) 기기가 업데이트를 받지 못한다.
`google_mobile_ads 9.x`가 요구하는 값이고, 구 버전(4.0.0)은 Flutter가 제거한 v1 embedding을 참조하는 `webview_flutter_android`를 끌어와 **빌드 자체가 불가능**했다. 광고를 제거하지 않는 한 회피할 수 없다.

**전면광고가 이제 실제로 노출된다.** 기존 코드는 `loadAd()` 직후 같은 동기 블록에서 `show()`를 호출해 로딩 완료 전이라 거의 항상 무시됐다. 30문제마다 뜨기로 돼 있던 광고가 실제로 뜨므로 재출시 후 광고 지표가 달라질 수 있다.

---

## 알려진 한계

`AnswerChecker.grade`는 답할 수 없는 음정에 `FormatException`을 던진다.
현재 도달 불가다 — `ProblemGenerator`가 후보를 `KoreanInterval.isAnswerable`로 검증한 뒤에만 내보내고, "양쪽 임시표" 분기는 홑임시표만 쓴다.
`test/domain/answer_checker_test.dart`의 통합 테스트(6개 모드 × 1,000회)가 이 보증을 지킨다.

---

## 참고

전체 구현 계획과 실행 중 판명된 정정 사항은
[`../superpowers/plans/2026-08-04-intervalpractice-revival.md`](../superpowers/plans/2026-08-04-intervalpractice-revival.md)에 있다.
