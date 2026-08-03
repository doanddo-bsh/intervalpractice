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
