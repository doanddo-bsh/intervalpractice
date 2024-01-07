import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'colorList.dart';
import 'problemVarList.dart';
import '../problemFunc/problemFunc.dart';

// appBar title style
TextStyle appBarTitleStyle =
TextStyle(fontSize: 16,fontWeight: FontWeight.bold);

// appBar title icon
Icon appBarIcon = Icon(Icons.arrow_back_ios,size: 16,);

// explain text style
TextStyle explainTextStyle =
TextStyle(fontSize: 14,fontWeight: FontWeight.bold);

TextStyle explainTextStyle2 =
TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.red[300]);

// next problem button style
ButtonStyle nextProblemButtonStyle(String easyOrHard,String right_wrong){
  return ElevatedButton.styleFrom(
      backgroundColor: (right_wrong=='right')? color1: color2,
      foregroundColor: (right_wrong=='right')? color1 : color2,
      elevation: 3
  );
}

// next problem button text style
TextStyle nextProblemButtonTextStyle =
TextStyle(fontSize: 14,fontWeight: FontWeight.bold,color: Colors.white54)
;




// answer button text design
TextStyle answerButtonTextDesign =
TextStyle(color: color3);

// answer button design
ButtonStyle answerButtonDesign(realValue,buttonValue,easyOrHard,context){
  return
    ElevatedButton.styleFrom(
        backgroundColor:
        realValue==buttonValue ?
        Color(0xffdadada) :
        Theme.of(context).colorScheme.onTertiary,
        foregroundColor: (easyOrHard=='easy')? color1 : color2,
        shape:RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8)
        ) 

    );
}

String classifyAccidentals(String accidentalOrigin){

  if (accidentalOrigin.contains('Natural'))
  {
    return 'n';
  } else if (accidentalOrigin.contains('Flat'))
  {
    return 'f';
  } else if (accidentalOrigin.contains
    ('Double flat'))
  { return 'df';
  } else if (accidentalOrigin.contains
    ('Double sharp'))
  { return 'ds';
  } else {
    return 's';
  }
}

// commentary function
String commentaryKeyReturn(List<dynamic> randomNoteAnswerSorted, String answerRealKor){

  // number
  String answerReal = randomNoteAnswerSorted[0].interval(randomNoteAnswerSorted[1]).toString();

  // commentary
  // 숫자(1~8), 알파벳(c,d,e,f,g,a,b), 알파벳(c,d,e,f,g,a,b) // ex 3cg
  String commentaryNumberTemp = answerReal.toString();
  String commentaryAlphabat1Temp = randomNoteAnswerSorted[0].note.baseNote
      .toString();
  String commentaryAlphabat2Temp = randomNoteAnswerSorted[1].note.baseNote
      .toString();

  String commentaryTarget =
      commentaryNumberTemp[commentaryNumberTemp.length - 1]
          + commentaryAlphabat1Temp[commentaryAlphabat1Temp.length - 1]
          + commentaryAlphabat2Temp[commentaryAlphabat2Temp.length - 1];

  String commentaryFirstAccidental =
  classifyAccidentals(randomNoteAnswerSorted[0].note.accidental.toString());

  String commentarySecondAccidental =
  classifyAccidentals(randomNoteAnswerSorted[1].note.accidental.toString());

  // print('commentary target : ${commentaryTarget}');
  //
  // print('commentary first accidental origin : ${randomNoteAnswerSorted[0].note
  //     .accidental.toString()}');
  // print('commentary second accidental origin : ${randomNoteAnswerSorted[1].note
  //     .accidental.toString()}');
  //
  // print('commentary first accidental : ${commentaryFirstAccidental}');
  // print('commentary second accidental : ${commentarySecondAccidental}');

  List<String> returnTarget = [commentaryTarget,commentaryFirstAccidental,
    commentarySecondAccidental];

  print('returnTarget $returnTarget');

  // print('returnTarget ${returnTarget}');
  // return returnTarget;

  String? commentaryUpAccidentalResult =
  commentaryUpAccidental[returnTarget[2]];
  String? commentaryDownAccidentalResult =
  commentaryDownAccidental[returnTarget[1]];
  String commentaryBasicResult =
      '${commentaryBasic[returnTarget[0]][0]} ${answerRealKor}도 '
      '${commentaryBasic[returnTarget[0]][1]}'
  ;

  if ((commentaryUpAccidentalResult==null)&(commentaryDownAccidentalResult==null)){
    return commentaryBasicResult;
  } else if (commentaryUpAccidentalResult==null){
    return commentaryDownAccidentalResult! + ' ' + commentaryBasicResult;
  } else if (commentaryDownAccidentalResult==null){
    return commentaryUpAccidentalResult! + ' ' + commentaryBasicResult;
  } else {
    return commentaryDownAccidentalResult! + ' ' +
        commentaryUpAccidentalResult! + ' ' +
        commentaryBasicResult;
  }



}

