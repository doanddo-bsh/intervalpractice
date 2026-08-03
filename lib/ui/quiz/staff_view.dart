import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_notes/music_notes.dart';

import '../../domain/problem.dart';
import '../../domain/staff_layout.dart';
import '../common/line_art_image.dart';

/// 높은음자리표 오선지에 문제의 두 음을 그린다.
class StaffView extends StatelessWidget {
  const StaffView(
      {super.key, required this.problem, this.hideUpperNote = false});

  final IntervalProblem problem;

  /// 유형 2(계이름 맞히기)에서 정답이 되는 음을 가린다.
  final bool hideUpperNote;

  static const _lineTops = [90.0, 116.5, 143.0, 169.5, 196.0];
  static const _firstNoteLeft = 130.0;
  static const _secondNoteLeft = 230.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0.h,
            bottom: 0.h,
            left: 10.0.w,
            child: Align(
              alignment: Alignment.centerLeft,
              child: LineArtImage(
                asset: 'assets/treble_clef_ff_cut.png',
                height: 180.h,
              ),
            ),
          ),
          for (final top in _lineTops) _StaffLine(top: top),
          _NoteHead(slot: problem.lower, left: _firstNoteLeft),
          _LedgerLineBelow(slot: problem.lower, left: _firstNoteLeft.w),
          _Accidental(
            kind: problem.accidentals[0],
            top: problem.lower.top,
            left: _firstNoteLeft.w,
          ),
          if (!hideUpperNote) ...[
            _NoteHead(slot: problem.upper, left: _secondNoteLeft),
            _LedgerLineBelow(slot: problem.upper, left: _secondNoteLeft.w),
            _Accidental(
              kind: problem.accidentals[1],
              top: problem.upper.top,
              left: _secondNoteLeft.w,
            ),
          ],
        ],
      ),
    );
  }
}

class _StaffLine extends StatelessWidget {
  const _StaffLine({required this.top});

  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top.h,
      left: 10.w,
      right: 10.w,
      child: Container(
        color: Theme.of(context).colorScheme.onSurface,
        height: 2.0.h,
      ),
    );
  }
}

class _NoteHead extends StatelessWidget {
  const _NoteHead({required this.slot, required this.left});

  final StaffSlot slot;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: slot.top.h,
      left: left.w,
      child: SizedBox(
        height: 26.5.h,
        child: Stack(
          children: [
            const LineArtImage(asset: 'assets/whole_note_lean.png'),
            _LedgerLineThrough(slot: slot),
          ],
        ),
      ),
    );
  }
}

/// 음표를 관통하는 덧줄 (기존 addLine1).
class _LedgerLineThrough extends StatelessWidget {
  const _LedgerLineThrough({required this.slot});

  final StaffSlot slot;

  static final _middle = {
    Note.a.inOctave(5),
    Note.f.inOctave(5),
    Note.d.inOctave(5),
    Note.b.inOctave(4),
    Note.g.inOctave(4),
    Note.e.inOctave(4),
    Note.c.inOctave(4),
    Note.a.inOctave(3),
    Note.c.inOctave(6),
  };
  static final _low = {Note.b.inOctave(5), Note.d.inOctave(6)};
  static final _high = {Note.b.inOctave(3), Note.g.inOctave(3)};

  @override
  Widget build(BuildContext context) {
    final double? top = switch (slot.pitch) {
      final p when _middle.contains(p) => 12.75,
      final p when _low.contains(p) => 24.5,
      final p when _high.contains(p) => 0.0,
      _ => null,
    };

    if (top == null) return const SizedBox.shrink();

    return Positioned(top: top.h, child: const _LedgerLine());
  }
}

/// 오선 밖 음의 추가 덧줄 (기존 addLine2/addLine3).
class _LedgerLineBelow extends StatelessWidget {
  const _LedgerLineBelow({required this.slot, required this.left});

  final StaffSlot slot;
  final double left;

  static final _aboveStaff = {Note.d.inOctave(6), Note.c.inOctave(6)};
  static final _belowStaff = {Note.a.inOctave(3), Note.g.inOctave(3)};

  @override
  Widget build(BuildContext context) {
    final double? top = switch (slot.pitch) {
      final p when _aboveStaff.contains(p) => 63.5,
      final p when _belowStaff.contains(p) => 222.5,
      _ => null,
    };

    if (top == null) return const SizedBox.shrink();

    return Positioned(top: top.h, left: left, child: const _LedgerLine());
  }
}

class _LedgerLine extends StatelessWidget {
  const _LedgerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.onSurface,
      height: 2.0.h,
      width: 50.w,
    );
  }
}

/// 임시표 이미지 (기존 addAccidentals).
class _Accidental extends StatelessWidget {
  const _Accidental({
    required this.kind,
    required this.top,
    required this.left,
  });

  final String kind;
  final double top;
  final double left;

  @override
  Widget build(BuildContext context) {
    final spec = switch (kind) {
      'sharp' => (
          asset: 'assets/sharp2.png',
          dTop: -13.0,
          dLeft: -11.0,
          h: 54.0,
          w: 47.0,
        ),
      'double sharp' => (
          asset: 'assets/doubleSharp.png',
          dTop: 3.5,
          dLeft: -2.0,
          h: 20.0,
          w: 20.0,
        ),
      'flat' => (
          asset: 'assets/flat2.png',
          dTop: -16.0,
          dLeft: 7.0,
          h: 41.0,
          w: 16.0,
        ),
      'double flat' => (
          asset: 'assets/doubleFlat.png',
          dTop: -17.5,
          dLeft: -7.5,
          h: 45.0,
          w: 30.0,
        ),
      _ => null,
    };

    if (spec == null) return const SizedBox.shrink();

    return Positioned(
      top: (top + spec.dTop).h,
      left: left + spec.dLeft.w,
      child: SizedBox(
        height: spec.h.h,
        width: spec.w.w,
        child: LineArtImage(asset: spec.asset, fit: BoxFit.fill),
      ),
    );
  }
}
