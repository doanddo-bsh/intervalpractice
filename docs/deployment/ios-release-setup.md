# iOS 릴리즈 배포 설정 가이드

> ## 🚫 차단됨 (BLOCKED) — 이 워크플로는 아직 실행할 수 없다
>
> `.github/workflows/release-ios.yml`은 작성되었고 YAML 문법과 `actionlint` 검사를
> 통과했지만, **서명에 필요한 Apple 자산이 하나도 없어 실제로 실행하면 반드시
> 실패한다.** Android 자산(`key.jks`, `key.properties`)만 이 프로젝트에
> 존재했고, iOS 배포 자산은 사용자가 아직 준다지 않았다.
>
> 아래 "1. GitHub Secrets 등록"의 **8개 Secret을 전부 등록하기 전에는 이
> 워크플로를 실행하지 말 것** (태그 푸시든 `workflow_dispatch`든). 실행하면
> 최선의 경우 "Verify certificate was imported" 스텝에서 빠르게 실패하고,
> 최악의 경우 10분 넘게 걸리는 Xcode 아카이브 단계 도중 실패해 macOS 러너
> 시간만 소모한다.
>
> 이 문서와 워크플로 파일 자체는 Claude가 로컬에서 검증 가능한 것만
> 검증했다 (YAML 문법, actionlint, `flutter build ios --release --no-codesign`,
> IPA 파일명 로직, `PlistBuddy` plist 생성 로직). **실제 서명, 아카이브,
> 내보내기(export), TestFlight 업로드는 단 한 번도 실행되지 않았다** — 이
> 자산들이 없으므로 Claude가 실행할 수 없었다. "부록 — 검증되지 않은 항목"을
> 반드시 읽을 것.

---

## 0. 사전 준비물

이 워크플로가 동작하려면 아래 4가지를 **사용자가** Apple Developer /
App Store Connect에서 직접 준비해야 한다. Claude는 Apple 계정에 접근할 수
없으므로 이 단계는 대신할 수 없다.

| 자산 | 형식 | 용도 |
|---|---|---|
| App Store Connect API Key | `.p8` + Key ID + Issuer ID | TestFlight 업로드 인증 |
| 배포 인증서 (Distribution certificate) | `.p12` + 내보내기 암호 | 앱 서명 |
| 프로비저닝 프로파일 | `.mobileprovision` + 정확한 이름 | 앱 서명 (인증서와 번들 ID를 연결) |
| Team ID | 10자리 영숫자 문자열 | `ExportOptions.plist`에 필요 |

- Apple Developer Program 멤버십 (유료, 연 $99) — 이미 App Store에 라이브
  상태인 앱이므로 이미 가입되어 있을 것이다.
- App Store Connect에 대한 **관리자(Admin) 또는 계정 소유자(Account
  Holder)** 권한 — API 키를 발급하려면 필요하다.
- Xcode 또는 macOS의 키체인 접근(Keychain Access) 앱 — 인증서를 `.p12`로
  내보내려면 필요하다 (또는 아래 2절의 커맨드라인 방법 사용).

---

## 1. GitHub Secrets 등록

저장소 → **Settings → Secrets and variables → Actions → New repository
secret**에서 아래 8개를 등록한다. 앞의 3개(`ANDROID_*`)와 달리 iOS는 3.
App Store Connect API 키 3개, 인증서/프로파일 관련 4개, Team ID 1개로
구성된다.

### `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID`, `APPSTORE_PRIVATE_KEY`

App Store Connect API 키 3종. 발급 방법은 2절 참고.

- `APPSTORE_ISSUER_ID` — App Store Connect API의 발급자(Issuer) ID.
  `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` 형태의 UUID.
- `APPSTORE_KEY_ID` — 발급한 API 키의 Key ID (10자리 영숫자, 예: `ABCD123456`).
- `APPSTORE_PRIVATE_KEY` — 다운로드한 `AuthKey_<KEY_ID>.p8` 파일의 **전체
  내용** (텍스트, base64 인코딩 불필요 — `-----BEGIN PRIVATE KEY-----`로
  시작하는 PEM 형식 그대로 붙여넣는다).

```bash
cat AuthKey_ABCD123456.p8 | pbcopy
```

> **`.p8` 파일은 딱 한 번만 다운로드할 수 있다.** Apple은 재다운로드를
> 지원하지 않으므로, 다운로드 직후 안전한 곳(예: 비밀번호 관리자)에
> 백업해두지 않으면 키를 잃어버렸을 때 새로 발급하고 이전 키를
> App Store Connect에서 폐기해야 한다.

