# 음정박사(intervalpractice) 부활 및 리팩토링 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 2년간 방치되어 안드로이드 빌드조차 실패하는 Flutter 음정 학습 앱을, 최신 툴체인 위에서 빌드·테스트·배포되는 상태로 되살리고, 6개로 복붙된 문제 화면을 단일 파라미터 기반 엔진으로 통합한 뒤, GitHub Actions CI/CD로 양대 스토어에 재출시한다.

**Architecture:** 순수 Dart 도메인 계층(`lib/domain/`)을 Flutter UI에서 완전히 분리하여 음정 계산·문제 생성·채점·해설을 테스트 가능하게 만든다. 그 위에 `난이도(easy|hard) × 문제유형(1|2|3)` 두 파라미터만 받는 단일 `QuizPage`를 두어 기존 6개 화면(약 4,800줄)을 대체한다. 색상·스타일은 하드코딩된 전역 변수 대신 Material 3 `ColorScheme` 기반 테마로 이관하고 다크모드를 지원한다.

**Tech Stack:** Flutter 3.44.2 / Dart 3.12.2, music_notes 0.26, google_mobile_ads 9.0, provider 6.1, flutter_screenutil 5.9, GitHub Actions, Gradle 8.x + AGP 8.x

---

## 사전 조사 결과 (이 계획의 근거)

이 계획은 아래 **실측 결과**를 근거로 작성되었다. 구현자는 이 사실들을 재확인할 필요 없다.

| 항목 | 실측값 |
|---|---|
| `flutter analyze` | 에러 0, warning 20, info 12 — Dart 로직은 살아있음 |
| `flutter build apk --debug` | **실패**: `app_plugin_loader` imperative apply 불가 |
| 현재 Gradle / AGP / Kotlin | 7.5 / 7.3.0 / 1.7.10 (모두 Flutter 3.44와 비호환) |
| 현재 compileSdk / targetSdk / minSdk | 34 / 34 / 21 |
| `google_mobile_ads` 9.0.0 요구사항 | **iOS 13.0+, Android minSdk 24, compileSdk 36** |
| Flutter 3.44 iOS 템플릿 기본값 | `platform :ios, '13.0'` |
| 현재 iOS Podfile | `platform :ios, '12.0'` |
| `music_notes` 0.13 → 0.26 | **파괴적 변경 4건** (아래 표) |
| 코드에서 실제 사용되지 않는 의존성 | `firebase_core`, `firebase_analytics`, `flutter_riverpod`, `avatar_glow`, `just_the_tooltip` |
| 저장소 내 Firebase 설정 파일 | **없음** (`google-services.json`, `GoogleService-Info.plist` 모두 부재) |
| `test/widget_test.dart` | 기본 카운터 템플릿 — 현재 앱에서 **실패**함 |
| 서명 키 | `android/app/key.jks` 배치 완료, 정상 개봉 확인 (SHA1 `E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93`) |

### music_notes 0.13 → 0.26 파괴적 변경 (전 코드베이스 영향)

| 0.13 (현재) | 0.26 (목표) | 영향 |
|---|---|---|
| `PositionedNote` | `Pitch` | `problemVarList.dart`, `problemFunc.dart`, 6개 화면 전부 |
| `interval.toString()` → `"M3"` | `interval.format()` → `"M3"` | **정답 판정 전체** — `getResultAllEasy/Hard` |
| `note.baseNote` | `note.noteName` | `commentaryKeyReturn` |
| `interval.inverted` | `interval.inversion` | type3(자리바꿈) 문제 |

`Pitch`는 `Comparable<Pitch>`를 구현하므로 기존 `.sort()` 호출은 **그대로 동작한다**.

### 애플 배포 자산 미비 (Phase 5 착수 전 사용자 확인 필요)

사용자가 제공한 `keyfiles/`에는 **안드로이드 자산만** 있었다 (`key.jks`, `key.properties`, `local.properties`, `proguard-rules.pro`). iOS 자동 배포에 필요한 아래 자산은 **아직 없다**:

- App Store Connect API Key (`.p8`) + Key ID + Issuer ID
- 배포용 인증서(`.p12`) + 프로비저닝 프로파일(`.mobileprovision`)

Task 24(iOS 배포 워크플로) 착수 전에 사용자에게 요청해야 한다. Phase 5의 나머지(Task 22, 23)는 이 자산 없이 진행 가능하다.

---

## 파일 구조 (목표)

리팩토링 완료 시점의 `lib/` 구조. 각 파일은 하나의 책임만 갖는다.

```
lib/
  main.dart                          # 부트스트랩만 (약 25줄)
  app.dart                           # MaterialApp + 테마 + Provider 배선
  theme/
    app_theme.dart                   # M3 ColorScheme (light/dark) + 텍스트/버튼 스타일
  domain/                            # 순수 Dart — flutter/material import 금지
    problem_mode.dart                # Difficulty, QuestionType, ProblemMode
    korean_interval.dart             # Interval <-> 한글 음정명 ("장3도")
    staff_layout.dart                # Pitch <-> 오선지 Y좌표 테이블
    accidental_picker.dart           # 임시표 무작위 배정 규칙
    problem.dart                     # IntervalProblem (문제 1개의 값 객체)
    problem_generator.dart           # 문제 생성 (Random 주입 가능)
    answer_checker.dart              # 채점
    commentary.dart                  # 해설 생성
    commentary_data.dart             # 해설 문구 상수 테이블
  state/
    quiz_session.dart                # 10문제 진행 + 오답노트 (ChangeNotifier)
    ad_counter.dart                  # 기존 providerCounter.dart 대체
  ads/
    ad_ids.dart                      # 광고 단위 ID
    ad_service.dart                  # 배너/전면 광고 단일 구현
    consent_service.dart             # UMP(GDPR) 동의 — 기존 initialization_helper
  ui/
    home/home_page.dart              # 기존 firstProblemTypeList.dart
    quiz/quiz_page.dart              # 통합 문제 화면 — 기존 6개 파일 대체
    quiz/staff_view.dart             # 오선지 + 음표 렌더링
    quiz/answer_pad.dart             # 정답 버튼 패드 (유형별 분기)
    quiz/result_sheet.dart           # 정답/오답 바텀시트
    quiz/progress_bar.dart
    result/result_page.dart
    settings/settings_page.dart
    common/banner_ad_slot.dart       # 배너 광고 위젯 (중복 5곳 통합)
    common/loading_page.dart

test/
  domain/                            # 순수 Dart 단위 테스트 (빠름, CI 필수)
  ui/                                # 위젯 테스트
```

**삭제 대상 파일** (총 약 6,000줄):
`easyProblemType1/2/3.dart`, `easyProblemType2BackUp.dart`, `easyProblemType3BackUp.dart`,
`hardProblemType1/2/3.dart`, `problemFunc.dart`, `problemFuncDeco.dart`, `problemVarList.dart`,
`colorList.dart`, `admobClass.dart`, `admobFunc.dart`, `iosIDFSSetting.dart`

---

## 실행 순서 원칙

**Phase 1과 Phase 2를 분리하는 이유:** `google_mobile_ads` 4.0.0은 최신 AGP에서 빌드되지 않으므로 툴체인 현대화와 함께 올려야 한다. 반면 `music_notes` 업그레이드는 정답 로직 전체를 건드리므로, **먼저 현재 동작을 특성화 테스트(characterization test)로 고정한 뒤**에 올려야 안전하다. 두 업그레이드는 서로 독립적이므로 분리한다.

각 Phase 종료 시점마다 앱은 **빌드되고 실행되는 상태**여야 한다.

---

# Phase 0 — 안전망 구축

## Task 1: 작업 브랜치 생성 및 기준선 커밋

**Files:**
- Modify: `.gitignore` (이미 서명 파일 무시 규칙 추가됨 — 커밋만 하면 됨)

- [ ] **Step 1: 브랜치 생성**

```bash
git checkout -b revival/2026-modernization
```

- [ ] **Step 2: 서명 파일이 무시되는지 검증**

```bash
git check-ignore -v android/app/key.jks android/app/key.properties android/local.properties
```

Expected: 세 줄 모두 `.gitignore:NN:...` 형태로 출력 (= 무시됨).
아무것도 출력되지 않으면 **중단하고** `.gitignore`를 고칠 것. 비밀 키가 커밋되면 되돌릴 수 없다.

- [ ] **Step 3: 추적 중인 파일에 비밀이 없는지 확인**

```bash
git ls-files | grep -E '\.jks$|\.keystore$|key\.properties$|\.p12$|\.p8$|\.mobileprovision$'
```

Expected: 출력 없음 (exit code 1).

- [ ] **Step 4: 커밋**

```bash
git add .gitignore
git commit -m "chore: ignore signing secrets and machine-local properties"
```

---

## Task 2: 데드코드 및 미사용 의존성 제거

백업 파일 2개(1,829줄)와 코드에서 전혀 호출되지 않는 패키지 5개를 제거한다. Firebase는 pubspec에만 존재하고 호출부가 0곳이며 설정 파일도 없으므로, 유지할 경우 빌드·심사 리스크만 남는다(사용자 결정: 제거).

**Files:**
- Delete: `lib/page/easyProblem/easyProblemType2BackUp.dart`
- Delete: `lib/page/easyProblem/easyProblemType3BackUp.dart`
- Delete: `lib/page/problemFunc/iosIDFSSetting.dart`
- Modify: `pubspec.yaml`

- [ ] **Step 1: 백업 파일이 어디서도 import되지 않는지 확인**

```bash
grep -rn "BackUp\|iosIDFSSetting" lib/ --include=*.dart | grep -v "^lib/page/easyProblem/easyProblemType[23]BackUp.dart:"
```

Expected: 출력 없음 (exit code 1). 출력이 있으면 해당 import를 먼저 제거할 것.

- [ ] **Step 2: 파일 삭제**

```bash
git rm lib/page/easyProblem/easyProblemType2BackUp.dart \
       lib/page/easyProblem/easyProblemType3BackUp.dart \
       lib/page/problemFunc/iosIDFSSetting.dart
```

- [ ] **Step 3: 미사용 의존성이 정말 미사용인지 재확인**

```bash
for p in firebase_core firebase_analytics riverpod avatar_glow just_the_tooltip; do
  echo "$p: $(grep -rl "$p" lib/ | wc -l | tr -d ' ') files"
done
```

Expected: 5개 모두 `0 files`.

- [ ] **Step 4: pubspec.yaml에서 해당 의존성 제거**

`pubspec.yaml`의 `dependencies:` 블록을 아래로 교체한다 (버전은 Phase 1에서 올리므로 지금은 그대로 둔다).

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.2
  auto_size_text: ^3.0.0
  flutter_screenutil: ^5.9.0
  music_notes: ^0.13.0
  percent_indicator: ^4.2.3
  lottie: ^2.6.0
  google_mobile_ads: ^4.0.0
  app_tracking_transparency: ^2.0.4
  provider: ^6.1.1
  async_preferences: ^0.8.0
```

- [ ] **Step 5: 의존성 재해결 및 정적 분석**

```bash
flutter pub get && flutter analyze
```

Expected: `error` 0건. warning/info는 이 단계에서 줄어들 수 있으나 남아 있어도 무방하다.

- [ ] **Step 6: 커밋**

```bash
git add -A
git commit -m "chore: remove dead backup files and unused dependencies

- delete easyProblemType2/3BackUp.dart (1829 lines, never imported)
- delete empty iosIDFSSetting.dart
- drop firebase_core/firebase_analytics (zero call sites, no config files)
- drop flutter_riverpod, avatar_glow, just_the_tooltip (zero call sites)"
```

---

## Task 3: 깨진 기본 위젯 테스트를 실제 스모크 테스트로 교체

현재 `test/widget_test.dart`는 존재하지 않는 카운터를 검증하며 실패한다. CI를 세우기 전에 `flutter test`가 초록색이어야 한다.

**Files:**
- Modify: `test/widget_test.dart`

- [ ] **Step 1: 현재 테스트가 실패하는 것을 확인**

```bash
flutter test
```

Expected: FAIL — `Expected: exactly one matching candidate / Actual: _TextFinder:<zero widgets with text "0">`

- [ ] **Step 2: 실제 앱 구조를 검증하는 테스트로 교체**

`test/widget_test.dart` 전체를 아래로 교체한다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/main.dart';

void main() {
  testWidgets('MyApp builds and shows a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
```

- [ ] **Step 3: 테스트 통과 확인**

```bash
flutter test
```

Expected: `All tests passed!`

> 참고: 이 테스트는 광고 플러그인을 초기화하지 않는 `MyApp` 위젯만 펌프하므로 플랫폼 채널 없이 통과한다. `pumpAndSettle()`은 로딩 애니메이션(lottie)이 무한 반복될 경우 타임아웃되므로 **쓰지 않는다**.

- [ ] **Step 4: 커밋**

```bash
git add test/widget_test.dart
git commit -m "test: replace stock counter test with real smoke test"
```

---

# Phase 1 — 빌드 복구 (Android / iOS 툴체인 + 의존성)

이 Phase가 끝나면 `flutter build apk --release`와 `flutter build ipa`가 성공해야 한다. **Dart 로직은 건드리지 않는다** (단, 신규 SDK API 변경 대응은 예외).

## Task 4: Gradle / AGP / Kotlin 현대화

현재 빌드 실패의 직접 원인. `app_plugin_loader.gradle`을 `apply from:`으로 부르는 방식이 폐기되어 선언적 `plugins {}` 블록으로 이관해야 한다.

**Files:**
- Modify: `android/settings.gradle`
- Modify: `android/build.gradle`
- Modify: `android/gradle/wrapper/gradle-wrapper.properties`
- Modify: `android/gradle.properties`

- [ ] **Step 1: 현재 실패를 재확인 (기준점 기록)**

```bash
flutter build apk --debug 2>&1 | tail -20
```

Expected: `FAILURE: Build failed` + `app_plugin_loader Gradle plugin imperatively ... not possible anymore`

- [ ] **Step 2: `android/settings.gradle`을 선언적 plugins 블록으로 교체**

파일 전체를 아래로 교체한다.

```groovy
pluginManagement {
    def flutterSdkPath = {
        def properties = new Properties()
        file("local.properties").withInputStream { properties.load(it) }
        def flutterSdkPath = properties.getProperty("flutter.sdk")
        assert flutterSdkPath != null, "flutter.sdk not set in local.properties"
        return flutterSdkPath
    }()

    includeBuild("${flutterSdkPath}/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id "dev.flutter.flutter-plugin-loader" version "1.0.0"
    id "com.android.application" version "8.7.3" apply false
    id "org.jetbrains.kotlin.android" version "2.1.0" apply false
}

include ":app"
```

- [ ] **Step 3: `android/build.gradle`에서 구 buildscript 제거**

파일 전체를 아래로 교체한다. AGP/Kotlin 버전 선언은 Step 2의 `settings.gradle`로 옮겨갔으므로 여기서는 제거한다.

```groovy
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = "../build"
subprojects {
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
```

- [ ] **Step 4: Gradle wrapper를 8.9로 올림**