// progress bar
Widget lastRidingProgress(
    wrongProblemMode,
    problemNumber,
    wrongProblemsSave,
    easyOrHard,
    context,
    ) {

  double percent =
  wrongProblemMode?
  double.parse((problemNumber / wrongProblemsSave.length).toStringAsFixed
    (1)) :
  problemNumber / 10 ;

  print(percent);
  print('problemNumber $problemNumber');
  print('wrongProblemsSave.length ${wrongProblemsSave.length}');

  return Column(
    children: [
      SizedBox(height: 3,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearPercentIndicator(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.zero,
            percent: percent,
            lineHeight: 20.h,
            center: wrongProblemMode?
            Text(problemNumber.toString() + '/' + wrongProblemsSave.length
                .toString(),style: TextStyle(fontSize: 12)) :
            Text(problemNumber.toString() + '/10',style: TextStyle(fontSize: 12),) ,
            backgroundColor: Colors.black12,
            progressColor: (easyOrHard=='easy')? color1 : color2,
          ),
        ],
      )
    ],
  );
}

// commentary Tooltip
Widget commentaryToolTip(String commentaryResult){
  return
    Padding(
      padding: EdgeInsets.fromLTRB(0.w, 0.h, 20.w, 0.h),
      child: Tooltip(
        margin: EdgeInsets.fromLTRB(0.w, 0.h, 0.w, 0.h),
        verticalOffset: 30,
        height: 80,
        textStyle: TextStyle(color: Colors.black54),
        decoration: BoxDecoration(color: Color(0xffeeeeee),
            borderRadius: BorderRadius.circular(10)),
        triggerMode: TooltipTriggerMode.tap,
        showDuration: Duration(milliseconds: 2500),
        message:
        commentaryResult,
        child: Icon(
          Icons.info_outline,
          size: 18,
        ),
      ),
    );
}