### `IOS_CERTIFICATE_BASE64`, `IOS_CERTIFICATE_PASSWORD`

배포 인증서 `.p12`를 base64 인코딩한 문자열과, 내보낼 때 설정한 암호. 인증서
발급/내보내기 방법은 3절 참고.

```bash
base64 -i /path/to/dist_certificate.p12 | pbcopy
```

`IOS_CERTIFICATE_PASSWORD`는 `.p12`로 내보낼 때 Keychain Access가 직접
물어보는 암호다 — Apple ID 암호나 키체인 암호가 아니라, **그 순간 직접
정한** 임의의 암호다.

### `IOS_PROVISIONING_PROFILE_BASE64`, `IOS_PROVISIONING_PROFILE_NAME`

```bash
base64 -i /path/to/profile.mobileprovision | pbcopy
```

`IOS_PROVISIONING_PROFILE_NAME`은 프로파일 **파일 이름이 아니라**, 프로파일을
만들 때 지정한 표시 이름이다 (예: `intervalpractice App Store`). 정확한 값을
찾는 방법은 4절 참고 — 여기서 한 글자라도 틀리면 `ExportOptions.plist`가
가리키는 프로파일을 Xcode가 찾지 못해 export 단계가 실패한다.

### `APPSTORE_TEAM_ID`

Apple Developer Team ID, 10자리 영숫자 (예: `AB12CD34EF`). 찾는 방법은 5절
참고.

### `KEYCHAIN_PASSWORD`

CI가 매 실행마다 만드는 임시 키체인의 잠금 암호. 실제로 어디에도 다시
쓰이지 않는 값이므로, 아무 문자열이나 정해서 등록하면 된다 (예: 32바이트
랜덤 문자열).

```bash
openssl rand -base64 24 | pbcopy
```

---

## 2. App Store Connect API 키 만들기

