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
};

List<List<dynamic>> note_height_list_fix =
[
  // topheigh, number, note
  [37.50,0,Note.b.inOctave(5)],
  [50.75,1,Note.a.inOctave(5)],
  [64.00,2,Note.g.inOctave(5)],
  [77.25,3,Note.f.inOctave(5)],
  [90.50,4,Note.e.inOctave(5)],
  [103.75,5,Note.d.inOctave(5)],
  [117.00,6,Note.c.inOctave(5)],
  [130.25,7,Note.b.inOctave(4)],
  [143.50,8,Note.a.inOctave(4)],
  [156.75,9,Note.g.inOctave(4)],
  [170.00,10,Note.f.inOctave(4)],
  [183.25,11,Note.e.inOctave(4)],
  [196.50,12,Note.d.inOctave(4)],
  [209.75,13,Note.c.inOctave(4)],
  [223.00,14,Note.b.inOctave(3)],
];

List<List<dynamic>> note_height_list =
[
  // topheigh, number, note
  [37.50,0,Note.b.inOctave(5)],
  [50.75,1,Note.a.inOctave(5)],
  [64.00,2,Note.g.inOctave(5)],
  [77.25,3,Note.f.inOctave(5)],
  [90.50,4,Note.e.inOctave(5)],
  [103.75,5,Note.d.inOctave(5)],
  [117.00,6,Note.c.inOctave(5)],
  [130.25,7,Note.b.inOctave(4)],
  [143.50,8,Note.a.inOctave(4)],
  [156.75,9,Note.g.inOctave(4)],
  [170.00,10,Note.f.inOctave(4)],
  [183.25,11,Note.e.inOctave(4)],
  [196.50,12,Note.d.inOctave(4)],
  [209.75,13,Note.c.inOctave(4)],
  [223.00,14,Note.b.inOctave(3)],
];
