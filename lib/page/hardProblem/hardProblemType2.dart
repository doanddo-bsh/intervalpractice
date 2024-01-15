import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:music_notes/music_notes.dart';
import 'dart:math';
import '../problemFunc/problemFunc.dart';
import '../problemFunc/problemFuncDeco.dart';
import '../problemFunc/problemVarList.dart';
import 'package:intervalpractice/page/problemFunc/colorList.dart';
import '../problemFunc/resultPage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../problemFunc/admobClass.dart';


class HardProblemType2 extends StatefulWidget {
  const HardProblemType2({super.key});

  @override
  State<HardProblemType2> createState() => _HardProblemType2State();
}

class _HardProblemType2State extends State<HardProblemType2> {

  List<double> randomItems = [];
  late List<int> randomNoteNumber ;
  late List<PositionedNote> randomNote ;
  List<String> accidentals = [];

  List<List<int>> wrongProblems = [];
  List<List<int>> wrongProblemsSave = [];

  List<List<String>> wrongProblemsAccidentals = [];
  List<List<String>> wrongProblemsAccidentalsSave = [];

  bool wrongProblemMode = false ;

  int numberOfRight = 0 ;

  // 위에음 보여줄지 아래음 보여줄지?
  int upDown = 0 ;
  List<int> upDownWorngList = [];
  List<int> upDownWorngListSave = [];

  String? intervalNumber = null;

  Note? answerNote = null;

  Widget intervalNumberButton(String number){
    return ElevatedButton(
        onPressed: answerNote==null?
            (){
          setState(() {
            intervalNumber = number;
            // hard라서 accidental까지 골라야함
          });
        } :
            (){
          // 정답이 null 이 아닐때?
        },
        child: Text(number
          , style: answerButtonTextDesign,
        ),
        style: answerButtonDesign(intervalNumber,number,'hard',context)
    );
  }

  // sharp, double sharp, flat, double flat
  Widget secondeElevatedButton(String intervalName,String intervalNumber){

    late Note answerCheck;

    if (intervalName == '#'){ // 샵
      answerCheck = korToEngNote[intervalNumber].sharp;
    } else if (intervalName == 'x'){ // 더블샵
      answerCheck = korToEngNote[intervalNumber].sharp.sharp;
    } else if(intervalName == 'b'){ // 플랫
      answerCheck = korToEngNote[intervalNumber].flat;
    } else if (intervalName == 'bb'){ // 더블플랫
      answerCheck = korToEngNote[intervalNumber].flat.flat;
    } else { // 없음
      answerCheck = korToEngNote[intervalNumber];
    }

    return ElevatedButton(
        onPressed: answerNote==null?
            () {
          setState(() {
            if (intervalName == '#'){ // 샵
              answerNote = korToEngNote[intervalNumber].sharp;
            } else if (intervalName == 'x'){ // 더블샵
              answerNote = korToEngNote[intervalNumber].sharp.sharp;
            } else if(intervalName == 'b'){ // 플랫
              answerNote = korToEngNote[intervalNumber].flat;
            } else if (intervalName == 'bb'){ // 더블플랫
              answerNote = korToEngNote[intervalNumber].flat.flat;
            } else {
              answerNote = korToEngNote[intervalNumber];
            }
            showBottomResult(answerNote!);
          });
        }:
            (){
          // ('정답이 이미 들어옴')?;
        },
        child: Text(intervalName, style: answerButtonTextDesign,),
        style:answerButtonDesign(answerNote,answerCheck,'hard',context)
    );
  }

