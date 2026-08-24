import 'package:flutter/foundation.dart';

/// 전면광고 노출 시점을 정하기 위해 누적 푼 문제 수를 센다.
final class AdCounter extends ChangeNotifier {
  int _solvedCount = 0;

  int get solvedCount => _solvedCount;

  void increment() {
    _solvedCount++;
    notifyListeners();
  }

  void reset() {
    _solvedCount = 0;
    notifyListeners();
  }
}
