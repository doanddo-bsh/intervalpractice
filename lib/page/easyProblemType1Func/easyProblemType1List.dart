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


List<List<dynamic>> note_height_list_fix =
[
  // topheigh, number, note
  [4.0,0,Note.b.inOctave(5)],
  [17.0,1,Note.a.inOctave(5)],
  [29.0,2,Note.g.inOctave(5)],
  [42.0,3,Note.f.inOctave(5)],
  [55.0,4,Note.e.inOctave(5)],
  [67.5,5,Note.d.inOctave(5)],
  [81.0,6,Note.c.inOctave(5)],
  [94.5,7,Note.b.inOctave(4)],
  [108.0,8,Note.a.inOctave(4)],
  [121.5,9,Note.g.inOctave(4)],
  [133.0,10,Note.f.inOctave(4)],
  [145.0,11,Note.e.inOctave(4)],
  [159.0,12,Note.d.inOctave(4)],
  [172.0,13,Note.c.inOctave(4)],
  [184.0,14,Note.b.inOctave(3)],
];

List<List<dynamic>> note_height_list =
[
  // topheigh, number, note
  [4.0,0,Note.b.inOctave(5)],
  [17.0,1,Note.a.inOctave(5)],
  [29.0,2,Note.g.inOctave(5)],
  [42.0,3,Note.f.inOctave(5)],
  [55.0,4,Note.e.inOctave(5)],
  [67.5,5,Note.d.inOctave(5)],
  [81.0,6,Note.c.inOctave(5)],
  [94.5,7,Note.b.inOctave(4)],
  [108.0,8,Note.a.inOctave(4)],
  [121.5,9,Note.g.inOctave(4)],
  [133.0,10,Note.f.inOctave(4)],
  [145.0,11,Note.e.inOctave(4)],
  [159.0,12,Note.d.inOctave(4)],
  [172.0,13,Note.c.inOctave(4)],
  [184.0,14,Note.b.inOctave(3)],
];
