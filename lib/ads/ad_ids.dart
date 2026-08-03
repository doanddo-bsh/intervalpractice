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
