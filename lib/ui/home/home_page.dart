import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:async_preferences/async_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../ads/ad_ids.dart';
import '../../ads/ad_service.dart';
import '../../domain/problem_mode.dart';
import '../../state/ad_counter.dart';
import '../common/banner_ad_slot.dart';
import '../common/line_art_image.dart';
import '../quiz/quiz_page.dart';
import '../settings/settings_page.dart';

/// 난이도 탭 + 문제 유형 목록. 기존 firstProblemTypeList.dart를 대체한다.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

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

  /// GDPR 대상 사용자에게만 개인정보 재설정 버튼을 노출한다.
  late final Future<bool> _showPrivacySettings = _isUnderGdpr();

  @override
  void initState() {
    super.initState();
    _interstitial.preload();

    // 지시선 색이 선택된 탭을 따라가므로 탭 전환 시 다시 그려야 한다.
    _tabController.addListener(_onTabChanged);

    // Apple은 IDFA 접근 전 ATT 동의를 요구한다. 첫 프레임 이후에 띄워야
    // 시스템 다이얼로그가 정상 표시된다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestTracking());
  }

  /// iOS 앱 추적 투명성(ATT) 동의 요청.
  ///
  /// 이 호출이 없으면 iOS에서 IDFA를 얻지 못해 광고 단가가 크게 떨어지고,
  /// 심사에서 지적될 수 있다. Android에서는 무해한 no-op이다.
  Future<void> _requestTracking() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // 다이얼로그가 곧바로 뜨면 무시되는 사례가 있어 한 박자 늦춘다.
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
      await AppTrackingTransparency.getAdvertisingIdentifier();
    } on PlatformException catch (error) {
      debugPrint('ATT request failed: $error');
    }
  }

  /// 사용자가 GDPR 적용 지역에 있는지 판별한다. 개인정보 재설정 버튼의
  /// 노출 여부를 결정한다.
  Future<bool> _isUnderGdpr() async {
    final preferences = AsyncPreferences();
    return await preferences.getInt('IABTCF_gdprApplies') == 1;
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _interstitial.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
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
              // 색을 지정하지 않으면 BorderSide 기본값이 검정이라,
              // 다크모드에서 지시선이 배경에 묻혀 구분선이 끊긴 것처럼
              // 보인다. 선택된 탭의 강조색을 따라가게 한다.
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2,
                  color: _tabController.index == 0
                      ? colors.primary
                      : colors.tertiary,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 40),
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
            FutureBuilder<bool>(
              future: _showPrivacySettings,
              builder: (context, snapshot) {
                return _BottomActions(
                  showPrivacySettings: snapshot.data ?? false,
                );
              },
            ),
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
                  child: LineArtImage(asset: iconAsset),
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
