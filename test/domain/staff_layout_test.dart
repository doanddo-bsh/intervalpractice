import 'package:flutter_test/flutter_test.dart';
import 'package:music_notes/music_notes.dart';

import 'package:intervalpractice/domain/staff_layout.dart';

void main() {
  group('StaffLayout', () {
    test('19개 음자리를 갖는다 (G3 ~ D6)', () {
      expect(StaffLayout.slots, hasLength(19));
    });

    test('맨 위 자리는 D6이고 top=11.0이다', () {
      final first = StaffLayout.slots.first;
      expect(first.index, 0);
      expect(first.top, 11.0);
      expect(first.pitch, Note.d.inOctave(6));
    });

    test('맨 아래 자리는 G3이고 top=249.5이다', () {
      final last = StaffLayout.slots.last;
      expect(last.index, 18);
      expect(last.top, 249.5);
      expect(last.pitch, Note.g.inOctave(3));
    });

    test('index는 0부터 순차 증가한다', () {
      for (var i = 0; i < StaffLayout.slots.length; i++) {
        expect(StaffLayout.slots[i].index, i);
      }
    });

    test('인접한 자리의 간격은 13.25로 일정하다', () {
      for (var i = 1; i < StaffLayout.slots.length; i++) {
        final gap = StaffLayout.slots[i].top - StaffLayout.slots[i - 1].top;
        expect(gap, closeTo(13.25, 0.001));
      }
    });

    test('byIndex로 자리를 되찾을 수 있다', () {
      expect(StaffLayout.byIndex(8).pitch, Note.c.inOctave(5));
    });

    test('한글 계이름을 반환한다', () {
      expect(StaffLayout.koreanNameOf(Note.c.inOctave(4)), '도');
      expect(StaffLayout.koreanNameOf(Note.g.inOctave(5)), '솔');
    });
  });
}