// commentary list
Map commentaryBasic = {
  "1cc"	:["반음이 0개이므로","음정입니다 \n(완전1도 음정의 기본 반음수는 0개)"],
  "1dd"	:["반음이 0개이므로","음정입니다 \n(완전1도 음정의 기본 반음수는 0개)"],
  "1ee"	:["반음이 0개이므로","음정입니다 \n(완전1도 음정의 기본 반음수는 0개)"],
  "1ff"	:["반음이 0개이므로","음정입니다 \n(완전1도 음정의 기본 반음수는 0개)"],
  "1gg"	:["반음이 0개이므로","음정입니다 \n(완전1도 음정의 기본 반음수는 0개)"],
  "1aa"	:["반음이 0개이므로","음정입니다 \n(완전1도 음정의 기본 반음수는 0개)"],
  "1bb"	:["반음이 0개이므로","음정입니다 \n(완전1도 음정의 기본 반음수는 0개)"],
  "2cd"	:["반음이 0개이므로","음정입니다 \n(장2도 음정의 기본 반음수는 0개)"],
  "2de"	:["반음이 0개이므로","음정입니다 \n(장2도 음정의 기본 반음수는 0개)"],
  "2ef"	:["반음이 1개이므로 간격이 줄어들어","음정입니다 \n(장2도 음정의 기본 반음수는 0개)"],
  "2fg"	:["반음이 0개이므로","음정입니다 \n(장2도 음정의 기본 반음수는 0개)"],
  "2ga"	:["반음이 0개이므로","음정입니다 \n(장2도 음정의 기본 반음수는 0개)"],
  "2ab"	:["반음이 0개이므로","음정입니다 \n(장2도 음정의 기본 반음수는 0개)"],
  "2bc"	:["반음이 1개이므로 간격이 줄어들어","음정입니다 \n(장2도 음정의 기본 반음수는 0개)"],
  "3ce"	:["반음이 0개이므로","음정입니다 \n(장3도 음정의 기본 반음수는 0개)"],
  "3df"	:["반음이 1개이므로 간격이 줄어들어","음정입니다 \n(장3도 음정의 기본 반음수는 0개)"],
  "3eg"	:["반음이 1개이므로 간격이 줄어들어","음정입니다 \n(장3도 음정의 기본 반음수는 0개)"],
  "3fa"	:["반음이 0개이므로","음정입니다 \n(장3도 음정의 기본 반음수는 0개)"],
  "3gb"	:["반음이 0개이므로","음정입니다 \n(장3도 음정의 기본 반음수는 0개)"],
  "3ac"	:["반음이 1개이므로 간격이 줄어들어","음정입니다 \n(장3도 음정의 기본 반음수는 0개)"],
  "3bd"	:["반음이 1개이므로 간격이 줄어들어","음정입니다 \n(장3도 음정의 기본 반음수는 0개)"],
  "4cf"	:["반음이 1개이므로","음정입니다 \n(완전4도 음정의 기본 반음수는 1개)"],
  "4dg"	:["반음이 1개이므로","음정입니다 \n(완전4도 음정의 기본 반음수는 1개)"],
  "4ea"	:["반음이 1개이므로","음정입니다 \n(완전4도 음정의 기본 반음수는 1개)"],
  "4fb"	:["반음이 0개이므로 간격이 늘어나","음정입니다 \n(완전4도 음정의 기본 반음수는 1개)"],
  "4gc"	:["반음이 1개이므로","음정입니다 \n(완전4도 음정의 기본 반음수는 1개)"],
  "4ad"	:["반음이 1개이므로","음정입니다 \n(완전4도 음정의 기본 반음수는 1개)"],
  "4be"	:["반음이 1개이므로","음정입니다 \n(완전4도 음정의 기본 반음수는 1개)"],
  "5cg"	:["반음이 1개이므로","음정입니다 \n(완전5도 음정의 기본 반음수는 1개)"],
  "5da"	:["반음이 1개이므로","음정입니다 \n(완전5도 음정의 기본 반음수는 1개)"],
  "5eb"	:["반음이 1개이므로","음정입니다 \n(완전5도 음정의 기본 반음수는 1개)"],
  "5fc"	:["반음이 1개이므로","음정입니다 \n(완전5도 음정의 기본 반음수는 1개)"],
  "5gd"	:["반음이 1개이므로","음정입니다 \n(완전5도 음정의 기본 반음수는 1개)"],
  "5ae"	:["반음이 1개이므로","음정입니다 \n(완전5도 음정의 기본 반음수는 1개)"],
  "5bf"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(완전5도 음정의 기본 반음수는 1개)"],
  "6ca"	:["반음이 1개이므로","음정입니다 \n(장6도 음정의 기본 반음수는 1개)"],
  "6db"	:["반음이 1개이므로","음정입니다 \n(장6도 음정의 기본 반음수는 1개)"],
  "6ec"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장6도 음정의 기본 반음수는 1개)"],
  "6fd"	:["반음이 1개이므로","음정입니다 \n(장6도 음정의 기본 반음수는 1개)"],
  "6ge"	:["반음이 1개이므로","음정입니다 \n(장6도 음정의 기본 반음수는 1개)"],
  "6af"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장6도 음정의 기본 반음수는 1개)"],
  "6bg"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장6도 음정의 기본 반음수는 1개)"],
  "7cb"	:["반음이 1개이므로","음정입니다 \n(장7도 음정의 기본 반음수는 1개)"],
  "7dc"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장7도 음정의 기본 반음수는 1개)"],
  "7ed"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장7도 음정의 기본 반음수는 1개)"],
  "7fe"	:["반음이 1개이므로","음정입니다 \n(장7도 음정의 기본 반음수는 1개)"],
  "7gf"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장7도 음정의 기본 반음수는 1개)"],
  "7ag"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장7도 음정의 기본 반음수는 1개)"],
  "7ba"	:["반음이 2개이므로 간격이 줄어들어","음정입니다 \n(장7도 음정의 기본 반음수는 1개)"],
  "8cc"	:["반음이 2개이므로","음정입니다 \n(완전8도 음정의 기본 반음수는 2개)"],
  "8dd"	:["반음이 2개이므로","음정입니다 \n(완전8도 음정의 기본 반음수는 2개)"],
  "8ee"	:["반음이 2개이므로","음정입니다 \n(완전8도 음정의 기본 반음수는 2개)"],
  "8ff"	:["반음이 2개이므로","음정입니다 \n(완전8도 음정의 기본 반음수는 2개)"],
  "8gg"	:["반음이 2개이므로","음정입니다 \n(완전8도 음정의 기본 반음수는 2개)"],
  "8aa"	:["반음이 2개이므로","음정입니다 \n(완전8도 음정의 기본 반음수는 2개)"],
  "8bb"	:["반음이 2개이므로","음정입니다 \n(완전8도 음정의 기본 반음수는 2개)"],
};

