# 재출시 인수인계

**브랜치:** `revival/2026-modernization` (48 커밋, `master`에 아직 미병합)
**버전:** `1.1.0+6` (이전 `1.0.4+5`)

`flutter test` 71개 통과 · `flutter analyze` 이슈 0건 · `dart format` clean · 양 플랫폼 릴리즈 빌드 성공.

---

## 아직 사람이 해야 하는 일

### 1. 실기기 확인 — 상당 부분 자동화됨, 남은 건 폴더블

iOS 시뮬레이터(iPhone 17 Pro / iOS 26.5)에서 앱을 실제로 띄워 검증했다. 그 과정에서 정적 검증으로는 잡히지 않는 **결함 3건**을 찾아 고쳤다(아래 "실행 중 발견한 결함" 참조).

**자동화된 검증** — `flutter test integration_test/quiz_flow_test.dart -d <device-id>`

시뮬레이터에서 실제로 탭하며 5개 시나리오 통과:
- 유형 1, 라이트/다크 양쪽: 도수 선택 → 품질 버튼 등장 → 채점 → 결과 시트 → 다음 문제
- 유형 2: 윗음이 실제로 가려지고 계이름 7버튼 동작
- 10문제 완주 → **결과 화면 도달** (리팩토링 막바지에 붙인 경로라 그전엔 한 번도 실행된 적 없었음)
- 6개 모드 전부에서 레이아웃 예외 없음

**골든 렌더** — `flutter test --update-goldens test/ui/`
6개 모드 × 라이트/다크 = 12조합 PNG. `test/ui/goldens/` 에서 눈으로 확인 가능.

**아직 남은 것:**

- [ ] **폴더블(Galaxy Z Fold) 확인** — 시뮬레이터로 대체 불가. 접힘/펼침 화면비에서 고정 좌표 오선지 레이아웃이 견디는지 봐야 한다.
  주의: 폰에 출시 버전이 깔려 있으면 서명이 달라 덮어쓸 수 없다(`INSTALL_FAILED_UPDATE_INCOMPATIBLE`). 기존 앱을 지워야 설치된다.
- [ ] 결과 화면의 반투명 오버레이(`alpha: 0.6`) 시각적 적절성
- [ ] 임시표가 음표 머리에 겹쳐 보이는 부분이 실사용에서 거슬리는지 (원본과 동일한 배치라 의도적으로 두었다)

### 2. Play Console 업로드 키 대조 — ✅ 2026-08-10 확인 완료

앱 소유자가 Play Console(앱 무결성 → 앱 서명 → 업로드 키 인증서)에서 직접 대조했고 **일치**한다.

세 지점이 모두 같은 지문임이 확인됐다:
1. 로컬 키스토어 `android/app/key.jks` (`keytool -list`)
2. 빌드된 AAB에서 추출한 인증서 (`keytool -printcert -jarfile`)
3. Play Console 등록값 (소유자 육안 확인)

아래는 기록용이며, 키스토어를 교체할 일이 생기면 같은 절차로 다시 확인할 것.

<details>
<summary>원래 절차</summary>

빌드된 AAB에서 추출한 서명 지문:

```
SHA-1: E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93
Owner: CN=seohwalee, OU=nowaa, O=nowaa, L=seoul, ST=korea, C=kr
Alias: key_intervalpractice
```

**Play Console → 테스트 및 출시 → 앱 무결성 → 앱 서명 → 업로드 키 인증서**와 대조할 것.
불일치 상태로 업로드하면 거부되고 복구에 구글 지원 요청이 필요하다.

</details>

### 3. Play Console 데이터 보안 양식 갱신

`firebase_core` / `firebase_analytics`를 제거했다 — 코드 호출부가 0곳이었고 `google-services.json`도 저장소에 없어 실제로 동작한 적이 없다.
기존 신고 내용에 Analytics 항목이 있다면 실제 구성과 어긋나므로 내려야 한다.

**현재 코드 기준으로 실제 수집되는 것은 광고 ID 하나뿐이다.**

| SDK | 수집 | 비고 |
|---|---|---|
| `google_mobile_ads` (AdMob) | 광고 ID(기기 ID) | 제3자(Google)와 공유, 광고 목적 |
| `app_tracking_transparency` | — | iOS에서 IDFA 접근 **동의를 받는** 역할. 자체 수집 없음 |
| `async_preferences` | — | 기기 내부 저장만. 전송 없음 |
| ~~`firebase_analytics`~~ | — | **제거됨** |

앱에 로그인·계정·사용자 생성 콘텐츠·위치 수집이 없다. 문제 풀이 기록도 저장하지 않는다(앱 종료 시 사라짐).

따라서 양식에서:
- **유지:** 기기 또는 기타 ID → 광고 ID (수집됨, 공유됨, 광고 또는 마케팅)
- **내릴 것:** Analytics를 전제로 신고했던 항목 — 앱 상호작용, 앱 내 검색 기록, 기타 앱 성능 데이터 등이 있다면 제거

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

## 실행 중 발견한 결함 (앱을 실제로 띄워서만 나온 것들)

| 결함 | 발견 방법 | 실사용 영향 |
|---|---|---|
| 홈 타일 아이콘이 다크모드에서 안 보임 | 스크린샷 픽셀 대비 측정 → **1.74:1** (그래픽 최소 3:1) | 다크모드 사용자에게 아이콘이 사실상 안 보임. 수정 후 **8.49:1** |
| 탭 지시선이 검정 | 사용자 육안 제보 | `BorderSide` 색 기본값이 검정이라, 다크모드에서 강조가 아니라 구분선이 끊긴 것처럼 보임 |
| 정답 버튼 가로 넘침 | 6개 모드 골든 렌더 중 예외 | **375pt 기기(iPhone SE, 13 mini)에서 넘침 줄무늬 노출.** `ElevatedButton` 기본 최소 폭 64pt가 원인 |

셋 다 `flutter analyze` 0건 · 테스트 전부 통과 상태에서 숨어 있었다. **위젯 테스트는 "위젯이 존재한다"를 증명하지만 "보인다/들어맞는다"는 증명하지 못한다.**

재발 방지로 `test/ui/quiz_modes_golden_test.dart` 가 12조합을 렌더하며 `takeException()`이 null인지 단언한다 — 넘침류 예외는 이제 테스트에서 잡힌다.

---

## 알려진 한계

`AnswerChecker.grade`는 답할 수 없는 음정에 `FormatException`을 던진다.
현재 도달 불가다 — `ProblemGenerator`가 후보를 `KoreanInterval.isAnswerable`로 검증한 뒤에만 내보내고, "양쪽 임시표" 분기는 홑임시표만 쓴다.
`test/domain/answer_checker_test.dart`의 통합 테스트(6개 모드 × 1,000회)가 이 보증을 지킨다.

---

## 참고

전체 구현 계획과 실행 중 판명된 정정 사항은
[`../superpowers/plans/2026-08-04-intervalpractice-revival.md`](../superpowers/plans/2026-08-04-intervalpractice-revival.md)에 있다.