`android/gradle/wrapper/gradle-wrapper.properties`의 `distributionUrl` 한 줄을 교체한다.

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.9-all.zip
```

- [ ] **Step 5: `android/gradle.properties`에 AndroidX/Jetifier 및 메모리 설정 확인**

파일 전체를 아래로 교체한다.

```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=false
android.nonTransitiveRClass=false
```

- [ ] **Step 6: 빌드 재시도 — 오류 메시지가 바뀌었는지 확인**

```bash
flutter build apk --debug 2>&1 | tail -25
```

Expected: `app_plugin_loader` 오류는 **사라진다**. 대신 `namespace`/`compileSdk`/Java 버전 관련 오류가 새로 나타난다 — 이는 Task 5에서 해결하므로 **정상 진행이다**.

- [ ] **Step 7: 커밋**

```bash
git add android/settings.gradle android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties android/gradle.properties
git commit -m "build(android): migrate to declarative plugins block, Gradle 8.9 / AGP 8.7 / Kotlin 2.1"
```

---

## Task 5: Android 앱 모듈 설정 현대화 (SDK 레벨 · Java 17 · namespace · 서명)

Google Play는 2026-08-31부터 신규 앱 및 업데이트에 **targetSdk 36**을 요구한다. 또한 현재 `namespace`가 `com.example.intervalpractice`로 실제 `applicationId`(`com.nowaa.intervalpractice`)와 불일치한다.

> **Task 4 실행 후 판명된 정정 3건** — 아래 Step 0에서 먼저 처리한다.
>
> 1. **AGP 8.7.3은 `compileSdk 36`을 지원하지 않는다.** AGP 8.7.3에 포함된 `com.android.SdkConstants.MAX_SUPPORTED_ANDROID_PLATFORM_VERSION`이 `35`로 하드코딩돼 있어, 36을 쓰면 "has not been tested with this version" 경고가 나온다. `compileSdk 36` 지원은 AGP 8.9부터다. → **AGP 8.11.1 / Gradle 8.14 / Kotlin 2.2.20**으로 올린다(Flutter 경고선도 함께 해소). Flutter 3.44.2의 자체 기본값은 Gradle 9.1.0 / AGP 9.0.1이지만, Gradle 9는 `rootProject.buildDir` 제거 등 별도 마이그레이션을 요구하므로 출시 일정을 고려해 8.x 계열에 머무른다.
> 2. **`android.nonTransitiveRClass=false`는 근거 없는 추가였다.** AGP 8의 기본값은 `true`이고, 이 앱은 의존성의 `R` 클래스를 통해 리소스에 접근하는 코드가 없다. → 삭제한다.
> 3. **Flutter 툴이 매 빌드마다 `android.newDsl=false`와 `android.builtInKotlin=false`를 `gradle.properties`에 자동 추가한다.** Task 4에서는 이를 계속 되돌렸으나, 이는 Flutter 자체 템플릿에도 들어있는 값이므로 툴과 싸우지 말고 **명시적으로 포함**한다.
>
> 그리고 **빌드를 막고 있는 진짜 원인**: `async_preferences 0.8.0`이 자기 `android/build.gradle`에 `namespace`를 선언하지 않아 AGP 8에서 구성 단계가 실패한다. 이 앱의 다른 의존성은 모두 정상이다(확인 완료). `async_preferences 2.0.0`은 `namespace com.svprdga.async_preferences`를 선언하고, 이 앱이 쓰는 유일한 API인 `getInt(String id, {String? file}) → Future<int?>`의 시그니처가 0.8.0과 **동일**하므로 호출부 수정이 필요 없다. → Step 0에서 함께 올린다.

**Files:**
- Modify: `android/settings.gradle` (AGP/Kotlin 버전)
- Modify: `android/gradle/wrapper/gradle-wrapper.properties` (Gradle 버전)
- Modify: `android/gradle.properties` (플래그 정정)
- Modify: `pubspec.yaml` (`async_preferences`만)
- Modify: `android/app/build.gradle`

- [ ] **Step 0: 툴체인 버전 정정 및 빌드 차단 의존성 해소**

`android/settings.gradle`의 plugins 블록 두 줄을 교체:

```groovy
    id "com.android.application" version "8.11.1" apply false
    id "org.jetbrains.kotlin.android" version "2.2.20" apply false
```

`android/gradle/wrapper/gradle-wrapper.properties`의 `distributionUrl`:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
```

`android/gradle.properties` 전체:

```properties
org.gradle.jvmargs=-Xmx4G -XX:MaxMetaspaceSize=2G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=false
android.newDsl=false
android.builtInKotlin=false
```

`pubspec.yaml`에서 `async_preferences`만 상향(나머지 의존성은 Task 7에서 처리):

```yaml
  async_preferences: ^2.0.0
```

```bash
flutter pub get && flutter analyze 2>&1 | tail -3
```

Expected: error 0건. `getInt` 시그니처가 동일하므로 `lib/page/firstProblemTypeList.dart:146`과 `lib/page/settingPage/settingPage.dart:27`의 호출부는 수정 불필요하다.

- [ ] **Step 1: `android/app/build.gradle` 전체 교체**

`minSdk`는 `google_mobile_ads` 9.0.0 요구사항에 맞춰 21 → 24로 올린다.
서명 설정은 **`key.properties`가 없어도 빌드가 죽지 않도록** debug 서명으로 폴백시킨다 — 이는 CI에서 PR 검증 빌드를 돌릴 때 필수다.

```groovy
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader("UTF-8") { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
def flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file("app/key.properties")
def hasSigningConfig = keystorePropertiesFile.exists()
if (hasSigningConfig) {
    keystorePropertiesFile.withInputStream { keystoreProperties.load(it) }
}

android {
    namespace "com.nowaa.intervalpractice"
    compileSdk 36
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId "com.nowaa.intervalpractice"
        minSdk 24
        targetSdk 36
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    signingConfigs {
        if (hasSigningConfig) {
            release {
                keyAlias keystoreProperties["keyAlias"]
                keyPassword keystoreProperties["keyPassword"]
                storeFile file(keystoreProperties["storeFile"])
                storePassword keystoreProperties["storePassword"]
            }
        }
    }

    buildTypes {
        release {
            // key.properties가 없으면(예: PR 검증 빌드) debug 키로 폴백한다.
            signingConfig hasSigningConfig
                ? signingConfigs.release
                : signingConfigs.debug

            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro"
        }
    }
}

flutter {
    source "../.."
}
```

> `sourceSets { main.java.srcDirs += 'src/main/kotlin' }`는 AGP 8 + Kotlin 플러그인이 자동 처리하므로 제거했다.

- [ ] **Step 2: `MainActivity`의 패키지 경로가 새 namespace와 맞는지 확인**

```bash
find android/app/src/main -name "MainActivity.kt" -o -name "MainActivity.java" | xargs head -1
```

Expected: `package com.nowaa.intervalpractice` 또는 `com.example.intervalpractice`.
`com.example...`이면 파일 내 `package` 선언과 디렉터리 경로를 `com/nowaa/intervalpractice`로 옮긴다. `AndroidManifest.xml`의 `android:name=".MainActivity"`는 상대 경로이므로 수정 불필요하다.

- [ ] **Step 3: 빌드가 "다른 곳"에서 실패하는지 확인 (성공은 여기서 불가능)**

```bash
flutter build apk --debug 2>&1 | tail -25
```

> **실행 결과 판명된 순서 오류.** 이 태스크에서는 빌드 성공이 **원리적으로 불가능**하다. `google_mobile_ads 4.0.0`이 `webview_flutter_android 3.13.2`를 끌어오는데, 이 패키지가 Flutter가 제거한 **v1 embedding**(`PluginRegistry.Registrar`)을 참조한다. Gradle/AGP를 어떻게 설정하든 이 지점에서 컴파일이 깨진다. `google_mobile_ads`는 4.0.0이 4.x의 마지막이라 9.0.0으로의 메이저 상향(Task 7)만이 해결책이다.
>
> 따라서 **Step 4(릴리즈 빌드)와 서명 검증은 Task 7로 이관한다.** 이 태스크의 성공 기준은 다음으로 대체한다:
>
> Expected: 실패 지점이 `async_preferences` namespace 오류에서 **`webview_flutter_android:compileDebugJavaWithJavac`의 `cannot find symbol: PluginRegistry.Registrar`로 바뀐다.** 이 변화 자체가 Step 0(d)가 제대로 동작했다는 증거다.

- [ ] **Step 3-b: 정적 검증**

```bash
flutter analyze 2>&1 | tail -3 && flutter test
```

Expected: error 0건, 테스트 통과.

- [ ] **Step 4: (Task 7로 이관됨 — 여기서 수행하지 않는다)**

릴리즈 빌드와 서명 지문 검증은 의존성 상향 이후에만 가능하므로 Task 7 Step 5-b로 옮겼다.

- [ ] **Step 5: 커밋**

```bash
git add android/app/build.gradle android/app/src/main
git commit -m "build(android): target SDK 36, Java 17, fix namespace, safe signing fallback

- namespace com.example.* -> com.nowaa.intervalpractice (matches applicationId)
- compileSdk/targetSdk 34 -> 36 (Play requirement from 2026-08-31)
- minSdk 21 -> 24 (google_mobile_ads 9.x requirement)
- release build falls back to debug signing when key.properties is absent (CI)"
```

---

## Task 6: iOS 최소 버전 상향 및 개인정보 매니페스트 추가

Apple은 2024-05부터 `PrivacyInfo.xcprivacy`(개인정보 매니페스트)를 요구한다. 현재 저장소에 없다.

**Files:**
- Modify: `ios/Podfile`
- Create: `ios/Runner/PrivacyInfo.xcprivacy`

- [ ] **Step 1: Podfile 최소 버전 상향**

`ios/Podfile` 첫 줄을 교체한다.

```ruby
platform :ios, '13.0'
```

- [ ] **Step 2: Xcode 프로젝트의 배포 타겟도 함께 상향**

```bash
sed -i '' 's/IPHONEOS_DEPLOYMENT_TARGET = 1[12]\.0;/IPHONEOS_DEPLOYMENT_TARGET = 13.0;/g' \
  ios/Runner.xcodeproj/project.pbxproj
grep -c "IPHONEOS_DEPLOYMENT_TARGET = 13.0;" ios/Runner.xcodeproj/project.pbxproj
```

Expected: 3 이상 (Debug/Release/Profile 구성).

- [ ] **Step 3: 개인정보 매니페스트 생성**

`ios/Runner/PrivacyInfo.xcprivacy` 파일을 아래 내용으로 만든다.
이 앱은 AdMob 광고와 IDFA 추적을 사용하고, `async_preferences`가 `NSUserDefaults`를 사용한다.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSPrivacyTracking</key>
	<true/>
	<key>NSPrivacyTrackingDomains</key>
	<array>
		<string>googleads.g.doubleclick.net</string>
		<string>pagead2.googlesyndication.com</string>
	</array>
	<key>NSPrivacyCollectedDataTypes</key>
	<array>
		<dict>
			<key>NSPrivacyCollectedDataType</key>
			<string>NSPrivacyCollectedDataTypeDeviceID</string>
			<key>NSPrivacyCollectedDataTypeLinked</key>
			<true/>
			<key>NSPrivacyCollectedDataTypeTracking</key>
			<true/>
			<key>NSPrivacyCollectedDataTypePurposes</key>
			<array>
				<string>NSPrivacyCollectedDataTypePurposeThirdPartyAdvertising</string>
			</array>
		</dict>
	</array>
	<key>NSPrivacyAccessedAPITypes</key>
	<array>
		<dict>
			<key>NSPrivacyAccessedAPIType</key>
			<string>NSPrivacyAccessedAPICategoryUserDefaults</string>
			<key>NSPrivacyAccessedAPITypeReasons</key>
			<array>
				<string>CA92.1</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
```

- [ ] **Step 4: 매니페스트를 Xcode 타겟에 등록**

`PrivacyInfo.xcprivacy`는 프로젝트 파일에 등록되어야 번들에 포함된다. Xcode를 열어 `Runner` 타겟의 **Build Phases → Copy Bundle Resources**에 추가한다.

```bash
open ios/Runner.xcworkspace
```

등록 후 아래로 검증한다.

```bash
grep -c "PrivacyInfo.xcprivacy" ios/Runner.xcodeproj/project.pbxproj
```

Expected: 3 이상 (PBXBuildFile, PBXFileReference, PBXResourcesBuildPhase 참조).
`0`이면 Xcode에서 등록되지 않은 것이므로 다시 수행한다.

- [ ] **Step 5: 커밋**

```bash
git add ios/Podfile ios/Runner.xcodeproj/project.pbxproj ios/Runner/PrivacyInfo.xcprivacy
git commit -m "build(ios): raise deployment target to 13.0, add privacy manifest"
```

---

## Task 7: Dart 의존성 업그레이드 (music_notes 제외)

`music_notes`는 정답 로직 전체를 바꾸므로 **여기서 올리지 않는다** (Phase 2에서 테스트로 보호한 뒤 진행).

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: `pubspec.yaml`의 environment와 dependencies 교체**

```yaml
environment:
  sdk: '>=3.5.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.9
  auto_size_text: ^3.0.0
  flutter_screenutil: ^5.9.3
  music_notes: ^0.13.0        # Phase 2에서 0.26으로 올린다
  percent_indicator: ^4.2.5
  lottie: ^3.5.1
  google_mobile_ads: ^9.0.0
  app_tracking_transparency: ^2.0.7
  provider: ^6.1.5+1
  async_preferences: ^2.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

- [ ] **Step 2: 의존성 해결**

```bash
flutter pub get
```

Expected: `Changed N dependencies!` — 해결 실패 시 충돌 패키지를 확인하고 해당 제약만 완화한다.

- [ ] **Step 3: 정적 분석으로 파괴적 변경 지점 확인**

```bash
flutter analyze 2>&1 | grep -E "^\s*error" | head -30
```

`flutter_lints` 6.0은 규칙이 크게 늘어 info/warning이 급증하지만, **error만** 수정 대상이다.

예상되는 error 지점과 대응:

| 위치 | 원인 | 대응 |
|---|---|---|
| `lottie` 3.x | `Lottie.asset` 시그니처 | 대부분 호환. error 시 `lib/page/loadingPage.dart` 확인 |
| `async_preferences` 2.x | `AsyncPreferences()` API 변경 가능 | `lib/page/firstProblemTypeList.dart:146` `_isUnderGdpr()` 확인 |
| `google_mobile_ads` 9.x | UMP/Ad API 변경 가능 | `admobClass.dart`, `initialization_helper.dart` 확인 |

- [ ] **Step 4: error가 0이 될 때까지 수정**

각 error를 개별적으로 고친다. 수정 후 매번:

```bash
flutter analyze 2>&1 | tail -3
```

Expected: 최종적으로 error 0건.

- [ ] **Step 5: 테스트 및 양 플랫폼 빌드 검증**

```bash
flutter test
```

Expected: `All tests passed!`

```bash
flutter build apk --debug 2>&1 | tail -5
```

Expected: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

**이 태스크가 안드로이드 빌드를 처음으로 초록불로 만드는 지점이다.** Task 4가 `app_plugin_loader` 오류를, Task 5가 `async_preferences` namespace 오류를 걷어냈고, 여기서 `webview_flutter_android`의 v1 embedding 오류가 사라진다.

- [ ] **Step 5-b: 릴리즈 빌드 및 서명 지문 검증 (Task 5에서 이관)**

```bash
flutter build apk --release 2>&1 | tail -10
```

Expected: `✓ Built ... app-release.apk`

서명이 **실제 업로드 키**로 됐는지 확인한다. 기대 SHA1은 아래와 같다(키스토어에서 확인 완료):

```
E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93
```

```bash
$JAVA_HOME/bin/jarsigner -verify -verbose:summary build/app/outputs/flutter-apk/app-release.apk 2>&1 | tail -5
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk | grep SHA1
```

Expected: `jar verified.` 그리고 SHA1이 위 값과 일치.

**일치하지 않으면 중단하고 보고한다.** debug 키로 폴백된 것이라면 `android/app/key.properties`가 읽히지 않은 것이고, 그 상태로 Play에 올리면 거부된다.

- [x] **Step 5-c: 서명 폴백 경로 검증 — Task 5 실행 중 이미 완료됨**

> Task 5 구현자가 `./gradlew :app:signingReport`로 양쪽 분기를 실증했다. 결과:
> - `key.properties` 없음 → `BUILD SUCCESSFUL`, `Variant: release / Config: debug` (폴백 정상, `Could not find signingConfig 'release'` 발생하지 않음)
> - `key.properties` 있음 → `Config: release`, `Alias: key_intervalpractice`, `SHA1: E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93` — **기대값 일치**
>
> Groovy 삼항 연산자가 단락 평가되므로 `hasSigningConfig`가 false일 때 `signingConfigs.release`가 역참조되지 않는다. 구조적으로 안전함이 확인됐다.
>
> 아래 절차는 참고용으로 남긴다(릴리즈 APK 산출물 자체에 대한 재확인이 필요할 때).

`key.properties`가 없는 환경(= CI PR 빌드)에서도 릴리즈 빌드가 죽지 않아야 한다. 임시로 치워서 확인한다.

```bash
mv android/app/key.properties /tmp/key.properties.bak
flutter build apk --release 2>&1 | tail -5
mv /tmp/key.properties.bak android/app/key.properties
```

Expected: 빌드 성공(debug 서명으로 폴백). `Could not find signingConfig 'release'` 같은 구성 오류가 나면 `android/app/build.gradle`의 조건부 `signingConfigs` 블록을 고쳐야 한다.

**반드시 `key.properties`를 제자리로 되돌린 뒤** `ls android/app/key.properties`로 확인한다.

```bash
cd ios && pod install --repo-update && cd .. && flutter build ios --release --no-codesign 2>&1 | tail -5
```

Expected: `✓ Built ... Runner.app`

- [ ] **Step 6: 커밋**

```bash
git add pubspec.yaml pubspec.lock ios/Podfile.lock lib/
git commit -m "deps: upgrade to google_mobile_ads 9.x, lottie 3.x, flutter_lints 6.x

music_notes intentionally held at 0.13 — upgraded in Phase 2 under test coverage."
```

---

## Task 8: 린트 규칙 정리 및 기존 경고 해소

**Files:**
- Modify: `analysis_options.yaml`
- Modify: 경고가 발생한 `lib/` 파일들

- [ ] **Step 1: `analysis_options.yaml` 교체**

