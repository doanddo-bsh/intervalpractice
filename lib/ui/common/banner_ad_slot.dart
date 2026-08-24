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
