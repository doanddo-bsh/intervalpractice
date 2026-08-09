// integration_test 가 `binding.takeScreenshot()` 으로 찍은 화면을 파일로 저장한다.
//
// 실행:
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/quiz_flow_test.dart \
//     -d <device-id>
//
// 산출물: screenshots/<name>.png
//
// ---------------------------------------------------------------------------
// 주의 — 이 앱에서는 안드로이드 스크린샷이 동작하지 않는다
// ---------------------------------------------------------------------------
// 안드로이드에서 `takeScreenshot()` 을 쓰려면 먼저
// `binding.convertFlutterSurfaceToImage()` 를 호출해야 하는데, 이 앱은
// 모든 화면 하단에 AdMob 배너(`AdWidget`)를 띄운다. 배너는 **플랫폼 뷰**라
// 이미지 백엔드 서피스와 공존하지 못하고, 실제로 시도하면 앱 프로세스가
// 죽으면서 드라이버가 다음 오류를 낸다:
//
//   DriverError: Failed to fulfill RequestData due to remote error
//   Original error: ext.flutter.driver: (112) Service has disappeared
//
// 그래서 `integration_test/quiz_flow_test.dart` 는 스크린샷을 찍지 않는다.
// 실기기에서는 **동작**을 검증하고(탭 → 채점 → 결과 시트 → 다음 문제),
// **모양**은 아래 두 가지로 확인한다:
//
//   - `test/ui/quiz_modes_golden_test.dart` — 6개 모드 × 라이트/다크 렌더
//   - iOS 시뮬레이터에서 `xcrun simctl io <id> screenshot`
//
// 이 드라이버는 향후 배너를 걷어낸 화면을 찍고 싶을 때를 위해 남겨둔다.
// ---------------------------------------------------------------------------
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String name, List<int> bytes,
        [Map<String, Object?>? args]) async {
      final file = File('screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      stdout.writeln('saved screenshots/$name.png (${bytes.length} bytes)');
      return true;
    },
  );
}
