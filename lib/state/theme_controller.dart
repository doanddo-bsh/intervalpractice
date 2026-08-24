import 'package:async_preferences/async_preferences.dart';
import 'package:flutter/material.dart';

/// 앱의 밝기 모드를 들고 있고, 선택을 기기에 저장한다.
///
/// 기본값은 [ThemeMode.light] — 이 앱은 원래 라이트 전용이었고 악보를
/// 검은 선화로 그리므로, 설치 직후 모습은 기존 사용자에게 익숙한 밝은
/// 화면으로 둔다. OS가 다크여도 마찬가지다.
///
/// 사용자가 토글로 [ThemeMode.system] 을 고르면 그때부터 OS 설정을
/// 따라가고, 그 선택은 저장되어 유지된다.
final class ThemeController extends ChangeNotifier {
  ThemeController({AsyncPreferences? preferences})
      : _preferences = preferences ?? AsyncPreferences();

  /// 저장 키. 값은 [ThemeMode.index] 를 그대로 쓴다.
  static const _storageKey = 'themeMode';

  final AsyncPreferences _preferences;

  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  /// 저장된 선택을 불러온다. 앱 시작 시 한 번 호출한다.
  ///
  /// 저장된 값이 없거나 범위를 벗어나면 기본값([ThemeMode.light])을 유지한다.
  Future<void> load() async {
    final stored = await _preferences.getInt(_storageKey);
    if (stored == null || stored < 0 || stored >= ThemeMode.values.length) {
      return;
    }

    _mode = ThemeMode.values[stored];
    notifyListeners();
  }

  /// 라이트 → 다크 → 시스템 → 라이트 순으로 돌린다.
  ///
  /// 기본값이 라이트이므로 라이트에서 시작한다. 시스템 설정을 따르고
  /// 싶은 사용자는 두 번 눌러 도달할 수 있다.
  Future<void> cycle() => setMode(switch (_mode) {
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
        ThemeMode.system => ThemeMode.light,
      });

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;

    _mode = mode;
    notifyListeners();
    await _preferences.setInt(_storageKey, mode.index);
  }

  /// 현재 모드를 나타내는 아이콘.
  IconData get icon => switch (_mode) {
        ThemeMode.system => Icons.brightness_auto_outlined,
        ThemeMode.light => Icons.light_mode_outlined,
        ThemeMode.dark => Icons.dark_mode_outlined,
      };

  /// 접근성 레이블 겸 툴팁 문구.
  String get label => switch (_mode) {
        ThemeMode.system => '화면 모드: 시스템 설정',
        ThemeMode.light => '화면 모드: 밝게',
        ThemeMode.dark => '화면 모드: 어둡게',
      };
}
