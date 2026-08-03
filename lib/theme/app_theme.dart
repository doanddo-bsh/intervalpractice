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
    final scheme = ColorScheme.fromSeed(
      seedColor: _easySeed,
      brightness: brightness,
      // 다크 테마의 surface/onSurface 대비를 WCAG AA(4.5:1) 이상으로
      // 끌어올리기 위해 표준(0.0)보다 높은 대비 레벨을 사용한다.
      contrastLevel: brightness == Brightness.dark ? 1.0 : 0.0,
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
