import 'package:flutter/material.dart';

/// 검은 선화(線畵) 에셋을 다크 테마에서 흰 선화로 뒤집어 그린다.
///
/// 이 앱의 그림 에셋(높은음자리표, 음표머리, 임시표, 홈 화면 타일 아이콘)은
/// 전부 투명 배경 위 검은 선화다. 다크 테마에서 그대로 그리면 어두운 배경에
/// 묻혀 사실상 보이지 않는다 — 실측으로 홈 화면 아이콘의 대비가 라이트
/// 16.67:1 에서 다크 1.74:1 로 떨어졌다(그래픽 최소 권장은 3:1).
///
/// 알파 채널은 보존하므로, `whole_note_lean.png`처럼 가운데가 뚫린
/// (알파 0) 에셋은 뚫린 부분이 그대로 투명하게 남아 오선/덧줄이 비쳐 보인다.
class LineArtImage extends StatelessWidget {
  const LineArtImage({
    super.key,
    required this.asset,
    this.height,
    this.width,
    this.fit,
  });

  final String asset;
  final double? height;
  final double? width;
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
    final image = Image.asset(asset, height: height, width: width, fit: fit);

    if (Theme.of(context).brightness == Brightness.light) return image;

    return ColorFiltered(colorFilter: _invert, child: image);
  }
}
