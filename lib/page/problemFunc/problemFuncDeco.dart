import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'colorList.dart';

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
ButtonStyle nextProblemButtonStyle(easyOrHard){
  return ElevatedButton.styleFrom(
      backgroundColor: (easyOrHard=='easy')? Color(0xff74bb6d): color2,
      foregroundColor: (easyOrHard=='easy')? color1 : color2,
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