1. [App Store Connect](https://appstoreconnect.apple.com/) 로그인 → **사용자
   및 액세스(Users and Access)** → **통합(Integrations)** 탭 → **App Store
   Connect API**.
2. **키 생성(Generate API Key)** 또는 `+` 클릭.
3. 이름은 예: `release-ios-ci`.
4. **액세스 권한(Access)**: **App Manager** 역할을 부여한다. TestFlight
   빌드 업로드에는 App Manager 또는 그 이상(Admin)이 필요하다 — Developer
   역할은 업로드 권한이 없어 `upload-testflight-build` 액션이 403으로
   실패한다.
5. 생성 후 **다운로드(Download API Key)** 클릭 — `AuthKey_<KEY_ID>.p8`
   파일이 다운로드된다. **이 버튼은 한 번만 활성화된다.** 위 1절의 경고
   참고.
6. 같은 화면에 표시되는 **Key ID**와, 페이지 상단의 **Issuer ID**를
   각각 `APPSTORE_KEY_ID`, `APPSTORE_ISSUER_ID`에 사용한다.

---

## 3. 배포 인증서를 키체인에서 `.p12`로 내보내기

인증서가 이미 로컬 키체인에 있다면 (Xcode로 한 번이라도 서명해본 적이
있다면 있을 가능성이 높다):

1. **Keychain Access** 앱 → 왼쪽에서 **로그인(login)** 키체인, **분류**에서
   **My Certificates** 선택.
2. `Apple Distribution: <팀 이름> (<Team ID>)` 또는 `iPhone Distribution: ...`
   이름의 항목을 찾는다. 항목을 펼치면 아래 개인 키가 함께 있어야 한다 —
   개인 키가 없으면 이 인증서로는 서명할 수 없다 (그 인증서를 발급한 바로
   그 macOS 기기에서만 개인 키를 가지고 있다).
3. 인증서를 우클릭 → **"...”내보내기(Export)"**.
4. 파일 형식: **Personal Information Exchange (.p12)**.
5. 저장 시 암호를 물어본다 — 이 암호가 `IOS_CERTIFICATE_PASSWORD`다. 빈
   암호도 기술적으로 가능하지만 권장하지 않는다.
6. macOS 로그인 암호를 한 번 더 물어본다 (키체인에서 개인 키를 꺼내는 것에
   대한 확인).

인증서가 아직 없다면, Apple Developer 웹사이트 → **Certificates,
Identifiers & Profiles → Certificates → +** 에서 **Apple Distribution**
유형으로 새로 만들어야 한다 (CSR을 Keychain Access의 **인증서 지원
→ 인증기관에서 인증서 요청**으로 먼저 만들어야 함). 이 경로는 이미 Play
Store에 라이브인 이 프로젝트에서는 필요 없을 가능성이 높다 (기존 인증서가
있을 것이다).

> 인증서 유효기간은 발급일로부터 보통 1년이다. 만료되면 워크플로가 서명
> 단계에서 실패한다 — 아래 "문제 해결"의 "만료된 인증서" 항목 참고.

---

## 4. 프로비저닝 프로파일 얻기 + 정확한 이름 찾기

1. [Apple Developer](https://developer.apple.com/account/resources/profiles/list)
   → **Certificates, Identifiers & Profiles → Profiles**.
2. 배포용(`App Store Connect` 배포 방식) 프로파일 중 **App ID**가
   `com.nowaa.intervalpractice`인 것을 찾는다. 없다면 **+** 로 새로 만든다:
   - Type: **App Store Connect**
   - App ID: `com.nowaa.intervalpractice`
   - 위 3절에서 준비한 배포 인증서를 선택
   - 이름을 직접 정한다 (예: `intervalpractice App Store`) — **이 이름이
     그대로 `IOS_PROVISIONING_PROFILE_NAME`이다.**
3. 기존 프로파일을 재사용하는 경우, 목록에서 해당 항목을 클릭하면 상세
   페이지 상단에 정확한 이름이 표시된다. **다운로드한 파일명이 아니라 이
   화면에 나온 이름**을 써야 한다 — Xcode가 프로파일을 다운로드하면서
   파일명에 UUID를 붙이는 경우가 많아 파일명과 실제 이름이 다르다.
4. 로컬 파일로도 확인할 수 있다 (이미 다운로드했다면):
   ```bash
   security cms -D -i /path/to/profile.mobileprovision | \
     /usr/libexec/PlistBuddy -c "Print :Name" /dev/stdin
   ```
5. **다운로드(Download)** → `.mobileprovision` 파일을 받는다. 이 파일을
   base64 인코딩해 `IOS_PROVISIONING_PROFILE_BASE64`에 쓴다 (1절 참고).

> 앱이 사용하는 Capability(예: Push Notification, In-App Purchase 등)가
> 있다면, 이 프로파일이 해당 Capability를 포함하는 App ID로 만들어졌는지
> 확인한다. 이 프로젝트는 현재 특수 Capability를 쓰지 않는 것으로
> 보이지만, 광고 SDK(`google_mobile_ads`, `app_tracking_transparency`)가
> 추후 App Tracking Transparency 관련 entitlement를 요구하게 되면 App ID
> 설정을 다시 확인해야 한다.

---

## 5. Team ID 찾는 법

아래 아무 방법이나:

- App Store Connect → **사용자 및 액세스** 페이지 우측 상단에 표시.
- Apple Developer 웹사이트 → **Membership** (또는 **Account**) 페이지 →
  **Team ID** 필드.
- Xcode → `Runner.xcworkspace` 열기 → 프로젝트 네비게이터에서 `Runner`
  타겟 선택 → **Signing & Capabilities** 탭 → Team 드롭다운 옆에 괄호로
  표시.
- 이미 다운로드한 프로비저닝 프로파일에서도 확인 가능:
  ```bash
  security cms -D -i /path/to/profile.mobileprovision | \
    /usr/libexec/PlistBuddy -c "Print :TeamIdentifier:0" /dev/stdin
  ```

10자리 영숫자 문자열이다 (예: `AB12CD34EF`). 이 값이 `APPSTORE_TEAM_ID`다.

---

## 6. (선택, 강력 권장) 배포 게이트 설정

워크플로의 `release` 잡은 `environment: testflight-release`를 참조한다.
저장소 Settings → **Environments → New environment**에서
`testflight-release`라는 이름의 환경을 만들고 **Required reviewers**를
설정하면, 워크플로가 서명·업로드를 시작하기 직전 지정된 사람의 승인을
받아야 진행된다. `release-android.yml`의 `play-release` 환경과 같은
목적이다. 설정하지 않아도 워크플로 자체는 동작한다 (GitHub가 이름만으로
환경을 자동 생성함).

---

## 7. 워크플로 실행 방법

### 방법 A — 태그 푸시

```bash
git tag v1.1.0
git push origin v1.1.0
```

### 방법 B — 수동 실행 (`workflow_dispatch`)

```bash
gh workflow run release-ios.yml
gh run watch
```

GitHub 웹 UI에서도 Actions → Release iOS → **Run workflow**로 실행할 수
있다.

### 실행 후 기대되는 흐름

1. macOS 러너에서 임시 키체인 생성 → 인증서 import → 프로파일 설치 →
   `ExportOptions.plist` 생성 → `flutter build ipa` (Xcode 아카이브 +
   export) → IPA 파일 탐색 → TestFlight 업로드 → 시크릿 정리. 전체 5~15분
   내외 예상 (Xcode 아카이브 단계가 가장 오래 걸림).
2. 워크플로 자체가 성공(초록색)해도, **App Store Connect의 TestFlight
   탭에 빌드가 나타나기까지 추가로 10~30분** 걸린다 (Apple 서버 측
   처리 — "Processing" 상태). 이 시간 동안 빌드는 보이지 않거나
   "Processing"으로만 표시된다.
3. 처리가 끝나면 App Store Connect → 앱 선택 → **TestFlight** 탭에서
   빌드 번호(`versionCode`에 해당하는 `CFBundleVersion`, 현재
   `1.1.0+6`이라면 빌드 번호 `6`)를 확인한다.
4. 내부 테스트 그룹에 배정하지 않으면 아무도 자동으로 받지 못한다 —
   TestFlight 탭에서 테스터 그룹에 빌드를 수동으로 추가해야 한다 (이
   워크플로가 자동화하지 않는 부분).

---

## 8. 문제 해결

### "No profiles for 'com.nowaa.intervalpractice' were found" / export 단계 실패

`IOS_PROVISIONING_PROFILE_NAME`이 실제 프로파일 이름과 정확히 일치하지
않을 때 발생한다. 대소문자, 공백, 특수문자까지 정확히 일치해야 한다. 4절의
방법으로 실제 이름을 다시 확인하고 Secret을 갱신한다.

### "No codesigning identity found" (워크플로의 "Verify certificate was imported" 스텝에서 자체적으로 잡음)

`IOS_CERTIFICATE_BASE64`가 손상되었거나, `IOS_CERTIFICATE_PASSWORD`가
틀렸거나, 애초에 `.p12`를 내보낼 때 개인 키가 포함되지 않았을 가능성 (3절
Step 2 — 인증서 항목을 펼쳤을 때 개인 키가 없었다면 애초에 내보내기가
불완전했을 수 있다). `.p12`를 다시 내보내고 base64를 다시 인코딩한다.

### 인증서가 만료됨

Apple Developer → Certificates 페이지에서 상태가 "Expired"로 표시된다.
만료된 인증서로는 새로 서명할 수 없다 (이미 서명된 기존 빌드는 영향
없음). 새 **Apple Distribution** 인증서를 발급하고, **그 인증서로 다시
프로비저닝 프로파일도 재발급**해야 한다 (프로파일은 특정 인증서에
묶여 있다) — 그런 다음 `IOS_CERTIFICATE_BASE64`,
`IOS_CERTIFICATE_PASSWORD`, `IOS_PROVISIONING_PROFILE_BASE64`,
`IOS_PROVISIONING_PROFILE_NAME` 4개 Secret을 모두 갱신한다.

### "doesn't support the Associated Domains capability" 등 Capability 관련 실패

App ID의 Capability 설정과 프로비저닝 프로파일이 어긋날 때 발생한다.
Apple Developer → Identifiers → `com.nowaa.intervalpractice` 선택 →
필요한 Capability가 켜져 있는지 확인하고, 켰다면 프로파일을 **재생성**해야
반영된다 (기존 프로파일에는 소급 적용되지 않는다).

### 번들 ID 불일치 ("doesn't match the bundle identifier")

`ExportOptions.plist`의 `provisioningProfiles` 딕셔너리는
`com.nowaa.intervalpractice`로 하드코딩되어 있다 (워크플로의 "Generate
ExportOptions.plist" 스텝). 프로파일 자체가 다른 App ID로 만들어졌다면
이 에러가 난다 — 4절에서 App ID가 정확히 `com.nowaa.intervalpractice`인
프로파일을 골랐는지 다시 확인한다. 워크플로의 "Inspect provisioning
profile" 스텝이 `::warning::`으로 미리 알려주지만, 실패로 처리하지는
않으므로 로그를 직접 확인해야 한다.

### App Store Connect API 키 관련 401/403

- 401: `APPSTORE_KEY_ID` / `APPSTORE_ISSUER_ID` / `APPSTORE_PRIVATE_KEY`
  중 하나가 틀렸거나, 키가 App Store Connect에서 폐기(Revoke)된 상태.
- 403: 키의 역할이 App Manager 미만 (예: Developer, Marketing)이라
  업로드 권한이 없음. 2절 Step 4 참고 — App Manager로 재발급해야 한다
  (기존 키의 역할은 변경할 수 없다).

### TestFlight에 빌드가 영영 안 나타남

먼저 워크플로 로그의 "Upload to TestFlight" 스텝이 실제로 성공했는지
확인한다. 성공했다면 30분 이상 기다려본다. 그래도 없다면 App Store
Connect → 앱 → **활동(Activity)** 탭에서 업로드 자체가 기록되었는지,
반려(reject) 사유가 있는지 확인한다 (예: 잘못된 `Info.plist` 값, 아이콘
누락 등 — 이 프로젝트는 아직 확인되지 않았다).

---

## 부록 — Claude가 로컬에서 검증한 사항

- `flutter build ios --release --no-codesign`이 성공하며
  `build/ios/iphoneos/Runner.app`을 만든다 — **`intervalpractice.app`이
  아니라 `Runner.app`**이다.
- 이유: `ios/Runner.xcodeproj/project.pbxproj`의
  `PRODUCT_NAME = "$(TARGET_NAME)"`이고, 타겟 이름이 `Runner`
  (`name = Runner; productName = Runner;`)이기 때문. `flutter build ipa`가
  내부적으로 호출하는 `xcodebuild -exportArchive`도 IPA 파일명을 직접
  지정하지 않고 아카이브의 `PRODUCT_NAME`을 그대로 쓴다 — Flutter 자신의
  성공 메시지도 파일명을 확정하지 않고 `build/ios/ipa/*.ipa` 글롭으로
  안내한다 (`flutter_tools/lib/src/commands/build_ios.dart`).
- 따라서 워크플로는 `intervalpractice.ipa`나 `Runner.ipa`를 하드코딩하지
  않고, `find build/ios/ipa -maxdepth 1 -name '*.ipa'`로 런타임에 찾는다
  ("Locate exported IPA" 스텝). 이 방식은 파일명이 무엇이든 (설령 Apple이
  향후 관례를 바꾸더라도) 안전하다.
- `ios/ExportOptions.plist`를 생성하는 `PlistBuddy` 커맨드 시퀀스는 이
  저장소 밖 스크래치 디렉터리에서 실제로 실행해 `plutil -lint` 통과를
  확인했다 (공백이 포함된 프로파일 이름 케이스 포함).
- `.github/workflows/release-ios.yml`은 `ruby -ryaml -e
  "YAML.load_file(...)"`로 YAML 문법을, `actionlint`로 스크립트 정적
  분석을 통과했다 (`shellcheck` 경고 1건은 의도된 word-splitting이라
  인라인 `disable` 주석으로 처리).

## 부록 — 검증되지 않은 항목 (반드시 읽을 것)

Apple 서명 자산이 없어 **아래는 단 한 번도 실행해보지 못했다.** 워크플로가
"정상적으로 보인다"는 것과 "실제로 동작한다"는 것은 다르다.

- 임시 키체인 생성 → 인증서 import → `security set-key-partition-list`
  조합이 실제 `.p12`에 대해 동작하는지. (업계에서 널리 쓰이는 표준
  패턴이지만, 이 프로젝트의 실제 인증서로 테스트되지 않았다.)
- `security cms -D -i`로 디코딩한 프로비저닝 프로파일 plist의
  `Entitlements:application-identifier`, `TeamIdentifier:0` 경로가 실제
  Apple이 발급한 프로파일 구조와 정확히 일치하는지. (일반적으로 알려진
  구조를 근거로 작성했으나, 실제 파일로 확인하지 못했다 — 그래서 이
  스텝은 실패가 아니라 `::warning::`으로만 처리하도록 의도적으로 약하게
  만들었다.)
- `apple-actions/upload-testflight-build@v4`의 입력 파라미터명
  (`app-path`, `issuer-id`, `api-key-id`, `api-private-key`)이 최신
  버전과 정확히 일치하는지. (2026-08 기준 해당 액션의 GitHub 페이지에서
  확인했으나, 실제 실행으로 검증하지 못했다.)
- `flutter build ipa`가 서명이 유효한 상태에서 실제로 성공하는지, export
  단계가 `ExportOptions.plist`의 `signingStyle: manual` +
  `provisioningProfiles` 조합을 받아들이는지.
- TestFlight 업로드가 실제로 성공하고 App Store Connect에 빌드가
  나타나는지, 처리 시간이 실제로 10~30분 내외인지 (Apple 공식 안내치를
  인용한 것으로, 이 프로젝트의 실제 업로드로 측정하지 않았다).

**이 문서의 8개 Secret을 모두 등록한 뒤, 반드시 `workflow_dispatch`로 먼저
한 번 수동 실행해 전체 흐름을 확인할 것.** 실패하면 위 "문제 해결" 절과
워크플로 로그를 함께 보고 원인을 좁혀나간다.
