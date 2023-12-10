import 'package:music_notes/music_notes.dart';
Map intervalNameKorEng = {
  '감' : 'd',
  '완전' : 'P',
  '증' : 'A',
  '겹감' : 'dd',
  '단' : 'm',
  '장' : 'M',
  '겹증' : 'AA',
};

Map intervalNameEngKor = {
  'd':'감',
  'P':'완전',
  'A':'증',
  'dd':'겹감',
  'm':'단',
  'M':'장',
  'AA':'겹증',
};

Map pitchNameEngToKr = {
  Note.d.inOctave(6):'레',
  Note.c.inOctave(6):'도',
  Note.b.inOctave(5):'시',
  Note.a.inOctave(5):'라',
  Note.g.inOctave(5):'솔',
  Note.f.inOctave(5):'파',
  Note.e.inOctave(5):'미',
  Note.d.inOctave(5):'레',
  Note.c.inOctave(5):'도',
  Note.b.inOctave(4):'시',
  Note.a.inOctave(4):'라',
  Note.g.inOctave(4):'솔',
  Note.f.inOctave(4):'파',
  Note.e.inOctave(4):'미',
  Note.d.inOctave(4):'레',
  Note.c.inOctave(4):'도',
  Note.b.inOctave(3):'시',
  Note.a.inOctave(3):'라',
  Note.g.inOctave(3):'솔',
};

List<List<dynamic>> note_height_list_fix =
[
  // topheigh, number, note
  [11.00,0,Note.d.inOctave(6)],
  [24.25,1,Note.c.inOctave(6)],
  [37.50,2,Note.b.inOctave(5)],
  [50.75,3,Note.a.inOctave(5)],
  [64.00,4,Note.g.inOctave(5)],
  [77.25,5,Note.f.inOctave(5)],
  [90.50,6,Note.e.inOctave(5)],
  [103.75,7,Note.d.inOctave(5)],
  [117.00,8,Note.c.inOctave(5)],
  [130.25,9,Note.b.inOctave(4)],
  [143.50,10,Note.a.inOctave(4)],
  [156.75,11,Note.g.inOctave(4)],
  [170.00,12,Note.f.inOctave(4)],
  [183.25,13,Note.e.inOctave(4)],
  [196.50,14,Note.d.inOctave(4)],
  [209.75,15,Note.c.inOctave(4)],
  [223.00,16,Note.b.inOctave(3)],
  [236.25,17,Note.a.inOctave(3)],
  [249.50,18,Note.g.inOctave(3)],
];

List<List<dynamic>> note_height_list =
[
  // topheigh, number, note
  [11.00,0,Note.d.inOctave(6)],
  [24.25,1,Note.c.inOctave(6)],
  [37.50,2,Note.b.inOctave(5)],
  [50.75,3,Note.a.inOctave(5)],
  [64.00,4,Note.g.inOctave(5)],
  [77.25,5,Note.f.inOctave(5)],
  [90.50,6,Note.e.inOctave(5)],
  [103.75,7,Note.d.inOctave(5)],
  [117.00,8,Note.c.inOctave(5)],
  [130.25,9,Note.b.inOctave(4)],
  [143.50,10,Note.a.inOctave(4)],
  [156.75,11,Note.g.inOctave(4)],
  [170.00,12,Note.f.inOctave(4)],
  [183.25,13,Note.e.inOctave(4)],
  [196.50,14,Note.d.inOctave(4)],
  [209.75,15,Note.c.inOctave(4)],
  [223.00,16,Note.b.inOctave(3)],
  [236.25,17,Note.a.inOctave(3)],
  [249.50,18,Note.g.inOctave(3)],
];

List<List<PositionedNote>> noDiffDoubleList = [
  [Note.e.inOctave(4),Note.f.inOctave(4)],
  [Note.e.inOctave(5),Note.f.inOctave(5)],

  [Note.b.inOctave(4),Note.c.inOctave(5)],
  [Note.b.inOctave(3),Note.c.inOctave(4)],
  [Note.b.inOctave(5),Note.c.inOctave(6)],

  [Note.d.inOctave(4),Note.f.inOctave(4)],
  [Note.d.inOctave(5),Note.f.inOctave(5)],

  [Note.e.inOctave(4),Note.g.inOctave(4)],
  [Note.e.inOctave(5),Note.g.inOctave(5)],

  [Note.a.inOctave(3),Note.c.inOctave(4)],
  [Note.a.inOctave(4),Note.c.inOctave(5)],
  [Note.a.inOctave(5),Note.c.inOctave(6)],

  [Note.b.inOctave(3),Note.d.inOctave(4)],
  [Note.b.inOctave(4),Note.d.inOctave(5)],
  [Note.b.inOctave(5),Note.d.inOctave(6)],

  [Note.f.inOctave(4),Note.b.inOctave(4)],
  [Note.f.inOctave(5),Note.b.inOctave(5)],
  [Note.f.inOctave(6),Note.b.inOctave(6)],

  [Note.b.inOctave(3),Note.f.inOctave(4)],
  [Note.b.inOctave(4),Note.f.inOctave(5)],
  [Note.b.inOctave(5),Note.f.inOctave(6)],

  [Note.e.inOctave(3),Note.c.inOctave(4)],
  [Note.e.inOctave(4),Note.c.inOctave(5)],
  [Note.e.inOctave(5),Note.c.inOctave(6)],

  [Note.b.inOctave(3),Note.g.inOctave(4)],
  [Note.b.inOctave(4),Note.g.inOctave(5)],
  [Note.b.inOctave(5),Note.g.inOctave(6)],

  [Note.a.inOctave(3),Note.f.inOctave(4)],
  [Note.a.inOctave(4),Note.f.inOctave(5)],

  [Note.d.inOctave(3),Note.c.inOctave(4)],
  [Note.d.inOctave(4),Note.c.inOctave(5)],
  [Note.d.inOctave(5),Note.c.inOctave(6)],

  [Note.e.inOctave(4),Note.d.inOctave(5)],

  [Note.g.inOctave(3),Note.f.inOctave(4)],
  [Note.g.inOctave(4),Note.f.inOctave(5)],

  [Note.a.inOctave(4),Note.g.inOctave(5)],
  [Note.a.inOctave(3),Note.g.inOctave(4)],

  [Note.b.inOctave(4),Note.a.inOctave(5)],
  [Note.b.inOctave(3),Note.a.inOctave(4)],
];