도메인 계층을 순수 Dart로 유지하기 위해 향후 규칙을 강화한다.

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    deprecated_member_use: warning
    unused_local_variable: warning
    unused_field: warning
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - unawaited_futures
```

- [ ] **Step 2: 미사용 변수/필드 제거**

`flutter analyze`가 지목하는 아래 항목을 삭제한다 (모두 사용되지 않는 지역변수·필드):

```bash
flutter analyze 2>&1 | grep -E "unused_local_variable|unused_field"
```

각 위치의 변수 선언을 삭제한다. 단, **우변에 부수효과가 있는 경우**(예: `final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();`)에는 변수만 제거하고 호출은 남긴다:

```dart
// lib/page/firstProblemTypeList.dart — 변수 제거, 호출은 유지
await AppTrackingTransparency.getAdvertisingIdentifier();
```

- [ ] **Step 3: deprecated API 교체**

`lib/main.dart:49` — `textScaleFactor` → `textScaler`:

```dart
builder: (context, child) {
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
    child: child!,
  );
},
```

`lib/page/problemFunc/resultPage.dart:73` — `withOpacity` → `withValues`:

```dart
// 변경 전: someColor.withOpacity(0.5)
// 변경 후:
someColor.withValues(alpha: 0.5)
```

`lib/page/problemFunc/problemFuncDeco.dart:179` — `Tooltip.height` → `Tooltip.constraints`:

```dart
constraints: const BoxConstraints(minHeight: 80),
```

- [ ] **Step 4: 분석 및 테스트 통과 확인**

```bash
flutter analyze && flutter test
```

Expected: `No issues found!` 그리고 `All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add -A
git commit -m "style: adopt flutter_lints 6 rules, remove unused vars, replace deprecated APIs"
```

---

# Phase 2 — 도메인 로직 추출 및 music_notes 마이그레이션

**전략:** 먼저 현재(0.13) 동작을 특성화 테스트로 고정한다. 그 다음 도메인 계층을 순수 Dart로 추출하고, 마지막에 music_notes를 0.26으로 올린다. 테스트가 초록색을 유지하면 마이그레이션이 안전했다는 증거가 된다.

## Task 9: 정답 계산의 특성화 테스트 작성 (music_notes 0.13 기준)

**Files:**
- Create: `test/characterization/answer_calculation_test.dart`

- [ ] **Step 1: 현재 동작을 고정하는 테스트 작성**

`getResultAllEasy`/`getResultAllHard`는 `[정렬된음들, 영문음정, 한글음정, 자리바꿈한글음정]`을 반환한다. 아래 테스트는 **현재 구현이 무엇을 내놓는지** 그대로 박제한다.

```dart
// 이 테스트는 music_notes 0.13 -> 0.26 마이그레이션의 안전망이다.
// 마이그레이션 전후로 동일하게 통과해야 한다.
import 'package:flutter_test/flutter_test.dart';
import 'package:music_notes/music_notes.dart';

import 'package:intervalpractice/page/problemFunc/problemFuncDeco.dart';

