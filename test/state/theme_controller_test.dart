import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:intervalpractice/state/theme_controller.dart';

void main() {
  // AsyncPreferences 는 플랫폼 채널을 쓰므로 테스트에서 가짜 응답을 준다.
  const channel = MethodChannel('async_preferences');
  late Map<String, Object?> store;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    store = <String, Object?>{};

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      // async_preferences 2.0.0 규약: invokeMethod('get_int', [file, id])
      // / invokeMethod('set_int', [file, id, value]) — Map 이 아니라 List 다.
      final args = (call.arguments as List?) ?? const [];
      final key = args.length > 1 ? args[1] as String : '';

      return switch (call.method) {
        'get_int' => store[key],
        'set_int' => () {
            store[key] = args[2];
            return true;
          }(),
        _ => null,
      };
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('기본값은 라이트다', () {
    expect(ThemeController().mode, ThemeMode.light);
  });

  test('라이트 → 다크 → 시스템 → 라이트 순으로 돈다', () async {
    final controller = ThemeController();

    await controller.cycle();
    expect(controller.mode, ThemeMode.dark);

    await controller.cycle();
    expect(controller.mode, ThemeMode.system);

    await controller.cycle();
    expect(controller.mode, ThemeMode.light);
  });

  test('바뀌면 리스너에게 알린다', () async {
    final controller = ThemeController();
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.cycle();
    expect(notified, 1);
  });

  test('같은 값으로 다시 설정하면 알리지 않는다', () async {
    final controller = ThemeController();
    var notified = 0;
    controller.addListener(() => notified++);

    await controller.setMode(ThemeMode.light);
    expect(notified, 0);
  });

  test('선택이 저장되고 다시 불러와진다', () async {
    await ThemeController().setMode(ThemeMode.dark);

    // 새 인스턴스가 저장된 값을 읽어온다.
    final restored = ThemeController();
    expect(restored.mode, ThemeMode.light, reason: 'load 전에는 기본값');

    await restored.load();
    expect(restored.mode, ThemeMode.dark);
  });

  test('저장된 값이 없으면 라이트를 유지한다 (OS가 다크여도)', () async {
    final controller = ThemeController();
    await controller.load();

    expect(controller.mode, ThemeMode.light);
  });

  test('저장된 값이 범위를 벗어나면 무시한다', () async {
    store['themeMode'] = 99;

    final controller = ThemeController();
    await controller.load();

    expect(controller.mode, ThemeMode.light);
  });

  test('사용자가 시스템 설정을 고르면 그것도 저장된다', () async {
    final controller = ThemeController();
    await controller.setMode(ThemeMode.system);

    final restored = ThemeController();
    await restored.load();
    expect(restored.mode, ThemeMode.system);
  });

  test('모드마다 다른 아이콘과 문구를 준다', () async {
    final controller = ThemeController();
    final seenIcons = <IconData>{};
    final seenLabels = <String>{};

    for (var i = 0; i < 3; i++) {
      seenIcons.add(controller.icon);
      seenLabels.add(controller.label);
      await controller.cycle();
    }

    expect(seenIcons, hasLength(3));
    expect(seenLabels, hasLength(3));
  });
}
