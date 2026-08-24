# Android 릴리즈 배포 설정 가이드

`.github/workflows/release-android.yml`이 Google Play에 AAB를 업로드하려면
GitHub Secrets 5개가 필요하다. 이 문서는 각 Secret을 만들고 등록하는 방법,
서비스 계정 설정, 워크플로 실행 방법, 첫 실행 후 확인할 항목을 정리한다.

**이 워크플로는 사용자가 직접 Secrets를 등록해야 동작한다.** Claude는 시크릿
파일 내용을 읽거나 출력하지 않으며, GitHub Secrets 등록도 대신 해 주지 않는다.

---

## 0. 사전 준비물

- `android/app/key.jks` — 기존 업로드 키 키스토어 (이미 저장소에 존재)
- `android/app/key.properties` — 로컬 서명 설정 (이미 저장소에 존재, git에는
  커밋되지 않음)
- Play Console에 대한 관리자 권한 (서비스 계정을 만들고 권한을 부여하려면 필요)
- Google Cloud Console 프로젝트에 대한 접근 권한

---

## 1. GitHub Secrets 등록

저장소 → **Settings → Secrets and variables → Actions → New repository
secret**에서 아래 5개를 등록한다.

### `ANDROID_KEYSTORE_BASE64`

키스토어 파일(`key.jks`)을 base64로 인코딩한 문자열 전체.

```bash
base64 -i android/app/key.jks | pbcopy
```

출력이 매우 길다 (수 KB). 터미널에 출력하지 말고 바로 클립보드로 보낸 뒤,
GitHub Secret 값 입력란에 붙여넣는다. `pbcopy`는 macOS 전용이며, 다른 OS에서는
`base64 -i android/app/key.jks | xclip -selection clipboard` (Linux) 등으로
대체한다.

### `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `ANDROID_STORE_PASSWORD`

`android/app/key.properties`는 4줄짜리 파일로, 각 줄이 아래처럼 GitHub Secret
하나에 대응한다:

| `key.properties`의 필드 | 대응하는 GitHub Secret |
|---|---|
| `storePassword=...` | `ANDROID_STORE_PASSWORD` |
| `keyPassword=...` | `ANDROID_KEY_PASSWORD` |
| `keyAlias=...` | `ANDROID_KEY_ALIAS` |
| `storeFile=./key.jks` | (Secret 아님 — 워크플로가 base64 복원 후 항상 이 경로에 씀) |

로컬에서 값을 확인하려면:

```bash
cat android/app/key.properties
```

터미널에만 출력하고, 캡처/커밋/공유하지 않는다. 각 줄의 `=` 뒤 값을 그대로
해당 GitHub Secret에 붙여넣으면 된다.

### `PLAY_SERVICE_ACCOUNT_JSON`

Play Console API를 호출할 서비스 계정의 JSON 키 **전체 내용**. 발급 방법은
아래 2절 참고.

---

## 2. Play Console 서비스 계정 만들기

1. **Google Cloud Console**에서 Play Console과 연결된 프로젝트를 연다
   (Play Console → 설정 → API 액세스에서 연결된 프로젝트를 확인/생성할 수
   있다).
2. Cloud Console → IAM 및 관리자 → 서비스 계정 → **서비스 계정 만들기**.
   이름은 예: `play-release-ci`.
3. 역할은 부여하지 않고 넘어가도 된다 (Play Console 쪽에서 권한을 준다).
4. 생성된 서비스 계정 → **키** 탭 → **키 추가 → 새 키 만들기 → JSON** →
   다운로드. 이 JSON 파일 내용이 `PLAY_SERVICE_ACCOUNT_JSON` 값이다.
5. **Play Console** → 설정 → API 액세스로 이동하면 방금 만든 서비스 계정이
   목록에 나타난다 (반영까지 몇 분 걸릴 수 있음). 계정 옆 **액세스 권한 관리**
   클릭.
6. 권한 부여:
   - **릴리스** → 앱을 프로덕션, 베타, 알파 트랙에 릴리스 → 허용 (최소
     internal 트랙 배포만 할 계획이어도, "릴리스 관리" 권한이 있어야
     `upload-google-play` 액션이 트랙에 업로드할 수 있다)
   - 앱 접근 권한에서 `com.nowaa.intervalpractice` 앱을 선택 (계정 단위가
     아니라 앱 단위로 권한을 준다)
7. 저장 후, 위 5단계에서 받은 JSON 파일의 **전체 내용**을 복사해
   `PLAY_SERVICE_ACCOUNT_JSON` Secret에 붙여넣는다. 로컬에 남은 JSON 키
   파일은 안전한 곳에 보관하거나 삭제한다 (커밋 금지).