  Widget showIntervalNameBefore(String intervalNumber){
    return SizedBox(
      child: Column(
        children: [
          Text('임시표를 고르세요',style: explainTextStyle),
          SizedBox(height: 20.0.h,),
          SizedBox(
            height: buttonSizeBasic,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                secondeElevatedButton(
                    'b',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '없음',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '#',
                    intervalNumber
                ),
              ],
            ),
          ),
          SizedBox(height: 13.0.h,),
          SizedBox(
            height: buttonSizeBasic,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                secondeElevatedButton(
                    'bb',
                    intervalNumber
                ),
                secondeElevatedButton(
                    'x',
                    intervalNumber
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget showIntervalName(String? intervalNumber){
    if (intervalNumber == null){
      return SizedBox(height: 10.h,);
    } else {
      return showIntervalNameBefore(intervalNumber);
    }
  }

  void showBottomResult(Note answerNote){

    // 정답 계산 for 해석
    List<dynamic> resultAll = getResultAllHard(randomNote, accidentals, false);

    // 정답 배분/입력
    List<dynamic> randomNoteAnswer = resultAll[0] ;
    String answerRealKor = resultAll[2] ;

    // 해석 해설
    // type2 해설은 answerRealKor만 활용함
    String commentaryResult = '' ;

    if (commentaryType2[answerRealKor+'도'] == null) {
      commentaryResult = '' ;
    } else {
      commentaryResult = commentaryType2[answerRealKor+'도']!;
    }

    print('commentaryResult $commentaryResult');

    // 진짜 정답 계산

    PositionedNote realNote = (upDown != 0)?
    randomNote[0]:randomNote[1];

    String realAccidental = (upDown != 0)?
    accidentals[0]:accidentals[1];

    late Note realNoteAccidental ;

    if (realAccidental == 'sharp'){
      realNoteAccidental = realNote.note.sharp;
    } else if (realAccidental == 'double sharp') {
      realNoteAccidental = realNote.note.sharp.sharp;
    } else if (realAccidental == 'flat') {
      realNoteAccidental = realNote.note.flat;
    } else if (realAccidental == 'double flat') {
      realNoteAccidental = realNote.note.flat.flat;
    } else {
      realNoteAccidental = realNote.note;
    }

    String realNoteNoteKr = engToKorNote[realNote.note];
    String realNoteAccidentalString = '';

    if (realNoteAccidental.toString().length ==1){
      realNoteAccidentalString = '';
    } else {
      realNoteAccidentalString = realNoteAccidental.toString().substring(1);
    }

    String realNoteNoteAccidentalKr = realNoteNoteKr + realNoteAccidentalString;

    if (answerNote == realNoteAccidental){

      setState(() {
        numberOfRight += 1 ;
      });

      showModalBottomSheet<void>(
        backgroundColor: color5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            )
        ),
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: 7,),
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('정답입니다!',
                            style: TextStyle(
                                color: color4,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          commentaryToolTip(commentaryResult,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 7,),
                  Text('정답 : ' + realNoteNoteAccidentalKr + ''
                      '(${realNoteAccidental.toString()})',
                    style: TextStyle(
                      color: color4,
                      fontSize : 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7,),
                  wrongProblemMode?
                  (wrongProblemsSave.length != problemNumber)?
                  wrongProblemNextProblem('다음문제','right') :
                  showResult('right') :
                  (problemNumber!=10)?
                  nextProblem('다음문제','right') :
                  showResult('right'),
                  // (problemNumber!=10)? nextProblem('다음문제') : showResult()
                ],
              ),
            ),
          );
        },
      );

    } else {


      wrongProblems += [randomNoteNumber] ;
      wrongProblemsAccidentals += [accidentals];
      upDownWorngList += [upDown];

      print('wrongProblems $wrongProblems');
      print('wrongProblemsAccidentals $wrongProblemsAccidentals');
      print('upDownWorngList $upDownWorngList');

      showModalBottomSheet<void>(
        backgroundColor: Color(0xffd7b1b1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            )
        ),
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 140,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('오답입니다',
                            style: TextStyle(
                                color:color6,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          commentaryToolTip(commentaryResult),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 7,),
                  Text('정답 : ' + realNoteNoteAccidentalKr + ''
                      '(${realNoteAccidental.toString()})',
                    style: TextStyle(
                      color: color6,
                      fontSize : 14.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7,),
                  // Text('정답은 ${answerRealKor} 입니다.'),
                  wrongProblemMode?
                  (wrongProblemsSave.length != problemNumber)?
                  wrongProblemNextProblem('다음문제','wrong') :
                  showResult('wrong') :
                  (problemNumber!=10)?
                  nextProblem('다음문제','wrong') :
                  showResult('wrong'),
                  // (problemNumber!=10)? nextProblem('다음문제') : showResult()
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget nextProblem(String buttonText,String right_wrong){
    return ElevatedButton(

        onPressed: (){
          if (problemNumber==10){
            setState(() {
              problemNumber = 0;
            });
          }

          List<List<dynamic>> note_height_list_problem = getProblemListNote(
            note_height_list,
            randomItems,
          );

          setState(() {
            // 문제 적용
            randomItems = [note_height_list_problem[0][0],note_height_list_problem[1][0]];
            // randomItems.sort();
            randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
            // randomNoteNumber.sort();
            randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
            // randomNote.sort();

            upDown = Random().nextInt(2);

            answerNote = null;
            intervalNumber = null;

            problemNumber += 1;

            accidentals = accidentalsFinal(randomNote);
          });

          Navigator.pop(context);

        },
      style: nextProblemButtonStyle('easy',right_wrong),
      child: Text(buttonText,
        style: nextProblemButtonTextStyle,
      ),
    );
  }


  Widget nextProblemResult(){
    return ElevatedButton(

        onPressed: (){

          numberOfRight = 0 ;
          wrongProblems = [];
          wrongProblemsAccidentals = [];
          wrongProblemMode = false ;

          List<List<dynamic>> note_height_list_problem = getProblemListNote(
            note_height_list,
            randomItems,
          );

          setState(() {
            // 문제 적용
            randomItems = [note_height_list_problem[0][0],note_height_list_problem[1][0]];
            // randomItems.sort();
            randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
            // randomNoteNumber.sort();
            randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
            // randomNote.sort();

            upDown = Random().nextInt(2);

            answerNote = null;
            intervalNumber = null;

            accidentals = accidentalsFinal(randomNote);
          });

          setState(() {
            problemNumber = 1 ;
          });

          Navigator.pop(context);


        },  style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        )
    ),
        child: Text('네',
          style: TextStyle(
              color: Colors.grey[700]
          ),
        )
    );
  }


  Widget wrongProblemNextProblem(String buttonText, String right_wrong){
    return ElevatedButton(

        onPressed: (){

          setState(() {

            problemNumber += 1;

            // 문제 적용
            randomNoteNumber = wrongProblemsSave[problemNumber-1];
            // randomNoteNumber.sort();
            upDown = upDownWorngListSave[problemNumber-1];

            randomItems =
            [note_height_list_fix[randomNoteNumber[0]][0],
              note_height_list_fix[randomNoteNumber[1]][0]];
            // randomItems.sort();
            randomNote =
            [note_height_list_fix[randomNoteNumber[0]][2],
              note_height_list_fix[randomNoteNumber[1]][2]];
            // randomNote.sort();

            answerNote = null;
            intervalNumber = null;

            accidentals = wrongProblemsAccidentalsSave[problemNumber-1];
          });

          Navigator.pop(context);

        },
        style: nextProblemButtonStyle('easy',right_wrong),
        child: Text(buttonText,
          style: nextProblemButtonTextStyle,
        ),
    );
  }


  Widget wrongProblemSolveStart(String buttonText){
    return ElevatedButton(

      onPressed: (wrongProblems.isEmpty) ? null:(){

        numberOfRight = 0 ;

        // back up
        wrongProblemsSave = wrongProblems ;
        wrongProblemsAccidentalsSave = wrongProblemsAccidentals;
        upDownWorngListSave = upDownWorngList;

        print('wrongProblemsSave $wrongProblemsSave');
        print('wrongProblems $wrongProblems');

        wrongProblems = [] ;
        wrongProblemsAccidentals = [] ;

        print('upDownWorngListSave $upDownWorngListSave');
        print('upDownWorngList $upDownWorngList');
        upDownWorngList = [] ;

        setState(() {
          // 문제 적용
          randomNoteNumber = wrongProblemsSave[0];
          upDown = upDownWorngListSave[0];
          // randomNoteNumber.sort();

          randomItems =
          [note_height_list_fix[randomNoteNumber[0]][0],
            note_height_list_fix[randomNoteNumber[1]][0]];
          // randomItems.sort();
          randomNote =
          [note_height_list_fix[randomNoteNumber[0]][2],
            note_height_list_fix[randomNoteNumber[1]][2]];
          // randomNote.sort();

          answerNote = null;
          intervalNumber = null;

          accidentals = wrongProblemsAccidentalsSave[0];

        });

        setState(() {
          problemNumber = 1 ;
          wrongProblemMode = true ;
        });

        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow[200]
      ),
      child: Text('틀린 문제 다시 풀기',
        style: TextStyle(
            color: Colors.grey[700]
        ),
      ),
    );
  }

  Widget showResult(String right_wrong){

    // Navigator.pop(context);

    return ElevatedButton(
        onPressed: (){

          Navigator.pop(context);

          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (BuildContext context) {
              return resultPage(context,
                wrongProblemMode,
                numberOfRight,
                wrongProblemsSave,
                wrongProblems,
                nextProblemResult(),
                wrongProblemSolveStart('틀린 문제 다시 풀기'),
                    (){
                  wrongProblems = [];
                  upDownWorngList = [];
                  wrongProblemMode = false ;
                  numberOfRight = 0 ;
                  Navigator.popUntil
                    (context, ModalRoute.withName("/FirstProblemTypeList"));
                },
              );
              //   Container(
              //   decoration: const BoxDecoration(
              //     borderRadius: BorderRadius.only(
              //       topLeft: Radius.circular(30),
              //       topRight: Radius.circular(30),
              //     ),
              //   ),
              //   height: MediaQuery.of(context).size.height * 1.0,
              //   child: Center(
              //     child:
              //     SafeArea(
              //       child: Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Column(
              //           children: [
              //             Container(
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 crossAxisAlignment: CrossAxisAlignment.center,
              //                 children: [
              //                   SizedBox(height: 40,),
              //                   Stack(
              //                     children: [
              //                       Padding(
              //                         padding: const EdgeInsets.all(15.0),
              //                         child: ClipRRect(
              //                           borderRadius: BorderRadius.circular(20),
              //                           child: Container(
              //                             width: 600.w,
              //                             height: 450.h,
              //                             color: Colors.lightGreen.withOpacity(0.4),
              //                           ),),
              //                       ),
              //                       Center(
              //                         child: Container(
              //                           child: Column(
              //                               children: [
              //                                 SizedBox(height: 60,),
              //                                 Container(
              //                                     child: Text('이번 문제의 점수는',
              //                                       style: TextStyle(
              //                                           fontSize: 25,
              //                                           color: Colors.grey[700]
              //                                       ),)),
              //                                 // SizedBox(height: 30,),
              //                                 Stack(
              //                                   children:[
              //                                     Container(
              //                                       child: Lottie.asset
              //                                         ('assets/animation/star2.json'),
              //                                     ),
              //                                     Padding(
              //                                       padding: const EdgeInsets.fromLTRB(40, 60, 0, 0),
              //                                       child: Container(
              //                                         child:
              //                                         wrongProblemMode?
              //                                         Text
              //                                           ('${
              //                                             (numberOfRight/wrongProblemsSave.length *
              //                                                 100).round()}점',
              //                                             style: TextStyle(
              //                                                 fontSize: 60,
              //                                                 fontWeight: FontWeight.bold
              //                                             )
              //                                         ):Text
              //                                           ('${
              //                                             (numberOfRight/10 *
              //                                                 100).round()}점',
              //                                             style: TextStyle(
              //                                                 fontSize: 60,
              //                                                 fontWeight: FontWeight.bold
              //                                             )
              //                                         ),
              //                                       ),
              //                                     ),
              //                                   ],),
              //                                 // SizedBox(height: 30,),
              //                                 Container(
              //                                     child: Text('정말 멋져요! 내가바로 음정고수🎉',
              //                                         style: TextStyle(
              //                                             fontSize: 20,
              //                                             color: Colors.grey[700]
              //                                         ))),
              //                                 SizedBox(height: 20,),
              //                                 Container(
              //                                     child: wrongProblemMode?
              //                                     Text
              //                                       ('${wrongProblemsSave.length
              //                                         .toString()}문제중에서 '
              //                                         '${numberOfRight}문제를 '
              //                                         '맞췄습니다',
              //                                         style:
              //                                         TextStyle(
              //                                             fontSize: 20,
              //                                             fontWeight: FontWeight.bold
              //                                         )
              //                                     ) : Text
              //                                       ('10문제중에서 '
              //                                         '${numberOfRight}문제를 '
              //                                         '맞췄습니다',
              //                                         style:
              //                                         TextStyle(
              //                                             fontSize: 20,
              //                                             fontWeight: FontWeight.bold
              //                                         )
              //                                     )
              //                                 ),
              //                                 SizedBox(height: 20,),
              //                                 Container(
              //                                   height: 40,
              //                                   width: 300,
              //                                   child: wrongProblemSolveStart
              //                                     ('틀린 문제 다시 풀기'),
              //                                 )
              //                               ]),
              //                         ),
              //                       ),
              //
              //                     ],
              //                   ),
              //                 ],
              //               ),
              //             ),
              //             Padding(
              //               padding: const EdgeInsets.fromLTRB(0, 1, 0, 2),
              //               child: Divider(thickness: 1,
              //                 indent: 7,
              //                 endIndent: 7,),
              //             ),
              //             Expanded(
              //               child: Padding(
              //                 padding: const EdgeInsets.all(8.0),
              //                 child: Stack(
              //                   children: [
              //                     ClipRRect(
              //                       borderRadius: BorderRadius.circular(20),
              //                       child: Container(
              //                         width: 600,
              //                         height: 400,
              //                         color: Colors.grey[300],
              //                       ),),
              //                     Container(
              //                       margin: EdgeInsets.all(15),
              //                       child: Column(
              //                         mainAxisAlignment: MainAxisAlignment.center,
              //                         children: [
              //                           Container(child:
              //                           Text('계속해서 문제를 푸시겠습니까?',
              //                             style: TextStyle(
              //                                 fontSize: 17,
              //                                 fontWeight: FontWeight.bold
              //                             ),),
              //                           ),
              //                           SizedBox(height: 13,),
              //                           Center(
              //                             child: Row(
              //                               mainAxisAlignment: MainAxisAlignment.center,
              //                               children: [
              //                                 nextProblemResult(),
              //                                 SizedBox(width: 40,),
              //                                 ElevatedButton(
              //                                   onPressed: (){
              //                                     wrongProblems = [];
              //                                     upDownWorngList = [];
              //                                     wrongProblemMode = false ;
              //                                     numberOfRight = 0 ;
              //                                     Navigator.popUntil
              //                                       (context, ModalRoute.withName(Navigator.defaultRouteName));
              //                                   },
              //                                   style: ElevatedButton.styleFrom(
              //                                       shape: RoundedRectangleBorder(
              //                                           borderRadius: BorderRadius.circular(10)
              //                                       )
              //                                   ),
              //                                   child: Text('아니오',
              //                                       style: TextStyle(
              //                                           color: Colors.grey[700])
              //                                   ),
              //                                 )],
              //                             ),
              //                           ),
              //
              //                         ],
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // );
            },
          );
        },
        style: nextProblemButtonStyle('easy',right_wrong),
        child: Text('결과보기',
          style: nextProblemButtonTextStyle,
        ),
    );
  }