void main() {
  group('getResultAllEasy - 임시표 없는 음정', () {
    test('도(C4)와 미(E4)는 장3도', () {
      final result = getResultAllEasy(
        [Note.c.inOctave(4), Note.e.inOctave(4)],
        false,
      );

      expect(result[1], 'M3');
      expect(result[2], '장3');
    });

    test('도(C4)와 솔(G4)은 완전5도', () {
      final result = getResultAllEasy(
        [Note.c.inOctave(4), Note.g.inOctave(4)],
        false,
      );

      expect(result[1], 'P5');
      expect(result[2], '완전5');
    });

    test('미(E4)와 파(F4)는 단2도', () {
      final result = getResultAllEasy(
        [Note.e.inOctave(4), Note.f.inOctave(4)],
        false,
      );

      expect(result[1], 'm2');
      expect(result[2], '단2');
    });

    test('입력 순서가 뒤바뀌어도 같은 결과 (내부 정렬)', () {
      final forward = getResultAllEasy(
        [Note.c.inOctave(4), Note.g.inOctave(4)],
        false,
      );
      final backward = getResultAllEasy(
        [Note.g.inOctave(4), Note.c.inOctave(4)],
        false,
      );

      expect(backward[1], forward[1]);
      expect(backward[2], forward[2]);
    });

    test('inverseTF=true이면 자리바꿈 음정을 반환 (장3도 -> 단6도)', () {
      final result = getResultAllEasy(
        [Note.c.inOctave(4), Note.e.inOctave(4)],
        true,
      );

      expect(result[1], 'm6');
      expect(result[2], '단6');
    });
  });

  group('getResultAllHard - 임시표 포함 음정', () {
    test('도(C4)와 미플랫(E4)은 단3도', () {
      final result = getResultAllHard(
        [Note.c.inOctave(4), Note.e.inOctave(4)],
        ['none', 'flat'],
        false,
      );

      expect(result[1], 'm3');
      expect(result[2], '단3');
    });

    test('도샵(C4)과 미(E4)는 단3도', () {
      final result = getResultAllHard(
        [Note.c.inOctave(4), Note.e.inOctave(4)],
        ['sharp', 'none'],
        false,
      );

      expect(result[1], 'm3');
      expect(result[2], '단3');
    });

    test('도(C4)와 솔샵(G4)은 증5도', () {
      final result = getResultAllHard(
        [Note.c.inOctave(4), Note.g.inOctave(4)],
        ['none', 'sharp'],
        false,
      );

      expect(result[1], 'A5');
      expect(result[2], '증5');
    });

    test('겹내림표(double flat)도 처리한다', () {
      final result = getResultAllHard(
        [Note.c.inOctave(4), Note.e.inOctave(4)],
        ['none', 'double flat'],
        false,
      );

      expect(result[1], 'd3');
      expect(result[2], '감3');
    });
  });

  group('commentaryKeyReturn - 해설 생성', () {
    test('도-미 장3도 해설에 정답 이름이 포함된다', () {
      final sorted = [Note.c.inOctave(4), Note.e.inOctave(4)];
      final commentary = commentaryKeyReturn(sorted, '장3');

      expect(commentary, contains('장3도'));
      expect(commentary, contains('반음'));
    });

    test('임시표가 붙으면 해설에 해당 설명이 앞에 붙는다', () {
      final sorted = [Note.c.inOctave(4), Note.e.flat.inOctave(4)];
      final commentary = commentaryKeyReturn(sorted, '단3');

      expect(commentary, contains('플렛'));
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 — 현재 구현 기준으로 통과해야 함**

```bash
flutter test test/characterization/answer_calculation_test.dart
```

Expected: `All tests passed!`

**실패하는 케이스가 있다면** 기대값이 아니라 **실제 출력에 맞춰 기대값을 고친다.** 이 테스트의 목적은 "옳음"이 아니라 "현재 동작의 박제"다. 실제 출력을 확인하려면:

```bash
flutter test test/characterization/answer_calculation_test.dart --reporter expanded 2>&1 | grep -A3 "Expected:"
```

- [ ] **Step 3: 커밋**

```bash
git add test/characterization/answer_calculation_test.dart
git commit -m "test: characterize current answer calculation before music_notes upgrade"
```

---

## Task 10: 한글 음정 표기 도메인 모듈 추출

**Files:**
- Create: `lib/domain/korean_interval.dart`
- Create: `test/domain/korean_interval_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/domain/korean_interval_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:music_notes/music_notes.dart';

import 'package:intervalpractice/domain/korean_interval.dart';

void main() {
  group('KoreanInterval.fromInterval', () {
    test('장3도를 "장3"으로 표기한다', () {
      final name = KoreanInterval.fromInterval(Interval.M3);
      expect(name, '장3');
    });

    test('완전5도를 "완전5"로 표기한다', () {
      final name = KoreanInterval.fromInterval(Interval.P5);
      expect(name, '완전5');
    });

    test('감5도를 "감5"로 표기한다', () {
      final name = KoreanInterval.fromInterval(Interval.d5);
      expect(name, '감5');
    });
  });

  group('KoreanInterval.toAbbreviation', () {
    test('"장"+"3"을 "M3"으로 변환한다', () {
      expect(KoreanInterval.toAbbreviation('장', '3'), 'M3');
    });

    test('"겹증"+"4"를 "AA4"로 변환한다', () {
      expect(KoreanInterval.toAbbreviation('겹증', '4'), 'AA4');
    });

    test('"겹감"+"7"을 "dd7"로 변환한다', () {
      expect(KoreanInterval.toAbbreviation('겹감', '7'), 'dd7');
    });
  });
}
```

- [ ] **Step 2: 테스트가 실패하는지 확인**

```bash
flutter test test/domain/korean_interval_test.dart
```

Expected: FAIL — `Target of URI doesn't exist: 'package:intervalpractice/domain/korean_interval.dart'`

- [ ] **Step 3: 최소 구현 작성**

`lib/domain/korean_interval.dart`:

```dart
import 'package:music_notes/music_notes.dart';

/// 음정의 한글 표기와 영문 약칭(`M3`, `P5`, `dd7`) 사이를 변환한다.
///
/// 영문 약칭은 music_notes가 내보내는 형식과 동일하다:
/// 품질(d/dd/m/M/P/A/AA) + 도수(1~8).
abstract final class KoreanInterval {
  /// 한글 품질 이름 -> 영문 약칭.
  static const _koreanToAbbreviation = <String, String>{
    '감': 'd',
    '겹감': 'dd',
    '단': 'm',
    '장': 'M',
    '완전': 'P',
    '증': 'A',
    '겹증': 'AA',
  };

  /// 영문 약칭 -> 한글 품질 이름.
  static const _abbreviationToKorean = <String, String>{
    'd': '감',
    'dd': '겹감',
    'm': '단',
    'M': '장',
    'P': '완전',
    'A': '증',
    'AA': '겹증',
  };

  /// `Interval`을 `"장3"` 같은 한글 표기로 바꾼다. ("도"는 붙이지 않는다.)
  static String fromInterval(Interval interval) =>
      fromAbbreviation(intervalAbbreviation(interval));

  /// `"M3"` -> `"장3"`.
  ///
  /// 품질 부분은 1~2글자이므로 뒤에서부터 도수를 떼어낸다.
  static String fromAbbreviation(String abbreviation) {
    final digitIndex = abbreviation.indexOf(RegExp(r'\d'));
    if (digitIndex <= 0) {
      throw FormatException('Invalid interval abbreviation', abbreviation);
    }

    final quality = abbreviation.substring(0, digitIndex);
    final size = abbreviation.substring(digitIndex);

    final korean = _abbreviationToKorean[quality];
    if (korean == null) {
      throw FormatException('Unknown interval quality', abbreviation);
    }

    return '$korean$size';
  }

  /// `("장", "3")` -> `"M3"`.
  static String toAbbreviation(String koreanQuality, String size) {
    final abbreviation = _koreanToAbbreviation[koreanQuality];
    if (abbreviation == null) {
      throw FormatException('Unknown Korean quality', koreanQuality);
    }

    return '$abbreviation$size';
  }

  /// music_notes 버전 차이를 흡수하는 단일 지점.
  ///
  /// 0.13에서는 `toString()`이, 0.26 이후로는 `format()`이 `"M3"` 형태를 낸다.
  /// 마이그레이션 시 이 메서드 한 곳만 고치면 된다.
  static String intervalAbbreviation(Interval interval) => interval.toString();
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/domain/korean_interval_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add lib/domain/korean_interval.dart test/domain/korean_interval_test.dart
git commit -m "feat(domain): extract Korean interval notation with version-isolating seam"
```

---

## Task 11: 문제 모드 및 값 객체 정의

**Files:**
- Create: `lib/domain/problem_mode.dart`
- Create: `test/domain/problem_mode_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/domain/problem_mode_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem_mode.dart';

void main() {
  group('ProblemMode', () {
    test('easy 난이도는 임시표를 쓰지 않는다', () {
      const mode = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.nameTheInterval,
      );

      expect(mode.usesAccidentals, isFalse);
    });

    test('hard 난이도는 임시표를 쓴다', () {
      const mode = ProblemMode(
        difficulty: Difficulty.hard,
        questionType: QuestionType.nameTheInterval,
      );

      expect(mode.usesAccidentals, isTrue);
    });

    test('자리바꿈 유형만 inverted 정답을 요구한다', () {
      const inversion = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.invertedInterval,
      );
      const plain = ProblemMode(
        difficulty: Difficulty.easy,
        questionType: QuestionType.nameTheInterval,
      );

      expect(inversion.usesInvertedAnswer, isTrue);
      expect(plain.usesInvertedAnswer, isFalse);
    });

    test('6가지 조합이 모두 정의된다', () {
      expect(ProblemMode.all, hasLength(6));
      expect(ProblemMode.all.toSet(), hasLength(6));
    });

    test('appBar 제목은 난이도를 따른다', () {
      expect(
        const ProblemMode(
          difficulty: Difficulty.easy,
          questionType: QuestionType.nameTheInterval,
        ).title,
        'Easy',
      );
      expect(
        const ProblemMode(
          difficulty: Difficulty.hard,
          questionType: QuestionType.nameTheInterval,
        ).title,
        'Hard',
      );
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/domain/problem_mode_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: 구현 작성**

`lib/domain/problem_mode.dart`:

```dart
/// 난이도 — 임시표(#, b, ##, bb) 사용 여부를 결정한다.
enum Difficulty {
  /// 임시표 없는 기본 계이름만 출제한다.
  easy,

  /// 임시표를 무작위로 붙여 출제한다.
  hard;

  bool get usesAccidentals => this == Difficulty.hard;
}

/// 문제 유형 — 무엇을 묻는지 결정한다.
enum QuestionType {
  /// 유형 1: 악보의 두 음을 보고 음정 이름을 고른다.
  nameTheInterval,

  /// 유형 2: 한 음과 음정이 주어지고 나머지 계이름을 고른다.
  nameTheNote,

  /// 유형 3: 두 음의 자리바꿈 음정을 고른다.
  invertedInterval;

  bool get usesInvertedAnswer => this == QuestionType.invertedInterval;
}

/// 난이도 × 문제유형 조합. 기존 6개 화면 파일을 대체하는 파라미터.
final class ProblemMode {
  const ProblemMode({required this.difficulty, required this.questionType});

  final Difficulty difficulty;
  final QuestionType questionType;

  bool get usesAccidentals => difficulty.usesAccidentals;
  bool get usesInvertedAnswer => questionType.usesInvertedAnswer;

  /// AppBar에 표시할 제목.
  String get title => switch (difficulty) {
    Difficulty.easy => 'Easy',
    Difficulty.hard => 'Hard',
  };

  /// 홈 화면 목록에 표시할 문제 제목.
  String get listTitle => switch (questionType) {
    QuestionType.nameTheInterval => '음정 문제 1',
    QuestionType.nameTheNote => '음정 문제 2',
    QuestionType.invertedInterval => '음정 문제 3',
  };

  /// 홈 화면 목록에 표시할 설명 2줄.
  List<String> get listDescription => switch (questionType) {
    QuestionType.nameTheInterval => const ['악보 위의 음정을 계산하여', '정답을 맞춰보세요'],
    QuestionType.nameTheNote => const ['주어진 음정을 보고 알맞은', '계이름을 계산하여 맞춰보세요'],
    QuestionType.invertedInterval => const ['주어진 음정의 자리바꿈 음정을', '계산하여 정답을 맞춰보세요'],
  };

  /// 가능한 6가지 조합 전부.
  static const all = <ProblemMode>[
    ProblemMode(
      difficulty: Difficulty.easy,
      questionType: QuestionType.nameTheInterval,
    ),
    ProblemMode(
      difficulty: Difficulty.easy,
      questionType: QuestionType.nameTheNote,
    ),
    ProblemMode(
      difficulty: Difficulty.easy,
      questionType: QuestionType.invertedInterval,
    ),
    ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.nameTheInterval,
    ),
    ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.nameTheNote,
    ),
    ProblemMode(
      difficulty: Difficulty.hard,
      questionType: QuestionType.invertedInterval,
    ),
  ];

  /// 난이도별 목록 (홈 화면 탭에 사용).
  static List<ProblemMode> forDifficulty(Difficulty difficulty) =>
      all.where((mode) => mode.difficulty == difficulty).toList();

  @override
  bool operator ==(Object other) =>
      other is ProblemMode &&
      other.difficulty == difficulty &&
      other.questionType == questionType;

  @override
  int get hashCode => Object.hash(difficulty, questionType);

  @override
  String toString() => 'ProblemMode(${difficulty.name}, ${questionType.name})';
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/domain/problem_mode_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add lib/domain/problem_mode.dart test/domain/problem_mode_test.dart
git commit -m "feat(domain): define ProblemMode as difficulty x question type"
```

---

## Task 12: 오선지 좌표 테이블 추출 (중복 상수 제거)

현재 `note_height_list`와 `note_height_list_fix`는 **내용이 100% 동일한 중복 리스트**이며, `List<List<dynamic>>`이라 타입 안정성이 없다.

**Files:**
- Create: `lib/domain/staff_layout.dart`
- Create: `test/domain/staff_layout_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/domain/staff_layout_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:music_notes/music_notes.dart';

import 'package:intervalpractice/domain/staff_layout.dart';

void main() {
  group('StaffLayout', () {
    test('19개 음자리를 갖는다 (G3 ~ D6)', () {
      expect(StaffLayout.slots, hasLength(19));
    });

    test('맨 위 자리는 D6이고 top=11.0이다', () {
      final first = StaffLayout.slots.first;
      expect(first.index, 0);
      expect(first.top, 11.0);
      expect(first.pitch, Note.d.inOctave(6));
    });

    test('맨 아래 자리는 G3이고 top=249.5이다', () {
      final last = StaffLayout.slots.last;
      expect(last.index, 18);
      expect(last.top, 249.5);
      expect(last.pitch, Note.g.inOctave(3));
    });

    test('index는 0부터 순차 증가한다', () {
      for (var i = 0; i < StaffLayout.slots.length; i++) {
        expect(StaffLayout.slots[i].index, i);
      }
    });

    test('인접한 자리의 간격은 13.25로 일정하다', () {
      for (var i = 1; i < StaffLayout.slots.length; i++) {
        final gap = StaffLayout.slots[i].top - StaffLayout.slots[i - 1].top;
        expect(gap, closeTo(13.25, 0.001));
      }
    });

    test('byIndex로 자리를 되찾을 수 있다', () {
      expect(StaffLayout.byIndex(8).pitch, Note.c.inOctave(5));
    });

    test('한글 계이름을 반환한다', () {
      expect(StaffLayout.koreanNameOf(Note.c.inOctave(4)), '도');
      expect(StaffLayout.koreanNameOf(Note.g.inOctave(5)), '솔');
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/domain/staff_layout_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: 구현 작성**

`lib/domain/staff_layout.dart`:

```dart
import 'package:music_notes/music_notes.dart';

/// 오선지 위의 한 음자리. 화면 Y좌표와 음높이를 함께 갖는다.
final class StaffSlot {
  const StaffSlot({
    required this.top,
    required this.index,
    required this.pitch,
  });

  /// 오선지 컨테이너 기준 Y 오프셋 (설계 기준 375x844 기준값).
  final double top;

  /// 위에서부터 0번, 아래로 갈수록 증가. 오답노트 저장에 쓰인다.
  final int index;

  /// 이 자리에 해당하는 음높이.
  final Pitch pitch;

  @override
  String toString() => 'StaffSlot($index, $pitch, top: $top)';
}

/// 높은음자리표 오선지의 음자리 배치.
///
/// 기존 `note_height_list` / `note_height_list_fix` 두 개의 동일한
/// `List<List<dynamic>>`를 하나의 타입 안전한 테이블로 대체한다.
abstract final class StaffLayout {
  static const _topStart = 11.0;
  static const _gap = 13.25;

  /// 위(D6)에서 아래(G3)로 내려가는 순서.
  static final List<StaffSlot> slots = List.unmodifiable([
    for (var i = 0; i < _pitches.length; i++)
      StaffSlot(top: _topStart + _gap * i, index: i, pitch: _pitches[i]),
  ]);

  static final List<Pitch> _pitches = [
    Note.d.inOctave(6),
    Note.c.inOctave(6),
    Note.b.inOctave(5),
    Note.a.inOctave(5),
    Note.g.inOctave(5),
    Note.f.inOctave(5),
    Note.e.inOctave(5),
    Note.d.inOctave(5),
    Note.c.inOctave(5),
    Note.b.inOctave(4),
    Note.a.inOctave(4),
    Note.g.inOctave(4),
    Note.f.inOctave(4),
    Note.e.inOctave(4),
    Note.d.inOctave(4),
    Note.c.inOctave(4),
    Note.b.inOctave(3),
    Note.a.inOctave(3),
    Note.g.inOctave(3),
  ];

  static StaffSlot byIndex(int index) => slots[index];

  static const _koreanNoteNames = <NoteName, String>{
    NoteName.c: '도',
    NoteName.d: '레',
    NoteName.e: '미',
    NoteName.f: '파',
    NoteName.g: '솔',
    NoteName.a: '라',
    NoteName.b: '시',
  };

  /// 한글 계이름 ("도", "레", ...). 임시표는 무시한다.
  static String koreanNameOf(Pitch pitch) =>
      _koreanNoteNames[pitch.note.noteName]!;

  /// 한글 계이름 전체 목록 (정답 버튼 배열용).
  static const koreanNoteNames = <String>['도', '레', '미', '파', '솔', '라', '시'];
}
```

> **주의:** 이 파일은 `pitch.note.noteName`과 `Pitch` 타입을 쓰므로 **music_notes 0.26 API 기준**이다. 아직 0.13이 설치된 상태라면 Step 4가 실패한다. 그 경우 Task 14(마이그레이션)를 먼저 끝낸 뒤 돌아온다. 순서대로 진행 중이라면 아래 Step 3-b를 먼저 적용한다.

- [ ] **Step 3-b: 0.13 호환 임시 조정 (Task 14 완료 전까지만)**

music_notes가 아직 0.13이면 위 코드의 두 곳을 임시로 바꾼다:

```dart
// 0.13: Pitch 타입이 없고 PositionedNote를 쓴다
final PositionedNote pitch;              // StaffSlot 필드
static final List<PositionedNote> _pitches = [ ... ];
static String koreanNameOf(PositionedNote pitch) =>
    _koreanNoteNames[pitch.note.baseNote]!;

// 0.13: NoteName이 아니라 BaseNote
static const _koreanNoteNames = <BaseNote, String>{
  BaseNote.c: '도', BaseNote.d: '레', BaseNote.e: '미', BaseNote.f: '파',
  BaseNote.g: '솔', BaseNote.a: '라', BaseNote.b: '시',
};
```

Task 14에서 되돌린다.

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/domain/staff_layout_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add lib/domain/staff_layout.dart test/domain/staff_layout_test.dart
git commit -m "feat(domain): type-safe staff layout replacing duplicated note_height_list"
```

---

## Task 13: 문제 생성기 추출 (Random 주입으로 테스트 가능하게)

현재 `getProblemListNote`는 `Random()`을 내부에서 새로 만들어 테스트가 불가능하다.

**Files:**
- Create: `lib/domain/problem.dart`
- Create: `lib/domain/problem_generator.dart`
- Create: `test/domain/problem_generator_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/domain/problem_generator_test.dart`:

```dart
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/problem_mode.dart';

void main() {
  const easyType1 = ProblemMode(
    difficulty: Difficulty.easy,
    questionType: QuestionType.nameTheInterval,
  );
  const hardType1 = ProblemMode(
    difficulty: Difficulty.hard,
    questionType: QuestionType.nameTheInterval,
  );

  group('ProblemGenerator', () {
    test('두 음자리를 생성한다', () {
      final generator = ProblemGenerator(random: Random(42));
      final problem = generator.next(mode: easyType1);

      expect(problem.lower.index, isNot(problem.upper.index));
    });

    test('두 음의 간격은 항상 7자리 이하다', () {
      final generator = ProblemGenerator(random: Random(7));

      for (var i = 0; i < 200; i++) {
        final problem = generator.next(mode: easyType1);
        final distance = (problem.lower.index - problem.upper.index).abs();

        expect(distance, lessThanOrEqualTo(7));
      }
    });

    test('easy 모드는 임시표를 붙이지 않는다', () {
      final generator = ProblemGenerator(random: Random(1));

      for (var i = 0; i < 50; i++) {
        final problem = generator.next(mode: easyType1);

        expect(problem.accidentals, ['none', 'none']);
      }
    });

    test('hard 모드는 임시표를 붙일 수 있다', () {
      final generator = ProblemGenerator(random: Random(1));
      var sawAccidental = false;

      for (var i = 0; i < 50; i++) {
        final problem = generator.next(mode: hardType1);
        if (problem.accidentals.any((a) => a != 'none')) {
          sawAccidental = true;
          break;
        }
      }

      expect(sawAccidental, isTrue);
    });

    test('직전 문제와 같은 음 조합을 연속 출제하지 않는다', () {
      final generator = ProblemGenerator(random: Random(3));
      var previous = generator.next(mode: easyType1);

      for (var i = 0; i < 100; i++) {
        final current = generator.next(mode: easyType1, previous: previous);
        final samePair =
            {current.lower.index, current.upper.index}.difference(
              {previous.lower.index, previous.upper.index},
            ).isEmpty;

        expect(samePair, isFalse);
        previous = current;
      }
    });

    test('같은 seed는 같은 문제열을 만든다 (재현 가능)', () {
      final a = ProblemGenerator(random: Random(99));
      final b = ProblemGenerator(random: Random(99));

      for (var i = 0; i < 20; i++) {
        final pa = a.next(mode: hardType1);
        final pb = b.next(mode: hardType1);

        expect(pa.lower.index, pb.lower.index);
        expect(pa.upper.index, pb.upper.index);
        expect(pa.accidentals, pb.accidentals);
      }
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/domain/problem_generator_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: 값 객체 작성**

`lib/domain/problem.dart`:

```dart
import 'staff_layout.dart';

/// 출제된 문제 하나. 화면에 그릴 정보와 채점에 필요한 정보를 모두 갖는다.
final class IntervalProblem {
  const IntervalProblem({
    required this.lower,
    required this.upper,
    required this.accidentals,
  });

  /// 화면상 위쪽에 그려지는 자리 (index가 작음 = 높은 음).
  final StaffSlot lower;

  /// 화면상 아래쪽에 그려지는 자리.
  final StaffSlot upper;

  /// `[lower, upper]` 순서의 임시표.
  /// 값은 `'none' | 'sharp' | 'flat' | 'double sharp' | 'double flat'`.
  final List<String> accidentals;

  /// 오답노트 저장용 식별자 — 자리 인덱스 쌍.
  List<int> get slotIndices => [lower.index, upper.index];

  @override
  String toString() =>
      'IntervalProblem(${lower.pitch} ${accidentals[0]}, '
      '${upper.pitch} ${accidentals[1]})';
}
```

- [ ] **Step 4: 생성기 작성**

`lib/domain/problem_generator.dart`:

```dart
import 'dart:math';

import 'problem.dart';
import 'problem_mode.dart';
import 'staff_layout.dart';

/// 문제를 무작위 생성한다.
///
/// [Random]을 주입받으므로 테스트에서 seed를 고정해 재현할 수 있다.
/// 기존 `getProblemListNote`가 내부에서 `Random()`을 새로 만들던 문제를 해결한다.
final class ProblemGenerator {
  ProblemGenerator({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// 두 음 사이 허용 최대 자리 간격. 넘으면 다시 뽑는다.
  static const _maxSlotDistance = 7;

  /// 재시도 상한 — 무한 루프 방지.
  static const _maxAttempts = 1000;

  IntervalProblem next({
    required ProblemMode mode,
    IntervalProblem? previous,
  }) {
    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final first = StaffLayout.slots[_random.nextInt(StaffLayout.slots.length)];
      final second =
          StaffLayout.slots[_random.nextInt(StaffLayout.slots.length)];

      if (first.index == second.index) continue;
      if ((first.index - second.index).abs() > _maxSlotDistance) continue;

      if (previous != null && _isSamePair(first, second, previous)) continue;

      return IntervalProblem(
        lower: first,
        upper: second,
        accidentals: mode.usesAccidentals
            ? _randomAccidentals(first, second)
            : const ['none', 'none'],
      );
    }

    throw StateError('Failed to generate a problem after $_maxAttempts tries');
  }

  bool _isSamePair(StaffSlot a, StaffSlot b, IntervalProblem previous) =>
      {a.index, b.index}.difference(previous.slotIndices.toSet()).isEmpty;

  /// 임시표 배정: 한쪽만 50%, 양쪽 30%, 없음 20%.
  List<String> _randomAccidentals(StaffSlot first, StaffSlot second) {
    final where = _random.nextDouble();

    if (where > 0.8) return const ['none', 'none'];

    if (where <= 0.5) {
      return _random.nextBool()
          ? [_anyAccidental(), 'none']
          : ['none', _anyAccidental()];
    }

    // 양쪽 모두 — 겹임시표가 어색해지는 조합은 홑임시표로 통일한다.
    if (_forbidsDoubleAccidentals(first, second)) {
      final shared = _simpleAccidental();
      return [shared, shared];
    }

    return [_simpleAccidental(), _simpleAccidental()];
  }

  String _anyAccidental() {
    final roll = _random.nextDouble();
    if (roll <= 0.35) return 'sharp';
    if (roll <= 0.70) return 'flat';
    if (roll <= 0.85) return 'double flat';
    return 'double sharp';
  }

  String _simpleAccidental() => _random.nextBool() ? 'sharp' : 'flat';

  /// 반음 관계 등으로 겹임시표를 붙이면 이론적으로 어색해지는 조합.
  ///
  /// 기존 `noDiffDoubleList`의 규칙을 일반화한 것이다: 두 음의 자리 간격이
  /// 좁거나(2~4도) 반음 경계(E-F, B-C)를 포함하면 겹임시표를 쓰지 않는다.
  bool _forbidsDoubleAccidentals(StaffSlot a, StaffSlot b) {
    final distance = (a.index - b.index).abs();
    if (distance <= 4) return true;

    const semitoneBoundaryNames = {'미', '파', '시', '도'};
    return semitoneBoundaryNames.contains(StaffLayout.koreanNameOf(a.pitch)) &&
        semitoneBoundaryNames.contains(StaffLayout.koreanNameOf(b.pitch));
  }
}
```

- [ ] **Step 5: 테스트 통과 확인**

```bash
flutter test test/domain/problem_generator_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 6: 커밋**

```bash
git add lib/domain/problem.dart lib/domain/problem_generator.dart \
        test/domain/problem_generator_test.dart
git commit -m "feat(domain): extract problem generator with injectable Random"
```

---

## Task 14: music_notes 0.13 → 0.26 마이그레이션

Task 9의 특성화 테스트가 안전망이다. **마이그레이션 후에도 그 테스트가 통과해야 한다.**

**Files:**
- Modify: `pubspec.yaml`
- Modify: `lib/domain/korean_interval.dart`
- Modify: `lib/domain/staff_layout.dart`
- Modify: `lib/page/problemFunc/problemVarList.dart`
- Modify: `lib/page/problemFunc/problemFunc.dart`
- Modify: `lib/page/problemFunc/problemFuncDeco.dart`
- Modify: `lib/page/easyProblem/*.dart`, `lib/page/hardProblem/*.dart`

- [ ] **Step 1: 마이그레이션 전 기준선 확인**

```bash
flutter test
```

Expected: `All tests passed!` — 여기서 실패하면 마이그레이션을 시작하지 말 것.

- [ ] **Step 2: 버전 상향**

`pubspec.yaml`에서 한 줄 교체:

```yaml
  music_notes: ^0.26.0
```

```bash
flutter pub get
```

Expected: `music_notes 0.26.0` 설치됨.

- [ ] **Step 3: 파괴적 변경 지점 전수 확인**

```bash
flutter analyze 2>&1 | grep -E "^\s*error" | wc -l
grep -rn "PositionedNote" lib/ | wc -l
grep -rn "\.baseNote" lib/ | wc -l
grep -rn "\.inverted\b" lib/ | wc -l
```

각 숫자를 기록해 둔다. 이후 단계에서 0이 되어야 한다.

- [ ] **Step 4: `PositionedNote` → `Pitch` 일괄 치환**

```bash
grep -rl "PositionedNote" lib/ | xargs sed -i '' 's/PositionedNote/Pitch/g'
grep -rn "PositionedNote" lib/ | wc -l
```

Expected: `0`

- [ ] **Step 5: `.baseNote` → `.noteName`, `BaseNote` → `NoteName` 치환**

```bash
grep -rl "baseNote\|BaseNote" lib/ | xargs sed -i '' -e 's/\.baseNote/.noteName/g' -e 's/BaseNote/NoteName/g'
grep -rn "baseNote\|BaseNote" lib/ | wc -l
```

Expected: `0`

- [ ] **Step 6: `.inverted` → `.inversion` 치환**

```bash
grep -rl "\.inverted\b" lib/ | xargs sed -i '' 's/\.inverted\b/.inversion/g'
grep -rn "\.inverted\b" lib/ | wc -l
```

Expected: `0`

- [ ] **Step 7: `toString()` → `format()` 교체 — 가장 중요한 단계**

0.26에서 `Interval.toString()`은 `"Interval(size: ..., quality: ...)"` 형태의 디버그 문자열을 내므로, `"M3"`를 기대하는 모든 곳이 조용히 깨진다. `sed`로 일괄 치환하면 **다른 타입의 toString까지 망가지므로 하지 않는다.**

먼저 대상을 찾는다:

```bash
grep -rn "interval(.*)\.toString()\|\.inversion\.toString()" lib/
```

Task 10에서 만든 seam을 실제 구현으로 바꾼다 — `lib/domain/korean_interval.dart`의 마지막 메서드:

```dart
  /// music_notes 버전 차이를 흡수하는 단일 지점.
  ///
  /// 0.26부터 `toString()`은 디버그 표현이 되었고, `"M3"` 형태는
  /// `format()`이 낸다.
  static String intervalAbbreviation(Interval interval) => interval.format();
```

그리고 `lib/page/problemFunc/problemFuncDeco.dart`의 `getResultAllEasy` / `getResultAllHard` / `commentaryKeyReturn` 안에 있는 `.interval(...).toString()` 호출을 모두 `KoreanInterval.intervalAbbreviation(...)`로 바꾼다. 예:

```dart
// 변경 전
answerReal = randomNoteAnswer[0].interval(randomNoteAnswer[1]).toString();

// 변경 후
answerReal = KoreanInterval.intervalAbbreviation(
  randomNoteAnswer[0].interval(randomNoteAnswer[1]),
);
```

```dart
// 변경 전
answerReal = randomNoteAnswer[0].interval(randomNoteAnswer[1]).inversion.toString();

// 변경 후
answerReal = KoreanInterval.intervalAbbreviation(
  randomNoteAnswer[0].interval(randomNoteAnswer[1]).inversion,
);
```

`problemFuncDeco.dart` 상단에 import를 추가한다:

```dart
import 'package:intervalpractice/domain/korean_interval.dart';
```

- [ ] **Step 8: `staff_layout.dart`의 0.13 임시 조정 되돌리기**

Task 12 Step 3-b에서 임시로 바꿨다면, Task 12 Step 3의 원래 코드(`Pitch`, `NoteName`, `.noteName`)로 되돌린다.

- [ ] **Step 9: 정적 분석 통과 확인**

```bash
flutter analyze 2>&1 | tail -5
```

Expected: error 0건. 남은 error는 개별적으로 확인해 수정한다.

- [ ] **Step 10: 특성화 테스트로 동작 보존 검증 — 이 계획의 핵심 검문소**

```bash
flutter test
```

Expected: `All tests passed!`

**실패하면 마이그레이션이 동작을 바꾼 것이다.** 기대값을 고치지 말고 **구현을 고칠 것.** 특히 `format()`이 `"M3"`가 아닌 다른 형태를 내는지 확인한다:

```bash
cat > /tmp/probe_format.dart <<'EOF'
import 'package:music_notes/music_notes.dart';
void main() {
  print(Interval.M3.format());
  print(Interval.P5.format());
  print(Note.c.inOctave(4).interval(Note.e.inOctave(4)).format());
}
EOF
dart run /tmp/probe_format.dart
```

Expected: `M3`, `P5`, `M3`

- [ ] **Step 11: 실기기/시뮬레이터에서 육안 확인**

정답 판정은 문자열 비교라 테스트만으로는 UI 반영을 놓칠 수 있다.

```bash
flutter run
```

Easy 문제 1에서 3문제를 풀어 정답/오답 판정과 해설 툴팁이 정상인지 확인한다.

- [ ] **Step 12: 커밋**

```bash
git add -A
git commit -m "deps!: migrate music_notes 0.13 -> 0.26

BREAKING API mapping:
- PositionedNote -> Pitch
- Note.baseNote -> Note.noteName (BaseNote -> NoteName)
- Interval.inverted -> Interval.inversion
- Interval.toString() -> Interval.format() (toString is now a debug repr)

Interval formatting is funneled through KoreanInterval.intervalAbbreviation
so future notation changes touch exactly one place.
Characterization tests from Task 9 pass unchanged."
```

---

# Phase 3 — 문제 엔진 통합

6개 화면(약 4,800줄)을 단일 `QuizPage`로 대체한다.

## Task 15: 광고 서비스 단일화

전면광고 로딩 코드가 8곳에 복붙되어 있고, 배너 생성 코드가 5곳에 있다.

**Files:**
- Create: `lib/ads/ad_ids.dart`
- Create: `lib/ads/ad_service.dart`
- Create: `lib/ui/common/banner_ad_slot.dart`
- Create: `test/ads/ad_ids_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/ads/ad_ids_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/ads/ad_ids.dart';

void main() {
  group('AdIds', () {
    test('디버그 모드에서는 구글 테스트 광고 ID를 쓴다', () {
      // kReleaseMode는 flutter test에서 항상 false다.
      expect(AdIds.banner, startsWith('ca-app-pub-3940256099942544/'));
      expect(AdIds.interstitial, startsWith('ca-app-pub-3940256099942544/'));
    });

    test('전면광고 노출 기준 문제 수는 30이다', () {
      expect(AdIds.interstitialThreshold, 30);
    });
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/ads/ad_ids_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: 광고 ID 모듈 작성**

`lib/ads/ad_ids.dart`:

```dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// AdMob 광고 단위 ID.
///
/// 디버그 빌드에서는 구글 공식 테스트 ID를 사용한다.
/// 실 ID로 테스트하면 계정이 정지될 수 있다.
abstract final class AdIds {
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';

  static const _liveBannerAndroid = 'ca-app-pub-7191096510845066/6192851137';
  static const _liveBannerIos = 'ca-app-pub-7191096510845066/7592211642';
  static const _liveInterstitialAndroid =
      'ca-app-pub-7191096510845066/3789278562';
  static const _liveInterstitialIos = 'ca-app-pub-7191096510845066/9450984570';

  static String get banner => kReleaseMode
      ? (Platform.isAndroid ? _liveBannerAndroid : _liveBannerIos)
      : (Platform.isAndroid ? _testBannerAndroid : _testBannerIos);

  static String get interstitial => kReleaseMode
      ? (Platform.isAndroid ? _liveInterstitialAndroid : _liveInterstitialIos)
      : (Platform.isAndroid ? _testInterstitialAndroid : _testInterstitialIos);

  /// 이만큼 문제를 풀면 전면광고를 한 번 띄운다.
  static const interstitialThreshold = 30;
}
```

> 기존 `admobClass.dart`는 `String?`을 반환하며 `!`로 강제 역참조했고, Android/iOS가 아닌 플랫폼에서 `null`을 반환해 크래시 위험이 있었다. 여기서는 non-nullable `String`으로 바꿨다.

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/ads/ad_ids_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: 광고 서비스 작성**

`lib/ads/ad_service.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// 전면광고 로딩/노출을 한 곳에서 관리한다.
///
/// 기존에는 8개 파일에 동일한 `loadAd()`가 복붙되어 있었고,
/// 로드 완료 전에 `show()`를 호출해 광고가 뜨지 않는 경합이 있었다.
/// 여기서는 미리 로드해 두고, 준비된 경우에만 노출한다.
final class InterstitialAdService {
  InterstitialAd? _ad;
  bool _isLoading = false;

  bool get isReady => _ad != null;

  /// 다음 노출을 위해 미리 로드한다. 이미 로드됐거나 로딩 중이면 무시한다.
  void preload() {
    if (_ad != null || _isLoading) return;
    _isLoading = true;

    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              preload();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _ad = null;
              preload();
            },
          );
          _ad = ad;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _ad = null;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  /// 준비된 광고를 노출한다. 실제로 노출했으면 true.
  bool showIfReady() {
    final ad = _ad;
    if (ad == null) {
      preload();
      return false;
    }

    _ad = null;
    ad.show();
    return true;
  }

  void dispose() {
    _ad?.dispose();
    _ad = null;
  }
}
```

- [ ] **Step 6: 배너 위젯 작성**

`lib/ui/common/banner_ad_slot.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../ads/ad_ids.dart';

/// 화면 하단 배너 광고 자리.
///
/// 기존에는 각 화면이 `BannerAd`를 직접 만들고 `_banner!`로 강제 역참조해
/// 로드 실패 시 크래시했다. 여기서는 로드 완료 전/실패 시 빈 공간을 차지한다.
class BannerAdSlot extends StatefulWidget {
  const BannerAdSlot({super.key});

  @override
  State<BannerAdSlot> createState() => _BannerAdSlotState();
}

class _BannerAdSlotState extends State<BannerAdSlot> {
  BannerAd? _banner;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdIds.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
        },
      ),
    );

    _banner = banner;
    banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;

    // 로드 여부와 무관하게 같은 높이를 차지해 레이아웃 점프를 막는다.
    return SizedBox(
      height: AdSize.banner.height.toDouble(),
      width: double.infinity,
      child: (_isLoaded && banner != null)
          ? Center(child: AdWidget(ad: banner))
          : const SizedBox.shrink(),
    );
  }
}
```

- [ ] **Step 7: 분석 및 테스트**

```bash
flutter analyze && flutter test
```

Expected: `No issues found!` / `All tests passed!`

- [ ] **Step 8: 커밋**

```bash
git add lib/ads/ lib/ui/common/banner_ad_slot.dart test/ads/
git commit -m "feat(ads): single ad service replacing 8 duplicated interstitial loaders

- non-nullable ad unit IDs (was String? with force-unwrap)
- preload interstitial so show() no longer races the load
- BannerAdSlot degrades to empty space instead of crashing on load failure"
```

---

## Task 16: 퀴즈 세션 상태 추출

10문제 진행, 정답 수, 오답노트 상태가 6개 화면에 각각 복제되어 있다.

**Files:**
- Create: `lib/state/quiz_session.dart`
- Create: `test/state/quiz_session_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/state/quiz_session_test.dart`:

```dart
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem_generator.dart';
import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/state/quiz_session.dart';

void main() {
  const mode = ProblemMode(
    difficulty: Difficulty.easy,
    questionType: QuestionType.nameTheInterval,
  );

  QuizSession newSession() => QuizSession(
    mode: mode,
    generator: ProblemGenerator(random: Random(11)),
  );

  group('QuizSession 진행', () {
    test('1번 문제부터 시작하고 첫 문제가 준비된다', () {
      final session = newSession();

      expect(session.questionNumber, 1);
      expect(session.totalQuestions, 10);
      expect(session.correctCount, 0);
      expect(session.isReviewMode, isFalse);
    });

    test('정답을 기록하면 정답 수가 증가한다', () {
      final session = newSession()..recordAnswer(isCorrect: true);

      expect(session.correctCount, 1);
      expect(session.wrongProblems, isEmpty);
    });

    test('오답을 기록하면 오답노트에 쌓인다', () {
      final session = newSession()..recordAnswer(isCorrect: false);

      expect(session.correctCount, 0);
      expect(session.wrongProblems, hasLength(1));
    });

    test('10문제를 다 풀면 완료 상태가 된다', () {
      final session = newSession();

      for (var i = 0; i < 10; i++) {
        session.recordAnswer(isCorrect: true);
        if (!session.isFinished) session.nextQuestion();
      }

      expect(session.isFinished, isTrue);
      expect(session.correctCount, 10);
    });
  });

  group('오답 다시 풀기', () {
    test('오답이 없으면 복습을 시작할 수 없다', () {
      final session = newSession()..recordAnswer(isCorrect: true);

      expect(session.canStartReview, isFalse);
    });

    test('오답이 있으면 복습을 시작할 수 있다', () {
      final session = newSession()..recordAnswer(isCorrect: false);

      expect(session.canStartReview, isTrue);
    });

    test('복습을 시작하면 오답 개수만큼만 출제한다', () {
      final session = newSession();

      session.recordAnswer(isCorrect: false);
      session.nextQuestion();
      session.recordAnswer(isCorrect: false);
      session.nextQuestion();
      session.recordAnswer(isCorrect: true);

      session.startReview();

      expect(session.isReviewMode, isTrue);
      expect(session.totalQuestions, 2);
      expect(session.questionNumber, 1);
      expect(session.correctCount, 0);
    });

    test('복습 중 다시 틀리면 다음 복습 대상으로 쌓인다', () {
      final session = newSession();

      session.recordAnswer(isCorrect: false);
      session.startReview();
      session.recordAnswer(isCorrect: false);

      expect(session.wrongProblems, hasLength(1));
    });

    test('restart하면 처음 상태로 돌아간다', () {
      final session = newSession();

      session.recordAnswer(isCorrect: false);
      session.nextQuestion();
      session.restart();

      expect(session.questionNumber, 1);
      expect(session.correctCount, 0);
      expect(session.isReviewMode, isFalse);
      expect(session.wrongProblems, isEmpty);
    });
  });

  test('진행률은 0.0 ~ 1.0 범위다', () {
    final session = newSession();

    expect(session.progress, closeTo(0.1, 0.001));

    for (var i = 0; i < 9; i++) {
      session.recordAnswer(isCorrect: true);
      session.nextQuestion();
    }

    expect(session.progress, closeTo(1.0, 0.001));
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/state/quiz_session_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: 구현 작성**

`lib/state/quiz_session.dart`:

```dart
import 'package:flutter/foundation.dart';

import '../domain/problem.dart';
import '../domain/problem_generator.dart';
import '../domain/problem_mode.dart';

/// 한 판(10문제)의 진행 상태와 오답노트를 관리한다.
///
/// 기존에는 이 상태가 6개 화면에 각각 복제되어 있었다.
final class QuizSession extends ChangeNotifier {
  QuizSession({required this.mode, required ProblemGenerator generator})
    : _generator = generator {
    _current = _generator.next(mode: mode);
  }

  static const questionsPerRound = 10;

  final ProblemMode mode;
  final ProblemGenerator _generator;

  late IntervalProblem _current;
  int _questionNumber = 1;
  int _correctCount = 0;

  /// 이번 판에서 틀린 문제들 — 다음 복습 대상.
  final List<IntervalProblem> _wrongProblems = [];

  /// 복습 모드일 때 풀고 있는 문제 목록.
  List<IntervalProblem> _reviewQueue = [];
  bool _isReviewMode = false;

  IntervalProblem get current => _current;
  int get questionNumber => _questionNumber;
  int get correctCount => _correctCount;
  bool get isReviewMode => _isReviewMode;
  List<IntervalProblem> get wrongProblems => List.unmodifiable(_wrongProblems);

  int get totalQuestions =>
      _isReviewMode ? _reviewQueue.length : questionsPerRound;

  bool get isFinished => _questionNumber >= totalQuestions;

  bool get canStartReview => _wrongProblems.isNotEmpty;

  double get progress =>
      totalQuestions == 0 ? 0 : _questionNumber / totalQuestions;

  /// 채점 결과를 기록한다. 문제를 넘기지는 않는다.
  void recordAnswer({required bool isCorrect}) {
    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongProblems.add(_current);
    }
    notifyListeners();
  }

  /// 다음 문제로 넘어간다.
  void nextQuestion() {
    _questionNumber++;

    if (_isReviewMode) {
      final index = _questionNumber - 1;
      if (index < _reviewQueue.length) _current = _reviewQueue[index];
    } else {
      _current = _generator.next(mode: mode, previous: _current);
    }

    notifyListeners();
  }

  /// 이번 판의 오답만 다시 출제하는 복습 모드로 전환한다.
  void startReview() {
    if (_wrongProblems.isEmpty) return;

    _reviewQueue = List.of(_wrongProblems);
    _wrongProblems.clear();
    _isReviewMode = true;
    _questionNumber = 1;
    _correctCount = 0;
    _current = _reviewQueue.first;

    notifyListeners();
  }

  /// 새 10문제를 처음부터 시작한다.
  void restart() {
    _wrongProblems.clear();
    _reviewQueue = [];
    _isReviewMode = false;
    _questionNumber = 1;
    _correctCount = 0;
    _current = _generator.next(mode: mode);

    notifyListeners();
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/state/quiz_session_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: 커밋**

```bash
git add lib/state/quiz_session.dart test/state/quiz_session_test.dart
git commit -m "feat(state): extract QuizSession replacing state duplicated across 6 screens"
```

---

## Task 17: 통합 QuizPage 구현

**Files:**
- Create: `lib/ui/quiz/staff_view.dart`
- Create: `lib/ui/quiz/answer_pad.dart`
- Create: `lib/ui/quiz/result_sheet.dart`
- Create: `lib/ui/quiz/quiz_page.dart`
- Create: `test/ui/quiz_page_test.dart`

- [ ] **Step 1: 오선지 위젯 작성**

`lib/ui/quiz/staff_view.dart`:

기존 `easyProblemType1.dart:662-717`의 `Stack` 구조와 `problemFunc.dart`의 `returnLine`/`addLine1`/`addLine2`/`addLine3`/`addAccidentals`를 하나의 위젯으로 옮긴다.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_notes/music_notes.dart';

import '../../domain/problem.dart';
import '../../domain/staff_layout.dart';

/// 높은음자리표 오선지에 문제의 두 음을 그린다.
class StaffView extends StatelessWidget {
  const StaffView({super.key, required this.problem, this.hideUpperNote = false});

  final IntervalProblem problem;

  /// 유형 2(계이름 맞히기)에서 정답이 되는 음을 가린다.
  final bool hideUpperNote;

  static const _lineTops = [90.0, 116.5, 143.0, 169.5, 196.0];
  static const _firstNoteLeft = 130.0;
  static const _secondNoteLeft = 230.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0.h,
            bottom: 0.h,
            left: 10.0.w,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/treble_clef_ff_cut.png',
                height: 180.h,
              ),
            ),
          ),
          for (final top in _lineTops) _StaffLine(top: top),
          _NoteHead(slot: problem.lower, left: _firstNoteLeft),
          _LedgerLineBelow(slot: problem.lower, left: _firstNoteLeft.w),
          _Accidental(
            kind: problem.accidentals[0],
            top: problem.lower.top,
            left: _firstNoteLeft.w,
          ),
          if (!hideUpperNote) ...[
            _NoteHead(slot: problem.upper, left: _secondNoteLeft),
            _LedgerLineBelow(slot: problem.upper, left: _secondNoteLeft.w),
            _Accidental(
              kind: problem.accidentals[1],
              top: problem.upper.top,
              left: _secondNoteLeft.w,
            ),
          ],
        ],
      ),
    );
  }
}

class _StaffLine extends StatelessWidget {
  const _StaffLine({required this.top});

  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top.h,
      left: 10.w,
      right: 10.w,
      child: Container(
        color: Theme.of(context).colorScheme.onSurface,
        height: 2.0.h,
      ),
    );
  }
}

class _NoteHead extends StatelessWidget {
  const _NoteHead({required this.slot, required this.left});

  final StaffSlot slot;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: slot.top.h,
      left: left.w,
      child: SizedBox(
        height: 26.5.h,
        child: Stack(
          children: [
            Image.asset('assets/whole_note_lean.png'),
            _LedgerLineThrough(slot: slot),
          ],
        ),
      ),
    );
  }
}

/// 음표를 관통하는 덧줄 (기존 addLine1).
class _LedgerLineThrough extends StatelessWidget {
  const _LedgerLineThrough({required this.slot});

  final StaffSlot slot;

  static final _middle = {
    Note.a.inOctave(5), Note.f.inOctave(5), Note.d.inOctave(5),
    Note.b.inOctave(4), Note.g.inOctave(4), Note.e.inOctave(4),
    Note.c.inOctave(4), Note.a.inOctave(3), Note.c.inOctave(6),
  };
  static final _low = {Note.b.inOctave(5), Note.d.inOctave(6)};
  static final _high = {Note.b.inOctave(3), Note.g.inOctave(3)};

  @override
  Widget build(BuildContext context) {
    final double? top = switch (slot.pitch) {
      final p when _middle.contains(p) => 12.75,
      final p when _low.contains(p) => 24.5,
      final p when _high.contains(p) => 0.0,
      _ => null,
    };

    if (top == null) return const SizedBox.shrink();

    return Positioned(top: top.h, child: const _LedgerLine());
  }
}

/// 오선 밖 음의 추가 덧줄 (기존 addLine2/addLine3).
class _LedgerLineBelow extends StatelessWidget {
  const _LedgerLineBelow({required this.slot, required this.left});

  final StaffSlot slot;
  final double left;

  static final _aboveStaff = {Note.d.inOctave(6), Note.c.inOctave(6)};
  static final _belowStaff = {Note.a.inOctave(3), Note.g.inOctave(3)};

  @override
  Widget build(BuildContext context) {
    final double? top = switch (slot.pitch) {
      final p when _aboveStaff.contains(p) => 63.5,
      final p when _belowStaff.contains(p) => 222.5,
      _ => null,
    };

    if (top == null) return const SizedBox.shrink();

    return Positioned(top: top.h, left: left, child: const _LedgerLine());
  }
}

class _LedgerLine extends StatelessWidget {
  const _LedgerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onSurface,
      height: 2.0.h,
      width: 50.w,
    );
  }
}

/// 임시표 이미지 (기존 addAccidentals).
class _Accidental extends StatelessWidget {
  const _Accidental({
    required this.kind,
    required this.top,
    required this.left,
  });

  final String kind;
  final double top;
  final double left;

  @override
  Widget build(BuildContext context) {
    final spec = switch (kind) {
      'sharp' => (
        asset: 'assets/sharp2.png',
        dTop: -13.0,
        dLeft: -11.0,
        h: 54.0,
        w: 47.0,
      ),
      'double sharp' => (
        asset: 'assets/doubleSharp.png',
        dTop: 3.5,
        dLeft: -2.0,
        h: 20.0,
        w: 20.0,
      ),
      'flat' => (
        asset: 'assets/flat2.png',
        dTop: -16.0,
        dLeft: 7.0,
        h: 41.0,
        w: 16.0,
      ),
      'double flat' => (
        asset: 'assets/doubleFlat.png',
        dTop: -17.5,
        dLeft: -7.5,
        h: 45.0,
        w: 30.0,
      ),
      _ => null,
    };

    if (spec == null) return const SizedBox.shrink();

    return Positioned(
      top: (top + spec.dTop).h,
      left: left + spec.dLeft.w,
      child: SizedBox(
        height: spec.h.h,
        width: spec.w.w,
        child: Image.asset(spec.asset, fit: BoxFit.fill),
      ),
    );
  }
}
```

- [ ] **Step 2: 정답 버튼 패드 작성**

`lib/ui/quiz/answer_pad.dart`:

```dart
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
            values: _perfectQualities
                .map((q) => '$q$selectedSize')
                .toList(),
            selected: submittedAnswer,
            enabled: submittedAnswer == null,
            onTap: onQualitySelected,
          ),
          SizedBox(height: 13.0.h),
          _ButtonRow(
            labels: _imperfectQualities.map((q) => '$q$selectedSize도').toList(),
            values: _imperfectQualities
                .map((q) => '$q$selectedSize')
                .toList(),
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
    final names = StaffLayout.koreanNoteNames;

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
```

- [ ] **Step 3: 결과 바텀시트 작성**

`lib/ui/quiz/result_sheet.dart`:

```dart
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
```

- [ ] **Step 4: QuizPage 작성**

`lib/ui/quiz/quiz_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../ads/ad_ids.dart';
import '../../ads/ad_service.dart';
import '../../domain/answer_checker.dart';
import '../../domain/problem_generator.dart';
import '../../domain/problem_mode.dart';
import '../../state/ad_counter.dart';
import '../../state/quiz_session.dart';
import '../common/banner_ad_slot.dart';
import 'answer_pad.dart';
import 'progress_bar.dart';
import 'result_sheet.dart';
import 'staff_view.dart';

/// 기존 easyProblemType1/2/3, hardProblemType1/2/3 여섯 화면을 대체한다.
class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.mode});

  final ProblemMode mode;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late final QuizSession _session = QuizSession(
    mode: widget.mode,
    generator: ProblemGenerator(),
  );
  final _interstitial = InterstitialAdService();

  String? _selectedSize;
  String? _submittedAnswer;

  @override
  void initState() {
    super.initState();
    _interstitial.preload();
  }

  @override
  void dispose() {
    _interstitial.dispose();
    _session.dispose();
    super.dispose();
  }

  void _submit(String answer) {
    context.read<AdCounter>().increment();

    setState(() => _submittedAnswer = answer);

    final grading = AnswerChecker.grade(
      problem: _session.current,
      mode: widget.mode,
      submitted: answer,
    );

    _session.recordAnswer(isCorrect: grading.isCorrect);
    _showResultSheet(grading);
  }

  void _showResultSheet(Grading grading) {
    showModalBottomSheet<void>(
      context: context,
      enableDrag: false,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => AnswerResultSheet(
        isCorrect: grading.isCorrect,
        answerText: grading.correctAnswerText,
        commentary: grading.commentary,
        actionButton: _session.isFinished
            ? _actionButton('결과보기', _showFinalResult)
            : _actionButton('다음문제', _goToNextQuestion),
      ),
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }

  void _goToNextQuestion() {
    Navigator.pop(context);
    setState(() {
      _selectedSize = null;
      _submittedAnswer = null;
    });
    _session.nextQuestion();
  }

  void _showFinalResult() {
    Navigator.pop(context);

    final counter = context.read<AdCounter>();
    if (counter.solvedCount >= AdIds.interstitialThreshold) {
      if (_interstitial.showIfReady()) counter.reset();
    }

    // 결과 화면은 Task 18에서 연결한다.
    setState(() {
      _selectedSize = null;
      _submittedAnswer = null;
    });
    _session.restart();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(_session.isReviewMode ? '오답문제' : widget.mode.title),
          ),
          body: Column(
            children: [
              QuizProgressBar(session: _session),
              StaffView(
                problem: _session.current,
                hideUpperNote:
                    widget.mode.questionType == QuestionType.nameTheNote,
              ),
              AnswerPad(
                mode: widget.mode,
                selectedSize: _selectedSize,
                submittedAnswer: _submittedAnswer,
                onSizeSelected: (size) => setState(() => _selectedSize = size),
                // AnswerPad가 이미 "장3" 형태로 조립해 넘겨준다.
                onQualitySelected: _submit,
                onNoteSelected: _submit,
              ),
              const Expanded(child: SizedBox()),
              const BannerAdSlot(),
              SizedBox(height: 30.h),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 5: 진행바 위젯 작성**

`lib/ui/quiz/progress_bar.dart`:

```dart
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
```

> `percent_indicator` 패키지 대신 Flutter 기본 `LinearProgressIndicator`를 쓴다. 의존성이 하나 줄어든다 — Task 18에서 pubspec에서 제거한다.

- [ ] **Step 6: 채점기 작성**

`lib/domain/answer_checker.dart`:

```dart
import 'package:music_notes/music_notes.dart';

import 'commentary.dart';
import 'korean_interval.dart';
import 'problem.dart';
import 'problem_mode.dart';
import 'staff_layout.dart';

/// 채점 결과.
final class Grading {
  const Grading({
    required this.isCorrect,
    required this.correctAnswerText,
    required this.commentary,
  });

  final bool isCorrect;

  /// 사용자에게 보여줄 정답 문자열 ("장3도" 또는 "솔").
  final String correctAnswerText;

  /// 해설. 없으면 빈 문자열.
  final String commentary;
}

abstract final class AnswerChecker {
  /// 임시표를 적용한 실제 음높이 두 개를 낮은 음부터 정렬해 반환한다.
  static List<Pitch> pitchesOf(IntervalProblem problem) {
    final pitches = [
      _applyAccidental(problem.lower.pitch, problem.accidentals[0]),
      _applyAccidental(problem.upper.pitch, problem.accidentals[1]),
    ]..sort();

    return pitches;
  }

  static Pitch _applyAccidental(Pitch pitch, String accidental) =>
      switch (accidental) {
        'sharp' => pitch.note.sharp.inOctave(pitch.octave),
        'double sharp' => pitch.note.sharp.sharp.inOctave(pitch.octave),
        'flat' => pitch.note.flat.inOctave(pitch.octave),
        'double flat' => pitch.note.flat.flat.inOctave(pitch.octave),
        _ => pitch,
      };

  static Grading grade({
    required IntervalProblem problem,
    required ProblemMode mode,
    required String submitted,
  }) {
    final pitches = pitchesOf(problem);

    if (mode.questionType == QuestionType.nameTheNote) {
      // 화면에 가려진 음(upper)의 계이름이 정답이다.
      final answer = StaffLayout.koreanNameOf(problem.upper.pitch);

      return Grading(
        isCorrect: submitted == answer,
        correctAnswerText: answer,
        commentary: Commentary.forNoteQuestion(pitches),
      );
    }

    var interval = pitches[0].interval(pitches[1]);
    if (mode.usesInvertedAnswer) interval = interval.inversion;

    final korean = KoreanInterval.fromInterval(interval);

    return Grading(
      isCorrect: submitted == korean,
      correctAnswerText: '$korean도',
      commentary: Commentary.forIntervalQuestion(pitches, korean),
    );
  }
}
```

- [ ] **Step 7: 해설 모듈 작성**

`lib/domain/commentary.dart` — 기존 `commentaryKeyReturn`과 `commentaryType2` 로직을 순수 Dart로 옮기고, 문구 테이블은 `lib/domain/commentary_data.dart`로 분리한다.

```dart
import 'package:music_notes/music_notes.dart';

import 'commentary_data.dart';
import 'korean_interval.dart';

abstract final class Commentary {
  /// 유형 1/3용 해설: 반음 개수와 임시표 영향을 설명한다.
  static String forIntervalQuestion(List<Pitch> sortedPitches, String korean) {
    final abbreviation = KoreanInterval.intervalAbbreviation(
      sortedPitches[0].interval(sortedPitches[1]),
    );

    final key =
        abbreviation[abbreviation.length - 1] +
        _noteLetter(sortedPitches[0]) +
        _noteLetter(sortedPitches[1]);

    final basic = commentaryBasic[key];
    if (basic == null) return '';

    final base = '${basic[0]} $korean도 ${basic[1]}';

    final lower = commentaryDownAccidental[_accidentalCode(sortedPitches[0])];
    final upper = commentaryUpAccidental[_accidentalCode(sortedPitches[1])];

    return [
      if (lower != null) lower,
      if (upper != null) upper,
      base,
    ].join(' ');
  }

  /// 유형 2용 해설: 음정 이름 자체를 설명한다.
  static String forNoteQuestion(List<Pitch> sortedPitches) {
    final interval = sortedPitches[0].interval(sortedPitches[1]);
    final korean = KoreanInterval.fromInterval(interval);

    return commentaryType2['$korean도'] ?? '';
  }

  static String _noteLetter(Pitch pitch) =>
      pitch.note.noteName.name.toLowerCase();

  static String _accidentalCode(Pitch pitch) {
    final accidental = pitch.note.accidental;

    return switch (accidental.semitones) {
      0 => 'n',
      1 => 's',
      2 => 'ds',
      -1 => 'f',
      -2 => 'df',
      _ => 'n',
    };
  }
}
```

`lib/domain/commentary_data.dart`에는 기존 `problemFuncDeco.dart`의 `commentaryBasic`(56항목), `commentaryUpAccidental`(4항목), `commentaryDownAccidental`(4항목), `commentaryType2`(44항목) 맵을 **내용 변경 없이 그대로 옮긴다.** 타입만 `Map` → `Map<String, List<String>>` / `Map<String, String>`으로 명시한다.

- [ ] **Step 8: 위젯 테스트 작성**

`test/ui/quiz_page_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:intervalpractice/domain/problem_mode.dart';
import 'package:intervalpractice/state/ad_counter.dart';
import 'package:intervalpractice/ui/quiz/answer_pad.dart';
import 'package:intervalpractice/ui/quiz/quiz_page.dart';
import 'package:intervalpractice/ui/quiz/staff_view.dart';

Widget wrap(Widget child) => ChangeNotifierProvider(
  create: (_) => AdCounter(),
  child: ScreenUtilInit(
    designSize: const Size(375, 844),
    builder: (context, _) => MaterialApp(home: child),
  ),
);

void main() {
  testWidgets('유형 1은 오선지와 도수 버튼을 보여준다', (tester) async {
    await tester.pumpWidget(
      wrap(
        const QuizPage(
          mode: ProblemMode(
            difficulty: Difficulty.easy,
            questionType: QuestionType.nameTheInterval,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(StaffView), findsOneWidget);
    expect(find.byType(AnswerPad), findsOneWidget);
    expect(find.text('음정의 간격을 고르세요'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('유형 2는 계이름 버튼을 보여준다', (tester) async {
    await tester.pumpWidget(
      wrap(
        const QuizPage(
          mode: ProblemMode(
            difficulty: Difficulty.easy,
            questionType: QuestionType.nameTheNote,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('알맞은 계이름을 고르세요'), findsOneWidget);
    expect(find.text('도'), findsOneWidget);
    expect(find.text('시'), findsOneWidget);
  });

  testWidgets('AppBar 제목은 난이도를 따른다', (tester) async {
    await tester.pumpWidget(
      wrap(
        const QuizPage(
          mode: ProblemMode(
            difficulty: Difficulty.hard,
            questionType: QuestionType.nameTheInterval,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Hard'), findsOneWidget);
  });
}
```

- [ ] **Step 9: 테스트 통과 확인**

```bash
flutter test test/ui/quiz_page_test.dart
```

Expected: `All tests passed!`

배너 광고가 플랫폼 채널을 요구해 실패하면, `BannerAdSlot`이 로드 실패 시 `SizedBox.shrink()`를 반환하므로 테스트 환경에서도 통과해야 한다. 그래도 실패하면 `AdWidget` 대신 테스트에서 빈 위젯이 나오는지 확인한다.

- [ ] **Step 10: 커밋**

```bash
git add lib/ui/quiz/ lib/domain/answer_checker.dart lib/domain/commentary.dart \
        lib/domain/commentary_data.dart test/ui/quiz_page_test.dart
git commit -m "feat(ui): unified QuizPage replacing 6 duplicated problem screens"
```

---

## Task 18: 기존 6개 화면 삭제 및 홈 화면 연결

**Files:**
- Create: `lib/state/ad_counter.dart`
- Create: `lib/ui/home/home_page.dart`
- Modify: `lib/main.dart`, `lib/app.dart`
- **Modify: `test/widget_test.dart`** — 이 태스크가 깨뜨린다 (아래 Step 5-b 참조)
- Delete: `lib/page/` 하위 구 파일 전부

> **경고:** 이 태스크는 `test/widget_test.dart`를 **컴파일 불가 상태로 만든다.** 해당 테스트는 `main.dart`의 `MyApp`과 `page/problemFunc/providerCounter.dart`의 `CounterClass`를 직접 import하는데, 이 태스크가 둘 다 없앤다(`IntervalPracticeApp`, `AdCounter`로 대체). Step 5-b에서 함께 고친다.

- [ ] **Step 1: AdCounter 작성 (기존 providerCounter.dart 대체)**

`lib/state/ad_counter.dart`:

```dart
import 'package:flutter/foundation.dart';

/// 전면광고 노출 시점을 정하기 위해 누적 푼 문제 수를 센다.
final class AdCounter extends ChangeNotifier {
  int _solvedCount = 0;

  int get solvedCount => _solvedCount;

  void increment() {
    _solvedCount++;
    notifyListeners();
  }

  void reset() {
    _solvedCount = 0;
    notifyListeners();
  }
}
```

- [ ] **Step 2: 홈 화면 작성**

기존 `firstProblemTypeList.dart`의 `ListViewEasy`/`ListViewHard` 두 클래스(거의 동일한 170줄 × 2)를 `ProblemMode.forDifficulty()`로 구동되는 하나의 리스트로 통합한다. 광고 로딩 코드는 `InterstitialAdService`로 대체한다.

`lib/ui/home/home_page.dart`:

```dart
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../ads/ad_ids.dart';
import '../../ads/ad_service.dart';
import '../../domain/problem_mode.dart';
import '../../state/ad_counter.dart';
import '../common/banner_ad_slot.dart';
import '../quiz/quiz_page.dart';
import '../settings/settings_page.dart';

/// 난이도 탭 + 문제 유형 목록. 기존 firstProblemTypeList.dart를 대체한다.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.showPrivacySettings = false});

  /// GDPR 대상 사용자에게만 개인정보 재설정 버튼을 노출한다.
  final bool showPrivacySettings;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: Difficulty.values.length,
    vsync: this,
  );
  final _interstitial = InterstitialAdService();

  @override
  void initState() {
    super.initState();
    _interstitial.preload();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _interstitial.dispose();
    super.dispose();
  }

  void _openQuiz(ProblemMode mode) {
    final counter = context.read<AdCounter>();
    if (counter.solvedCount >= AdIds.interstitialThreshold) {
      if (_interstitial.showIfReady()) counter.reset();
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => QuizPage(mode: mode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 2),
                insets: EdgeInsets.symmetric(horizontal: 40),
              ),
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  child: Text('Easy', style: TextStyle(color: colors.primary)),
                ),
                Tab(
                  child: Text('Hard', style: TextStyle(color: colors.tertiary)),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final difficulty in Difficulty.values)
                    _ModeList(difficulty: difficulty, onTapMode: _openQuiz),
                ],
              ),
            ),
            _BottomActions(showPrivacySettings: widget.showPrivacySettings),
            const BannerAdSlot(),
          ],
        ),
      ),
    );
  }
}

class _ModeList extends StatelessWidget {
  const _ModeList({required this.difficulty, required this.onTapMode});

  final Difficulty difficulty;
  final ValueChanged<ProblemMode> onTapMode;

  @override
  Widget build(BuildContext context) {
    final modes = ProblemMode.forDifficulty(difficulty);
    final icon = difficulty == Difficulty.easy
        ? 'assets/music_2805328.png'
        : 'assets/musichard.png';

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 0),
      itemCount: modes.length,
      itemBuilder: (context, index) {
        final mode = modes[index];

        return Padding(
          padding: const EdgeInsets.all(7.5),
          child: _ModeTile(
            mode: mode,
            iconAsset: icon,
            onTap: () => onTapMode(mode),
          ),
        );
      },
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.iconAsset,
    required this.onTap,
  });

  final ProblemMode mode;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        height: 155.h,
        decoration: BoxDecoration(
          border: Border.all(color: colors.outlineVariant, width: 2.3),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 105.w,
              height: 105.h,
              child: Center(
                child: SizedBox(
                  height: 73.h,
                  width: 73.w,
                  child: Image.asset(iconAsset),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Text(
                      mode.listTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  for (final line in mode.listDescription)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AutoSizeText(line, maxLines: 1),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.showPrivacySettings});

  final bool showPrivacySettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (showPrivacySettings)
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
            icon: const Icon(Icons.privacy_tip_outlined),
          ),
        Padding(
          padding: EdgeInsets.only(right: 30.w),
          child: const Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            showDuration: Duration(seconds: 5),
            message: 'Easy는 임시표가 없는 기본 계이름입니다\n'
                'Hard는 여러종류의 임시표를 포함하고 있습니다',
            child: Icon(Icons.info_outline, size: 18),
          ),
        ),
      ],
    );
  }
}
```

> 기존 코드는 `SizedBox(height: 590.h)` / `SizedBox(height: 530.h)`로 높이를 고정해 작은 화면에서 넘침이 발생했다. 여기서는 `Expanded` + 스크롤 가능한 `ListView`로 바꿔 해소한다.

- [ ] **Step 3: main.dart / app.dart 정리**

`lib/main.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  unawaited(MobileAds.instance.initialize());

  runApp(const IntervalPracticeApp());
}
```

`lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'state/ad_counter.dart';
import 'theme/app_theme.dart';
import 'ui/common/loading_page.dart';

class IntervalPracticeApp extends StatelessWidget {
  const IntervalPracticeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdCounter(),
      child: ScreenUtilInit(
        designSize: const Size(375, 844),
        builder: (context, child) => MaterialApp(
          title: '음정박사',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          ),
          home: child,
        ),
        child: const LoadingPage(),
      ),
    );
  }
}
```

> `AppTheme`는 Task 19에서 만든다. 이 태스크에서는 `ThemeData.light()`/`ThemeData.dark()`를 임시로 넣고 Task 19에서 교체한다.

- [ ] **Step 4: 구 파일 삭제**

```bash
git rm -r lib/page/easyProblem lib/page/hardProblem
git rm lib/page/firstProblemTypeList.dart \
       lib/page/problemFunc/problemFunc.dart \
       lib/page/problemFunc/problemFuncDeco.dart \
       lib/page/problemFunc/problemVarList.dart \
       lib/page/problemFunc/colorList.dart \
       lib/page/problemFunc/admobClass.dart \
       lib/page/problemFunc/admobFunc.dart \
       lib/page/problemFunc/providerCounter.dart
```

`resultPage.dart`, `settingPage/`, `loadingPage.dart`는 각각 `lib/ui/result/`, `lib/ui/settings/`, `lib/ui/common/`으로 **이동**한다:

```bash
git mv lib/page/problemFunc/resultPage.dart lib/ui/result/result_page.dart
git mv lib/page/settingPage/settingPage.dart lib/ui/settings/settings_page.dart
git mv lib/page/settingPage/initialization_helper.dart lib/ads/consent_service.dart
git mv lib/page/settingPage/initialize_screen.dart lib/ui/common/initialize_screen.dart
git mv lib/page/loadingPage.dart lib/ui/common/loading_page.dart
rmdir lib/page/problemFunc lib/page/settingPage lib/page 2>/dev/null || true
```

- [ ] **Step 5: 특성화 테스트 정리**

Task 9의 `test/characterization/answer_calculation_test.dart`는 삭제된 `problemFuncDeco.dart`를 import하므로 더 이상 컴파일되지 않는다. 그 검증 책임은 이미 `test/domain/` 테스트들이 이어받았다.

```bash
git rm test/characterization/answer_calculation_test.dart
```

- [ ] **Step 5-b: 스모크 테스트를 새 진입점에 맞게 갱신**

Task 3에서 만든 `test/widget_test.dart`는 이 태스크가 없애는 심볼 두 개를 직접 import한다. 갱신하지 않으면 **컴파일 자체가 실패**한다.

```bash
grep -n "import\|MyApp\|CounterClass" test/widget_test.dart
```

교체 대상:

| 기존 | 신규 |
|---|---|
| `import 'package:intervalpractice/main.dart';` → `MyApp` | `import 'package:intervalpractice/app.dart';` → `IntervalPracticeApp` |
| `import 'package:intervalpractice/page/problemFunc/providerCounter.dart';` → `CounterClass` | `import 'package:intervalpractice/state/ad_counter.dart';` → `AdCounter` |

또한 이 테스트는 `LoadingPage` → `InitializeScreen` 전이를 검증하며 `InitializeScreen`이 `CircularProgressIndicator`를 그린다는 데 의존한다. 이동한 `lib/ui/common/initialize_screen.dart`가 그 구조를 유지하는지 확인하고, 바뀌었다면 단언을 새 구조에 맞춘다.

테스트가 **여전히 실제 결함을 잡는지** 반드시 재확인한다 — provider 배선을 일부러 제거해 실패하는지 보고 되돌린다:

```bash
flutter test   # 통과 확인
# app.dart에서 ChangeNotifierProvider 래퍼를 임시 제거 → flutter test 가 실패해야 함
# git checkout -- lib/app.dart 로 복원 후 flutter test 재통과 확인
```

- [ ] **Step 6: 이동한 파일의 클래스명·참조 정리**

파일을 옮기기만 해서는 컴파일되지 않는다. 아래 3건을 함께 고친다.

1. **클래스명 통일** — `settingPage.dart`의 클래스는 `SettingPage`(단수)였다. 파일명에 맞춰 `SettingsPage`로 바꾼다:

```bash
sed -i '' 's/\bSettingPage\b/SettingsPage/g' lib/ui/settings/settings_page.dart
grep -rn "SettingPage\b" lib/ | grep -v SettingsPage
```

Expected: 두 번째 명령 출력 없음.

2. **로딩 화면의 목적지 교체** — `loading_page.dart`가 삭제된 `FirstProblemTypeList`로 이동하고 있다. `HomePage`로 바꾼다.

```bash
grep -n "FirstProblemTypeList" lib/ui/common/loading_page.dart
```

해당 import와 위젯 생성을 각각 아래로 교체한다:

```dart
import '../home/home_page.dart';
```

```dart
// 변경 전: return const FirstProblemTypeList();
// 변경 후:
return const HomePage();
```

3. **오답노트 라우트명** — 기존 코드는 `Navigator.popUntil(context, ModalRoute.withName("/FirstProblemTypeList"))`로 홈까지 되돌아갔다. 이 이름 붙은 라우트는 실제로 등록된 적이 없어 동작하지 않았다. `result_page.dart`에서 아래로 교체한다:

```dart
// 변경 전: Navigator.popUntil(context, ModalRoute.withName("/FirstProblemTypeList"));
// 변경 후: 퀴즈 화면까지만 닫고 홈으로 돌아간다.
Navigator.of(context).popUntil((route) => route.isFirst);
```

- [ ] **Step 6-b: import 경로 수정 및 분석**

```bash
flutter analyze 2>&1 | grep -E "^\s*error" | head -30
```

이동한 파일들의 상대 import를 새 위치에 맞게 고친다. error가 0이 될 때까지 반복한다.

- [ ] **Step 7: 미사용이 된 의존성 제거**

`percent_indicator`는 Task 17 Step 5에서 기본 위젯으로 대체했다.

```bash
grep -rn "percent_indicator" lib/ | wc -l
```

Expected: `0` — 그러면 `pubspec.yaml`에서 `percent_indicator` 줄을 삭제하고 `flutter pub get`.

- [ ] **Step 8: 전체 검증**

```bash
flutter analyze && flutter test
```

Expected: `No issues found!` / `All tests passed!`

```bash
cloc lib/ 2>/dev/null || find lib -name "*.dart" | xargs wc -l | tail -1
```

Expected: 총 라인 수가 9,205 → 3,000줄대로 감소.

- [ ] **Step 9: 실기기 회귀 확인**

```bash
flutter run
```

6가지 모드를 각각 최소 2문제씩 풀어 정답 판정·해설·진행바·오답노트가 기존과 동일하게 동작하는지 확인한다.

- [ ] **Step 10: 커밋**

```bash
git add -A
git commit -m "refactor!: delete 6 duplicated problem screens, reorganize lib/ by layer

- lib/page/** -> lib/domain, lib/state, lib/ads, lib/ui
- 9205 -> ~3000 lines
- drop percent_indicator (replaced by LinearProgressIndicator)"
```

---

# Phase 4 — Material 3 테마 및 다크모드

## Task 19: M3 ColorScheme 정의

**Files:**
- Create: `lib/theme/app_theme.dart`
- Create: `test/theme/app_theme_test.dart`

- [ ] **Step 1: 실패하는 테스트 작성**

`test/theme/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('밝기가 올바르게 설정된다', () {
      expect(AppTheme.light.colorScheme.brightness, Brightness.light);
      expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
    });

    test('easy/hard 구분색이 서로 다르다', () {
      final scheme = AppTheme.light.colorScheme;
      expect(scheme.primary, isNot(scheme.tertiary));
    });

    test('다크 테마 표면 위 텍스트가 충분한 대비를 갖는다', () {
      final scheme = AppTheme.dark.colorScheme;
      final surface = scheme.surface.computeLuminance();
      final onSurface = scheme.onSurface.computeLuminance();
      final contrast =
          (max(surface, onSurface) + 0.05) / (min(surface, onSurface) + 0.05);

      expect(contrast, greaterThan(4.5));
    });
  });
}

double max(double a, double b) => a > b ? a : b;
double min(double a, double b) => a < b ? a : b;
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/theme/app_theme_test.dart
```

Expected: FAIL — `Target of URI doesn't exist`

- [ ] **Step 3: 테마 구현**

`lib/theme/app_theme.dart` — 기존 `colorList.dart`의 하드코딩된 8개 색을 M3 시드 색상으로 이관한다. 기존 색상의 의미는 다음과 같이 매핑한다:

| 기존 | 의미 | M3 대응 |
|---|---|---|
| `color1` `#63af5b` (녹색) | easy 강조 | `primary` |
| `color2` `#e36d3f` (주황) | hard 강조 | `tertiary` |
| `color4/5` (녹색 계열) | 정답 시트 | `primaryContainer` / `onPrimaryContainer` |
| `color6/7` (적갈색) | 오답 시트 | `errorContainer` / `onErrorContainer` |
| `color8` `#dedede` | 타일 테두리 | `outlineVariant` |

```dart
import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// easy 난이도 강조색 (기존 color1).
  static const _easySeed = Color(0xff63af5b);

  /// hard 난이도 강조색 (기존 color2).
  static const _hardSeed = Color(0xffe36d3f);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _easySeed,
      brightness: brightness,
    ).copyWith(
      // hard 난이도는 tertiary 슬롯을 쓴다.
      tertiary: _hardSeed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(color: scheme.onInverseSurface),
      ),
      textTheme: const TextTheme(
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/theme/app_theme_test.dart
```

Expected: `All tests passed!`

대비 테스트가 실패하면 `ColorScheme.fromSeed`의 `contrastLevel` 파라미터를 올리거나 `onSurface`를 명시적으로 지정한다.

- [ ] **Step 5: app.dart에서 임시 테마를 교체**

Task 18 Step 3에서 넣은 `ThemeData.light()`/`ThemeData.dark()`를 `AppTheme.light`/`AppTheme.dark`로 바꾼다.

- [ ] **Step 6: 커밋**

```bash
git add lib/theme/ test/theme/ lib/app.dart
git commit -m "feat(theme): Material 3 color scheme with light/dark support"
```

---

## Task 20: 악보 에셋 다크모드 대응

**이 태스크가 다크모드의 핵심 난제다.** 오선지 음표·임시표·높은음자리표 PNG는 모두 **검은색 그림**이라, 다크모드에서 어두운 배경에 검은 음표가 그려져 보이지 않는다.

**Files:**
- Modify: `lib/ui/quiz/staff_view.dart`
- Create: `test/ui/staff_view_test.dart`

- [ ] **Step 1: 문제를 재현하는 테스트 작성**

`test/ui/staff_view_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/domain/problem.dart';
import 'package:intervalpractice/domain/staff_layout.dart';
import 'package:intervalpractice/theme/app_theme.dart';
import 'package:intervalpractice/ui/quiz/staff_view.dart';

Widget wrap(Widget child, ThemeData theme) => ScreenUtilInit(
  designSize: const Size(375, 844),
  builder: (context, _) => MaterialApp(theme: theme, home: Scaffold(body: child)),
);

void main() {
  final problem = IntervalProblem(
    lower: StaffLayout.byIndex(8),
    upper: StaffLayout.byIndex(12),
    accidentals: const ['sharp', 'none'],
  );

  testWidgets('다크 테마에서 악보 이미지에 색 필터가 적용된다', (tester) async {
    await tester.pumpWidget(wrap(StaffView(problem: problem), AppTheme.dark));
    await tester.pump();

    expect(find.byType(ColorFiltered), findsWidgets);
  });

  testWidgets('라이트 테마에서는 색 필터를 적용하지 않는다', (tester) async {
    await tester.pumpWidget(wrap(StaffView(problem: problem), AppTheme.light));
    await tester.pump();

    expect(find.byType(ColorFiltered), findsNothing);
  });
}
```

- [ ] **Step 2: 테스트 실패 확인**

```bash
flutter test test/ui/staff_view_test.dart
```

Expected: 첫 번째 테스트 FAIL — `findsWidgets` 실패 (ColorFiltered 없음)

- [ ] **Step 3: 색 반전 래퍼 구현**

`lib/ui/quiz/staff_view.dart`에 아래 위젯을 추가하고, 모든 `Image.asset(...)` 호출을 `_StaffImage(asset: ...)`로 교체한다.

```dart
/// 악보 에셋은 검은 선화(線畵)라 다크모드에서 배경에 묻힌다.
/// 다크 테마에서만 밝기를 반전시켜 흰 선화로 바꾼다.
class _StaffImage extends StatelessWidget {
  const _StaffImage({required this.asset, this.fit});

  final String asset;
  final BoxFit? fit;

  /// 밝기 반전 행렬 (RGB 반전, 알파 보존).
  static const _invert = ColorFilter.matrix(<double>[
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, fit: fit);

    if (Theme.of(context).brightness == Brightness.light) return image;

    return ColorFiltered(colorFilter: _invert, child: image);
  }
}
```

- [ ] **Step 4: 테스트 통과 확인**

```bash
flutter test test/ui/staff_view_test.dart
```

Expected: `All tests passed!`

- [ ] **Step 5: 육안 확인 — 자동 테스트로는 잡히지 않는 부분**

```bash
flutter run
```

기기 설정에서 다크모드를 켜고 문제 화면을 연다. 확인 항목:
- 오선 5줄이 배경과 구분되는가
- 음표 머리(흰 타원 + 검은 테두리)가 뭉개지지 않는가 — `whole_note_lean.png`는 반투명 영역이 있어 반전 시 어색할 수 있다
- 임시표(#, b)가 읽히는가
- 높은음자리표가 읽히는가

음표 머리가 어색하면 `whole_note_lean_all_white.png`(이미 존재하는 흰색 버전)를 다크모드에서 쓰도록 분기한다.

- [ ] **Step 6: 커밋**

```bash
git add lib/ui/quiz/staff_view.dart test/ui/staff_view_test.dart
git commit -m "fix(ui): invert staff artwork in dark mode so notation stays legible"
```

---

## Task 21: 홈·결과·설정 화면 테마 적용 및 하드코딩 색 제거

**Files:**
- Modify: `lib/ui/home/home_page.dart`, `lib/ui/result/result_page.dart`, `lib/ui/settings/settings_page.dart`, `lib/ui/common/loading_page.dart`

- [ ] **Step 1: 남아있는 하드코딩 색상 전수 조사**

```bash
grep -rn "Color(0x\|Colors\.\(white\|black\|grey\|yellow\|red\)" lib/ui/ lib/app.dart
```

- [ ] **Step 2: 각 항목을 테마 색으로 교체**

| 발견되는 패턴 | 교체 대상 |
|---|---|
| `backgroundColor: Colors.white` | 제거 (Scaffold 기본값이 `colorScheme.surface`) |
| `Colors.grey[700]` (버튼 텍스트) | `Theme.of(context).colorScheme.onSurfaceVariant` |
| `Colors.yellow[200]` (오답 다시풀기 버튼) | `Theme.of(context).colorScheme.secondaryContainer` |
| `Color(0xffdedede)` (타일 테두리) | `Theme.of(context).colorScheme.outlineVariant` |
| `Color(0xff3f8a36)` (Easy 탭) | `Theme.of(context).colorScheme.primary` |
| `Color(0xffc94040)` (Hard 탭) | `Theme.of(context).colorScheme.tertiary` |
| `TextStyle(color: Colors.black54)` | 제거 (테마 기본값 사용) |

- [ ] **Step 3: 재조사로 잔여 항목 0 확인**

```bash
grep -rn "Color(0x" lib/ui/ | grep -v "^lib/theme/"
```

Expected: 출력 없음.

- [ ] **Step 4: 라이트/다크 양쪽 육안 확인**

```bash
flutter run
```

홈 → Easy 1 → 10문제 완주 → 결과 화면 → 오답 다시 풀기 → 설정 화면 경로를 **라이트/다크 각각** 한 번씩 통과한다.

- [ ] **Step 5: 전체 검증 및 커밋**

```bash
flutter analyze && flutter test
```

Expected: `No issues found!` / `All tests passed!`

```bash
git add -A
git commit -m "style(ui): route all colors through ColorScheme, remove hardcoded values"
```

---

# Phase 5 — CI/CD (GitHub Actions)

## Task 22: 검증 파이프라인 (PR + push)

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: 워크플로 작성**

`.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [master, 'revival/**']
  pull_request:
    branches: [master]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

env:
  FLUTTER_VERSION: '3.44.2'

jobs:
  analyze-and-test:
    name: Analyze & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Verify formatting
        run: dart format --output=none --set-exit-if-changed lib test

      - name: Analyze
        run: flutter analyze --no-fatal-infos

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/lcov.info

  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    needs: analyze-and-test
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - run: flutter pub get

      # key.properties가 없으므로 debug 서명으로 폴백된다 (Task 5 Step 1 참조).
      - name: Build release APK (unsigned verification build)
        run: flutter build apk --release

  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: analyze-and-test
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - run: flutter pub get

      - name: Build iOS (no codesign)
        run: flutter build ios --release --no-codesign
```

- [ ] **Step 2: 포맷 검사가 통과하도록 코드 정렬**

```bash
dart format lib test
```

- [ ] **Step 3: 로컬에서 CI 단계를 그대로 재현**

```bash
dart format --output=none --set-exit-if-changed lib test && \
flutter analyze --no-fatal-infos && \
flutter test
```

Expected: 세 명령 모두 성공 (exit code 0).

- [ ] **Step 4: 커밋 및 푸시하여 CI 확인**

```bash
git add .github/workflows/ci.yml
git add -A
git commit -m "ci: add analyze/test/build pipeline for PRs and pushes"
git push -u origin revival/2026-modernization
```

- [ ] **Step 5: GitHub에서 워크플로 결과 확인**

```bash
gh run watch
```

Expected: 세 job 모두 초록색. 실패하면 로그를 보고 수정한 뒤 다시 푸시한다.

---

## Task 23: Android 릴리즈 배포 워크플로

**Files:**
- Create: `.github/workflows/release-android.yml`

- [ ] **Step 1: GitHub Secrets 등록**

로컬 키스토어를 base64로 인코딩한다 (출력이 길므로 클립보드로 바로 보낸다):

```bash
base64 -i android/app/key.jks | pbcopy
```

GitHub 저장소 → Settings → Secrets and variables → Actions에 아래를 등록한다:

| Secret 이름 | 값 |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | 위에서 복사한 base64 문자열 |
| `ANDROID_KEY_ALIAS` | `android/app/key.properties`의 `keyAlias` 값 |
| `ANDROID_KEY_PASSWORD` | `keyPassword` 값 |
| `ANDROID_STORE_PASSWORD` | `storePassword` 값 |
| `PLAY_SERVICE_ACCOUNT_JSON` | Play Console 서비스 계정 JSON 전체 |

`PLAY_SERVICE_ACCOUNT_JSON`은 Google Cloud Console에서 서비스 계정을 만들고, Play Console → 사용자 및 권한에서 해당 계정에 "릴리스 관리자" 권한을 부여한 뒤 받은 JSON 키다.

값 확인용 (터미널에만 출력, 커밋 금지):

```bash
cat android/app/key.properties
```

- [ ] **Step 2: 워크플로 작성**

`.github/workflows/release-android.yml`:

```yaml
name: Release Android

on:
  push:
    tags: ['v*']
  workflow_dispatch:
    inputs:
      track:
        description: 'Play track'
        required: true
        default: internal
        type: choice
        options: [internal, alpha, beta, production]

env:
  FLUTTER_VERSION: '3.44.2'

jobs:
  release:
    name: Build & Upload AAB
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Restore keystore
        run: echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/key.jks

      - name: Write key.properties
        run: |
          cat > android/app/key.properties <<EOF
          storePassword=${{ secrets.ANDROID_STORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=./key.jks
          EOF

      - run: flutter pub get

      - name: Build App Bundle
        run: flutter build appbundle --release

      - name: Verify the bundle is signed with the upload key
        run: |
          FINGERPRINT=$(keytool -list -v \
            -keystore android/app/key.jks \
            -alias "${{ secrets.ANDROID_KEY_ALIAS }}" \
            -storepass "${{ secrets.ANDROID_STORE_PASSWORD }}" \
            | grep 'SHA1:' | head -1)
          echo "Signing key $FINGERPRINT"

      - name: Upload to Play Console
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.nowaa.intervalpractice
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: ${{ inputs.track || 'internal' }}
          status: completed

      - name: Clean up secrets from runner
        if: always()
        run: rm -f android/app/key.jks android/app/key.properties
```

- [ ] **Step 3: 서명 검증 — 업로드 키가 기존 키와 같은지 확인**

Play Console에 이미 등록된 앱은 **업로드 키가 바뀌면 거부된다.** 로컬 키의 지문이 Play Console에 등록된 것과 같아야 한다.

```bash
cd android/app
ALIAS=$(grep '^keyAlias' key.properties | cut -d= -f2-)
SP=$(grep '^storePassword' key.properties | cut -d= -f2-)
keytool -list -v -keystore key.jks -alias "$ALIAS" -storepass "$SP" | grep -E "SHA1:|SHA256:"
cd ../..
```

이 지문을 Play Console → 설정 → 앱 무결성 → 앱 서명 → **업로드 키 인증서**의 지문과 대조한다.

Expected: SHA1 `E5:1D:6A:6F:45:E2:4D:98:14:A9:10:28:CD:5B:6B:B7:DA:7C:C7:93` 와 일치.

**일치하지 않으면 여기서 중단하고** 사용자에게 알린다. 잘못된 키로 업로드하면 Play가 거부하며, 키 재설정에는 구글 지원 요청이 필요하다.

- [ ] **Step 4: 내부 테스트 트랙으로 시험 배포**

```bash
git add .github/workflows/release-android.yml
git commit -m "ci: add Android release workflow uploading to Play internal track"
git push
gh workflow run release-android.yml -f track=internal
gh run watch
```

Expected: 워크플로 성공 + Play Console 내부 테스트 트랙에 새 버전이 나타남.

---

## Task 24: iOS 릴리즈 배포 워크플로

> **선행 조건:** 이 태스크는 사용자가 App Store Connect API Key(`.p8`), 배포 인증서(`.p12`), 프로비저닝 프로파일(`.mobileprovision`)을 제공해야 진행할 수 있다. `keyfiles/`에는 안드로이드 자산만 있었다. **자산을 받기 전에는 이 태스크를 시작하지 말 것.**

**Files:**
- Create: `.github/workflows/release-ios.yml`
- Create: `ios/ExportOptions.plist`

- [ ] **Step 1: GitHub Secrets 등록**

| Secret 이름 | 설명 |
|---|---|
| `IOS_CERTIFICATE_BASE64` | 배포 인증서 `.p12`를 base64 인코딩 |
| `IOS_CERTIFICATE_PASSWORD` | `.p12` 내보낼 때 설정한 암호 |
| `IOS_PROVISIONING_PROFILE_BASE64` | `.mobileprovision`을 base64 인코딩 |
| `APPSTORE_ISSUER_ID` | App Store Connect API 발급자 ID |
| `APPSTORE_KEY_ID` | API 키 ID |
| `APPSTORE_PRIVATE_KEY` | `.p8` 파일 내용 전체 |
| `KEYCHAIN_PASSWORD` | CI 임시 키체인용 아무 문자열 |

```bash
base64 -i /path/to/dist.p12 | pbcopy
base64 -i /path/to/profile.mobileprovision | pbcopy
```

- [ ] **Step 2: ExportOptions.plist 작성**

`ios/ExportOptions.plist` — `TEAM_ID`와 프로파일 이름은 사용자가 제공한 값으로 채운다.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store-connect</string>
	<key>teamID</key>
	<string>REPLACE_WITH_TEAM_ID</string>
	<key>uploadSymbols</key>
	<true/>
	<key>signingStyle</key>
	<string>manual</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>com.nowaa.intervalpractice</key>
		<string>REPLACE_WITH_PROFILE_NAME</string>
	</dict>
</dict>
</plist>
```

- [ ] **Step 3: 워크플로 작성**

`.github/workflows/release-ios.yml`:

```yaml
name: Release iOS

on:
  push:
    tags: ['v*']
  workflow_dispatch:

env:
  FLUTTER_VERSION: '3.44.2'

jobs:
  release:
    name: Build & Upload to TestFlight
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          channel: stable
          cache: true

      - name: Install signing certificate and profile
        env:
          CERT_BASE64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          CERT_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          PROFILE_BASE64: ${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          CERT_PATH=$RUNNER_TEMP/cert.p12
          PROFILE_PATH=$RUNNER_TEMP/profile.mobileprovision
          KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db

          echo -n "$CERT_BASE64" | base64 --decode -o $CERT_PATH
          echo -n "$PROFILE_BASE64" | base64 --decode -o $PROFILE_PATH

          security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security import $CERT_PATH -P "$CERT_PASSWORD" -A \
            -t cert -f pkcs12 -k $KEYCHAIN_PATH
          security set-key-partition-list -S apple-tool:,apple: \
            -k "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
          security list-keychain -d user -s $KEYCHAIN_PATH

          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          cp $PROFILE_PATH ~/Library/MobileDevice/Provisioning\ Profiles/

      - run: flutter pub get

      - name: Build IPA
        run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v3
        with:
          app-path: build/ios/ipa/intervalpractice.ipa
          issuer-id: ${{ secrets.APPSTORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APPSTORE_KEY_ID }}
          api-private-key: ${{ secrets.APPSTORE_PRIVATE_KEY }}

      - name: Clean up keychain
        if: always()
        run: security delete-keychain $RUNNER_TEMP/app-signing.keychain-db || true
```

- [ ] **Step 4: 시험 실행**

```bash
git add .github/workflows/release-ios.yml ios/ExportOptions.plist
git commit -m "ci: add iOS release workflow uploading to TestFlight"
git push
gh workflow run release-ios.yml
gh run watch
```

Expected: 워크플로 성공 + App Store Connect의 TestFlight에 빌드가 나타남 (처리에 10~30분 소요).

IPA 파일명이 다르면 아래로 확인해 `app-path`를 고친다:

```bash
ls build/ios/ipa/
```

---

# Phase 6 — 재출시

## Task 25: 버전 상향 및 스토어 제출

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 버전 상향**

`pubspec.yaml`의 version 줄을 교체한다. 대규모 리팩토링이므로 마이너 버전을 올린다.

```yaml
version: 1.1.0+6
```

빌드 번호(`+6`)는 기존 `+5`보다 반드시 커야 한다. 두 스토어 모두 빌드 번호 역행을 거부한다.

- [ ] **Step 2: 최종 검증**

```bash
flutter clean && flutter pub get && flutter analyze && flutter test
```

Expected: `No issues found!` / `All tests passed!`

- [ ] **Step 3: 양 플랫폼 릴리즈 빌드 확인**

```bash
flutter build appbundle --release
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

Expected: 두 빌드 모두 성공.

- [ ] **Step 4: 제출 전 체크리스트**

각 항목을 실제로 확인한다.

- [ ] Android `targetSdk 36` 적용됨 — `grep targetSdk android/app/build.gradle`
- [ ] Android 업로드 키 지문이 Play Console 등록값과 일치 (Task 23 Step 3)
- [ ] iOS `PrivacyInfo.xcprivacy`가 번들에 포함됨 — `unzip -l build/ios/ipa/*.ipa | grep -i privacyinfo`
- [ ] iOS `NSUserTrackingUsageDescription` 문구 존재 — `grep -A1 NSUserTracking ios/Runner/Info.plist`
- [ ] AdMob 앱 ID가 실 ID임 — `grep -A1 "APPLICATION_ID" android/app/src/main/AndroidManifest.xml`, `grep -A1 GADApplicationIdentifier ios/Runner/Info.plist`
- [ ] 릴리즈 빌드에서 테스트 광고가 아닌 실 광고 ID가 쓰임 (`AdIds`는 `kReleaseMode`로 분기)
- [ ] Play Console 데이터 보안 양식이 현재 SDK 구성과 일치 (Firebase 제거됐으므로 **Analytics 관련 항목을 내려야 한다**)
- [ ] App Store 개인정보 보고서가 현재 구성과 일치
- [ ] 라이트/다크 모드 양쪽에서 6개 문제 유형이 정상 동작 (Task 21 Step 4)

- [ ] **Step 5: 태그를 눌러 양 스토어 배포 트리거**

```bash
git tag v1.1.0
git push origin v1.1.0
gh run watch
```

Expected: `Release Android`, `Release iOS` 워크플로가 모두 성공.

- [ ] **Step 6: 브랜치 병합**

```bash
git checkout master
git merge --no-ff revival/2026-modernization
git push origin master
```

---

## 부록: 사용자 확인이 필요한 항목

구현 중 아래 지점에서는 진행 전에 사용자에게 확인해야 한다.

1. **Task 23 Step 3** — 업로드 키 지문이 Play Console 등록값과 다를 경우. 잘못 올리면 되돌리기 어렵다.
2. **Task 24 착수 전** — Apple 배포 자산(`.p8`, `.p12`, `.mobileprovision`, Team ID, 프로파일 이름)이 아직 없다.
3. **Task 25 Step 4** — Play Console 데이터 보안 양식과 App Store 개인정보 보고서는 콘솔에서 수동으로 갱신해야 한다. Firebase Analytics를 제거했으므로 기존 신고 내용이 실제와 어긋난다.