> 이미 Play Console에 게시된 앱이라는 전제 하의 절차다. 완전히 새 앱은 API로
> 첫 릴리스를 만들 수 없고 최소 1회 콘솔에서 수동 업로드가 필요하지만, 이
> 프로젝트는 이미 라이브 상태이므로 해당 없음.

---

## 3. (선택, 강력 권장) 배포 게이트 설정

워크플로의 `release` 잡은 `environment: play-release`를 참조한다. 저장소
Settings → **Environments → New environment**에서 `play-release`라는 이름의
환경을 만들고 **Required reviewers**를 설정하면, 워크플로가 Play Console에
업로드하기 직전 지정된 사람의 승인을 받아야 진행된다. 설정하지 않아도 워크플로
자체는 정상 동작하지만(GitHub가 이름만으로 환경을 자동 생성함), 실수로 태그를
잘못 눌렀을 때의 마지막 안전장치이므로 설정을 권장한다.

---

## 4. 워크플로 실행 방법

### 방법 A — 태그 푸시 (프로덕션 릴리스용)

```bash
git tag v1.1.0
git push origin v1.1.0
```

`v*` 패턴의 태그가 푸시되면 자동 실행되며, 이 경우 트랙은 항상 **internal**로
고정된다 (`inputs.track`은 `workflow_dispatch`에서만 채워지므로, 태그 푸시
시에는 `inputs.track || 'internal'`이 `internal`로 떨어진다). 다른 트랙으로
직접 배포하려면 태그 푸시가 아니라 아래 방법 B를 쓴다.

### 방법 B — 수동 실행 (`workflow_dispatch`)

```bash
gh workflow run release-android.yml -f track=internal
# 또는 track=alpha / beta / production
gh run watch
```

GitHub 웹 UI에서도 Actions → Release Android → **Run workflow**로 트랙을
선택해 실행할 수 있다.

### 권장 순서

처음에는 반드시 `internal` 트랙으로 실행해 워크플로와 서명이 정상인지 확인한
뒤, 문제 없으면 이후 태그로 `production`까지 승격한다. `production` 트랙
업로드는 Play Console에서 별도 검토를 거칠 수 있다.

---

## 5. 첫 실행 후 확인할 것

1. **워크플로 로그 — "Verify AAB is signed with the correct upload key" 스텝**이
   초록색인지 확인한다. 이 스텝이 실패하면 워크플로가 **Play 업로드 전에
   중단된다** — 절대로 이 스텝을 우회하거나 삭제해서 다시 돌리지 말고, 왜
   서명이 달라졌는지부터 확인한다 (예: 잘못된 `ANDROID_KEYSTORE_BASE64`를
   등록했거나, 다른 키스토어 파일을 base64 인코딩했을 가능성).
2. **Play Console → 설정 → 앱 무결성 → 앱 서명 → 업로드 키 인증서**에서 표시된
   SHA-1 지문이 아래 값과 일치하는지 **사용자가 직접** 대조한다. Claude가 로컬
   키스토어에서 재확인한 값과 워크플로가 실제로 업로드에 사용한 AAB에서
   추출한 값은 아래와 같다 (2026-08-04 기준):

   ```
   SHA-1: E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93
   ```

   이 대조는 Claude가 대신할 수 없다 — Play Console의 해당 페이지는 계정
   소유자만 볼 수 있다.
3. **Play Console → 테스트 → 내부 테스트** (또는 선택한 트랙)에 새 버전
   (`versionCode`/`versionName`)이 나타났는지 확인한다.
4. Play Console → 게시 개요에서 경고/거부 사유가 없는지 확인한다.
5. 워크플로 로그에 시크릿 원문이 노출되지 않았는지 훑어본다 (GitHub가 등록된
   Secret 문자열을 자동으로 마스킹하지만, 실행 후 한 번은 육안으로 확인하는
   것이 안전하다).

---

## 부록 — 이 프로젝트에서 검증된 사항 (참고용, Claude가 로컬에서 확인)

- `flutter build appbundle --release` 정상 빌드 확인됨
  (`build/app/outputs/bundle/release/app-release.aab`).
- 업로드 키 별칭: `key_intervalpractice`.
- 인증서 소유자(DN): `CN=seohwalee, OU=nowaa, O=nowaa, L=seoul, ST=korea, C=kr`
  (공개 정보 — 인증서 자체에 포함되어 있어 누구나 조회 가능).
- 워크플로의 서명 검증 스텝은 `jarsigner`로 AAB의 JAR 서명을 검증하고,
  `keytool -printcert -jarfile`로 **빌드된 AAB에서 직접** 인증서를 추출해
  위 SHA-1 값과 비교한다. `apksigner`는 `.aab`를 검증할 수 없고(APK 전용),
  AGP의 v2-scheme 전용 APK 서명은 `jarsigner`로 읽을 수 없으므로 이 조합을
  택했다.