  int problemNumber = 1 ;
  //
  // Widget lastRidingProgress() {
  //
  //   double percent =
  //   wrongProblemMode?
  //   double.parse((problemNumber / wrongProblemsSave.length).toStringAsFixed
  //     (1)) :
  //   problemNumber / 10 ;
  //
  //   print(percent);
  //   print('problemNumber $problemNumber');
  //   print('wrongProblemsSave.length ${wrongProblemsSave.length}');
  //
  //   return Column(
  //     children: [
  //       Center(
  //         child: Container(
  //           // color: Colors.black12,
  //           width: MediaQuery.of(context).size.width-15.w,
  //           alignment: FractionalOffset(percent, 1 - percent),
  //           child: Padding(
  //             padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
  //             child: Container(
  //               // color: Colors.red,
  //                 child: Image.asset('assets/noteToProgress.png',
  //                     width: 20, height: 20, fit: BoxFit.cover)
  //             ),
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 3,),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           LinearPercentIndicator(
  //             width: MediaQuery.of(context).size.width-50.w,
  //             padding: EdgeInsets.zero,
  //             percent: percent,
  //             lineHeight: 20.h,
  //             center: wrongProblemMode?
  //             Text(problemNumber.toString() + '/' + wrongProblemsSave.length
  //                 .toString()) :
  //             Text(problemNumber.toString() + '/10') ,
  //             backgroundColor: Colors.black12,
  //             progressColor: Colors.amber,
  //           ),
  //         ],
  //       )
  //     ],
  //   );
  // }
  //
  // Widget returnLine(double top){
  //   return Positioned(
  //       top: top.h,
  //       left: 10.w,
  //       right: 10.w,
  //       child:
  //       Container(
  //         color: Colors.black,
  //         width: double.infinity,
  //         height: 2.0.h,
  //       )
  //   );
  // }
  //
  // // 덧줄용1
  // Widget addLine1(PositionedNote randomNote){
  //
  //   // middle line
  //   List<PositionedNote> middleLine = [
  //     Note.a.inOctave(5),
  //     Note.f.inOctave(5),
  //     Note.d.inOctave(5),
  //     Note.b.inOctave(4),
  //     Note.g.inOctave(4),
  //     Note.e.inOctave(4),
  //     Note.c.inOctave(4),
  //     Note.a.inOctave(3),
  //     Note.c.inOctave(6),
  //   ];
  //   // low line
  //   List<PositionedNote> lowLine = [
  //     Note.b.inOctave(5),
  //     Note.d.inOctave(6),
  //   ];
  //
  //   // high line
  //   List<PositionedNote> highLine = [
  //     Note.b.inOctave(3),
  //     Note.g.inOctave(3)
  //   ];
  //
  //   if (middleLine.contains(randomNote)){
  //     return
  //       Positioned(
  //         top: 12.75.h,
  //         child: Container(
  //           color: Colors.black,
  //           height: 2.0.h,
  //           width: 50.w,
  //         ),
  //       );
  //   } else if (lowLine.contains(randomNote)) {
  //     return
  //       Positioned(
  //         top: 24.5.h,
  //         child: Container(
  //           color: Colors.black,
  //           height: 2.0.h,
  //           width: 50.w,
  //         ),
  //       );
  //   } else if (highLine.contains(randomNote)){
  //     return
  //       Positioned(
  //         child: Container(
  //           color: Colors.black,
  //           height: 2.0.h,
  //           width: 50.w,
  //         ),
  //       );
  //   }
  //   else {
  //     return SizedBox();
  //   }
  // }
  //
  //
  // // 덧줄용2
  // Widget addLine2(PositionedNote randomNote, double left){
  //
  //   // highhigh line
  //   List<PositionedNote> highHighLine = [
  //     Note.d.inOctave(6),
  //     Note.c.inOctave(6),
  //   ];
  //   // lowlow line
  //   List<PositionedNote> lowLowLine = [
  //     Note.a.inOctave(3),
  //     Note.g.inOctave(3),
  //   ];
  //
  //   if (highHighLine.contains(randomNote)){
  //     return
  //       Positioned(
  //         top: 63.5.h,
  //         left: left,
  //         child: Container(
  //           color: Colors.black,
  //           height: 2.0.h,
  //           width: 50.w,
  //         ),
  //       );
  //   } else if (lowLowLine.contains(randomNote)) {
  //     return
  //       Positioned(
  //         top: 222.5.h,
  //         left: left,
  //         child: Container(
  //           color: Colors.black,
  //           height: 2.0.h,
  //           width: 50.w,
  //         ),
  //       );
  //   }
  //   else {
  //     return SizedBox();
  //   }
  // }
  //
  // // 변화표 추가
  // Widget addAccidentals(String whatAccidental, double top, double left){
  //
  //   if (whatAccidental == 'none'){
  //     return SizedBox();
  //   } else if (whatAccidental == 'sharp'){
  //     return Positioned(
  //       top: top,
  //       left: left,
  //       child: SizedBox(
  //         height: 30,
  //         width: 15,
  //         child: Image(
  //           image: AssetImage('assets/sharp1.png',
  //           ),
  //           fit: BoxFit.fill,
  //         ),
  //       ),
  //     );
  //   } else if (whatAccidental == 'double sharp'){
  //     return Positioned(
  //       top: top,
  //       left: left,
  //       child: SizedBox(
  //         height: 30,
  //         width: 15,
  //         child: Image(
  //           image: AssetImage('assets/doubleSharp.png',
  //           ),
  //           fit: BoxFit.fill,
  //         ),
  //       ),
  //     );
  //   } else if (whatAccidental == 'flat'){
  //     return Positioned(
  //       top: top,
  //       left: left,
  //       child: SizedBox(
  //         height: 30,
  //         width: 15,
  //         child: Image(
  //           image: AssetImage('assets/flat1.png',
  //           ),
  //           fit: BoxFit.fill,
  //         ),
  //       ),
  //     );
  //   } else {
  //     return Positioned(
  //       top: top,
  //       left: left,
  //       child: SizedBox(
  //         height: 30,
  //         width: 15,
  //         child: Image(
  //           image: AssetImage('assets/doubleFlat.png',
  //           ),
  //           fit: BoxFit.fill,
  //         ),
  //       ),
  //     );
  //   }
  //
  //
  // }

  // for admob banner
  BannerAd? _banner;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // 새로운 문제 생성

    List<List<dynamic>> note_height_list_problem = getProblemListNote(
        note_height_list, randomItems
    );

    randomItems = [note_height_list_problem[0][0],note_height_list_problem[1][0]];
    // randomItems.sort();
    randomNoteNumber = [note_height_list_problem[0][1],note_height_list_problem[1][1]];
    // randomNoteNumber.sort();
    randomNote = [note_height_list_problem[0][2],note_height_list_problem[1][2]];
    // randomNote.sort();
    accidentals = accidentalsFinal(randomNote);
    upDown = Random().nextInt(2);

    // for admob banner
    _createBannerAd();
  }

  // admob banner
  void _createBannerAd(){
    _banner = BannerAd(
      size: AdSize.banner
      , adUnitId: AdMobServiceBanner.bannerAdUnitId!
      , listener: AdMobServiceBanner.bannerAdListener
      , request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {

    print('upDown $upDown');
    print('randomNote $randomNote');
    print('randomNoteNumber $randomNoteNumber');
    print('accidentals $accidentals');

    print('kor note name');
    (upDown!=0)?
    print(engToKorNote[randomNote[0].note]):
    print(engToKorNote[randomNote[1].note]);

    List<dynamic> randomNoteAnswerTemp = [] ;

    randomNoteAnswerTemp.add(addAccidental(randomNote[0], accidentals[0]));
    randomNoteAnswerTemp.add(addAccidental(randomNote[1], accidentals[1]));

    randomNoteAnswerTemp.sort();

    String answerRealTemp = randomNoteAnswerTemp[0].interval
      (randomNoteAnswerTemp[1]).toString();
    String answerRealKorTemp = '';

    if (answerRealTemp.length==2){
      answerRealKorTemp = intervalNameEngKor[answerRealTemp.substring(0, 1)] +
          answerRealTemp.substring(1, 2);
    } else {
      answerRealKorTemp = intervalNameEngKor[answerRealTemp.substring(0, 2)] +
          answerRealTemp.substring(2, 3);
    }

    print('answerRealTemp $answerRealTemp');
    print('answerRealKorTemp $answerRealKorTemp');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: wrongProblemMode?
        Text("오답문제",
            style: appBarTitleStyle
        ) :
        Text("Hard",
          style: appBarTitleStyle,
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: appBarIcon,
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          lastRidingProgress(
            wrongProblemMode,
            problemNumber,
            wrongProblemsSave,
            'hard',
            context,
          ),
          Container(
            height: 300.h,
            width: double.infinity,
            // decoration: BoxDecoration(
            //     border: Border.all(color: Colors.black)
            // ),
            child: Stack(
              children: [
                Positioned(
                  top: 0.h,
                  bottom: 0.h,
                  left: 10.0.w,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:Image.asset('assets/treble_clef_ff_cut.png',
                      height: 180.h,
                    ),
                  ),
                ),
                returnLine(90.0),
                returnLine(116.5),
                returnLine(143.0),
                returnLine(169.5),
                returnLine(196.0),
                (upDown == 0)?
                Positioned(
                  top: randomItems[0].h,
                  left: 130.w,
                  child: SizedBox(
                    height: 26.5.h,
                    child: Stack(
                      children: [
                        Image.asset('assets/whole_note_lean.png'),
                        addLine1(randomNote[0]),
                      ],
                    ),
                  ),
                ):Positioned(
                  top: randomItems[1].h,
                  left: 130.w,
                  child: SizedBox(
                    height: 26.5.h,
                    child: Stack(
                      children: [
                        Image.asset('assets/whole_note_lean.png'),
                        addLine1(randomNote[1]),
                      ],
                    ),
                  ),
                ),
                (upDown == 0)?
                addLine3(randomNote[0],130.w):
                addLine3(randomNote[1],130.w)
                ,
                (upDown == 0)?
                addAccidentals(accidentals[0],randomItems[0].h,110.w):
                addAccidentals(accidentals[1],randomItems[1].h,110.w),
              ],
            ),
          ),
          // const SizedBox(height: 10.0,),
          // ElevatedButton(onPressed: (){
          //   setState(() {
          //     problemNumber = 10;
          //   });
          // }, child: Text('test')
          // ),
          Text('[ 주어진 음정 : $answerRealKorTemp'+'도 ]',style: explainTextStyle2),
          SizedBox(height: 20.h,),
          (upDown == 0)?
          (randomNoteNumber[0] < randomNoteNumber[1])?
          Text('주어진 음정을 위해 필요한 아래↓ 계이름은?',style: explainTextStyle):
          Text('주어진 음정을 위해 필요한 위↑ 계이름은?',style: explainTextStyle):
          (randomNoteNumber[0] < randomNoteNumber[1])?
          Text('주어진 음정을 위해 필요한 위↑ 계이름은?',style: explainTextStyle):
          Text('주어진 음정을 위해 필요한 아래↓ 계이름은?',style: explainTextStyle),
          SizedBox(height: 20.0.h,),
          SizedBox(
            child: Column(
              children: [
                SizedBox(
                  height: buttonSizeBasic,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      intervalNumberButton('도'),
                      intervalNumberButton('레'),
                      intervalNumberButton('미'),
                      intervalNumberButton('파'),
                    ],
                  ),
                ),
                SizedBox(height: 13.0.h,),
                SizedBox(
                  height: buttonSizeBasic,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      intervalNumberButton('솔'),
                      intervalNumberButton('라'),
                      intervalNumberButton('시'),
                      // intervalNumberButton('8'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0.h,),
          showIntervalName(intervalNumber),
          // SizedBox(height: 30,),
          Expanded(child: SizedBox()),
          // admob banner
          Container(
            alignment: Alignment.center,
            width: _banner!.size.width.toDouble(),
            height: _banner!.size.height.toDouble(),
            child: AdWidget(
              ad: _banner!,
            ),
          ),
          Expanded(child: SizedBox()),
        ],
      ),
    );
  }
}
