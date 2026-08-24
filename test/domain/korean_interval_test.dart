import 'package:flutter_test/flutter_test.dart';
import 'package:music_notes/music_notes.dart';

import 'package:intervalpractice/domain/korean_interval.dart';

void main() {
  group('KoreanInterval.fromInterval', () {
    test('장3도를 "장3"으로 표기한다', () {
      final name = KoreanInterval.fromInterval(Interval.M3);
      expect(name, '장3');
    });

    test('완전5도를 "완전5"로 표기한다', () {
      final name = KoreanInterval.fromInterval(Interval.P5);
      expect(name, '완전5');
    });

    test('감5도를 "감5"로 표기한다', () {
      final name = KoreanInterval.fromInterval(Interval.d5);
      expect(name, '감5');
    });
  });

  group('KoreanInterval.toAbbreviation', () {
    test('"장"+"3"을 "M3"으로 변환한다', () {
      expect(KoreanInterval.toAbbreviation('장', '3'), 'M3');
    });

    test('"겹증"+"4"를 "AA4"로 변환한다', () {
      expect(KoreanInterval.toAbbreviation('겹증', '4'), 'AA4');
    });

    test('"겹감"+"7"을 "dd7"로 변환한다', () {
      expect(KoreanInterval.toAbbreviation('겹감', '7'), 'dd7');
    });
  });
}
