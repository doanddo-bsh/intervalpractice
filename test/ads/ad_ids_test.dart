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