Map commentaryUpAccidental = {
  "s"	:"위에 있는 음에 붙은 샵으로 인해 음정간 간격이 늘어나고",
  "f"	:"위에 있는 음에 붙은 플렛으로 인해 음정간 간격이 줄어들고",
  "ds"	:"위에 있는 음에 붙은 더블샵으로 인해 음정간 간격이 늘어나고",
  "df"	:"위에 있는 음에 붙은 더블플렛으로 인해 음정간 간격이 줄어들고",
};

Map commentaryDownAccidental = {
  "s"	:"아래에 있는 음에 붙은 샵으로 인해 음정간 간격이 줄어들고 ",
  "f"	:"아래에 있는 음에 붙은 플렛으로 인해 음정간 간격이 늘어나고",
  "ds"	:"아래에 있는 음에 붙은 더블샵으로 인해 음정간 간격이 줄어들고",
  "df"	:"아래에 있는 음에 붙은 더블플렛으로 인해 음정간 간격이 늘어나고",
};


// showBottomResult 내부에서
// 음을 sort 한 뒤, 간격 및 한글 결과 내뱉는 함수
// List<dynamic> randomNote
List<dynamic> getResultAllEasy(List<dynamic> randomNote, bool inverseTF){

  List<dynamic> randomNoteAnswer = [] ;

  randomNoteAnswer.add(randomNote[0]);
  randomNoteAnswer.add(randomNote[1]);

  randomNoteAnswer.sort();

  String answerReal;

  if (inverseTF){
    // inverse True
    answerReal = randomNoteAnswer[0].interval(randomNoteAnswer[1])
        .inverted.toString();
  } else {
    // inverse False
    answerReal = randomNoteAnswer[0].interval(randomNoteAnswer[1])
        .toString();
  }

  String answerRealKor = '';

  if (answerReal.length==2){
    answerRealKor = intervalNameEngKor[answerReal.substring(0, 1)] +
        answerReal.substring(1, 2);
  } else {
    answerRealKor = intervalNameEngKor[answerReal.substring(0, 2)] +
        answerReal.substring(2, 3);
  }

  return [randomNoteAnswer, answerReal, answerRealKor];
}

List<dynamic> getResultAllHard(List<dynamic> randomNote,List<dynamic> accidentals, bool inverseTF){

  List<dynamic> randomNoteAnswer = [] ;

  randomNoteAnswer.add(addAccidental(randomNote[0], accidentals[0]));
  randomNoteAnswer.add(addAccidental(randomNote[1], accidentals[1]));

  randomNoteAnswer.sort();

  String answerReal;

  if (inverseTF){
    // inverse True
    answerReal = randomNoteAnswer[0].interval(randomNoteAnswer[1])
        .inverted.toString();
  } else {
    // inverse False
    answerReal = randomNoteAnswer[0].interval(randomNoteAnswer[1])
        .toString();
  }

  String answerRealKor = '';

  if (answerReal.length==2){
    answerRealKor = intervalNameEngKor[answerReal.substring(0, 1)] +
        answerReal.substring(1, 2);
  } else if (answerReal.length==3) {
    answerRealKor = intervalNameEngKor[answerReal.substring(0, 2)] +
        answerReal.substring(2, 3);
  }

  return [randomNoteAnswer, answerReal, answerRealKor];
}
