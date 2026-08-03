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
