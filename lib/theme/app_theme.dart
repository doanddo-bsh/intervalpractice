import 'package:flutter/material.dart';

/// 앱 전역 Material 3 테마.
///
/// 기존 `colorList.dart`의 하드코딩된 8개 색을 M3 ColorScheme 역할로
/// 이관했다:
///
/// | 기존 | 의미 | M3 대응 |
/// |---|---|---|
/// | `color1` `#63af5b` (녹색) | easy 강조 | `primary` (시드) |
/// | `color2` `#e36d3f` (주황) | hard 강조 | `tertiary` |
/// | `color4/5` (녹색 계열) | 정답 시트 | `primaryContainer` / `onPrimaryContainer` |
/// | `color6/7` (적갈색) | 오답 시트 | `errorContainer` / `onErrorContainer` |
/// | `color8` `#dedede` | 타일 테두리 | `outlineVariant` |
abstract final class AppTheme {
  /// easy 난이도 강조색 (기존 color1).
  static const _easySeed = Color(0xff63af5b);

  /// hard 난이도 강조색 (기존 color2).
  static const _hardSeed = Color(0xffe36d3f);

  // ---------------------------------------------------------------
  // 원본 앱 팔레트
  //
  // M3 ColorScheme 이 뽑아주는 색보다 원본 조합이 보기 좋다는 판단에
  // 따라, 정답 버튼과 결과 시트는 아래 고정색을 쓴다.
  // (구 `colorList.dart` 및 각 문제 화면에서 그대로 가져왔다.)
  // ---------------------------------------------------------------

  /// 정답 버튼 배경 (선택되지 않은 상태).
  static const answerButtonBackground = Color(0xfffdfdfd);

  /// 정답 버튼 배경 (선택된 상태).
  static const answerButtonSelected = Color(0xffdadada);

  /// 정답 버튼 글자색.
  static const answerButtonText = Colors.black54;

  /// easy 난이도 강조 (버튼 잉크, 진행바).
  static const easyAccent = _easySeed;

  /// hard 난이도 강조.
  static const hardAccent = _hardSeed;

  /// 유형 2의 "주어진 음정" 강조색 (구 explainTextStyle2).
  static const givenIntervalText = Color(0xff931919);

  /// 정답 시트 배경 / 글자 (구 color5 / color4).
  static const correctSheetBackground = Color(0xffacd0a8);
  static const correctSheetText = Color(0xff4b7947);

  /// 오답 시트 배경 / 글자 (구 하드코딩값 / color6).
  static const wrongSheetBackground = Color(0xffd7b1b1);
  static const wrongSheetText = Color(0xff79474e);

  /// 스플래시 화면 전용 브랜드 고정 색상.
  ///
  /// [LoadingPage]는 앱 실행 즉시(테마/시스템 다크모드 판단 이전) 뜨는
  /// 화면이라 라이트/다크 전환과 무관하게 고정 브랜드 색을 쓴다. 다른 모든
  /// 화면과 달리 `ColorScheme`을 참조하지 않는 유일한 예외이므로, 색상값
  /// 자체는 여기 한 곳에만 남겨 둔다.
  static const splashBackground = Color(0xffd1e0ba);
  static const splashForeground = Color(0xff373f2c);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    // contrastLevel 은 기본값(0.0)을 쓴다.
    //
    // 한때 다크 테마에 1.0(최대 대비)을 넣었는데, 실기기에서 보니
    // 정답/오답 시트가 **밝은 파스텔 패널**로 나와 어두운 화면에서 눈에
    // 튀었다. 최대 대비 모드는 컨테이너 색을 밝게 뒤집기 때문이다:
    //
    //   contrastLevel 1.0 → errorContainer #ffaea4 (휘도 0.542, 밝은 분홍)
    //   contrastLevel 0.0 → errorContainer #93000a (휘도 0.062, 어두운 빨강)
    //
    // 애초에 필요하지도 않았다. 기본값에서도 surface/onSurface 대비가
    // 14.4:1 로 WCAG AA(4.5:1)를 세 배 넘게 통과한다.
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
      scaffoldBackgroundColor: scheme.surface,
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
