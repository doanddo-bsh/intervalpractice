import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intervalpractice/page/problemFunc/providerCounter.dart';
import 'package:lottie/lottie.dart';
import 'package:music_notes/music_notes.dart';
import 'package:provider/provider.dart';
import '../problemFunc/problemFunc.dart';
import '../problemFunc/problemFuncDeco.dart';
import '../problemFunc/problemVarList.dart';
import 'package:intervalpractice/page/problemFunc/colorList.dart';
import '../problemFunc/resultPage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../problemFunc/admobClass.dart';


class EasyProblemType1 extends StatefulWidget {
  const EasyProblemType1({super.key});

  @override
  State<EasyProblemType1> createState() => _EasyProblemType1State();
}

class _EasyProblemType1State extends State<EasyProblemType1> {

  // 변수 초기화
  List<double> randomItems = [];
  late List<int> randomNoteNumber ;
  late List<PositionedNote> randomNote ;

  List<List<int>> wrongProblems = [];
  List<List<int>> wrongProblemsSave = [];

  bool wrongProblemMode = false ;

  int numberOfRight = 0 ;

  String? intervalNumber = null;

  Widget intervalNumberButton(String number){
    return ElevatedButton(
        onPressed: answerInterval==null?
            (){
          setState(() {intervalNumber = number;});
        } :
            (){
        },
        child: Text(
          number,
          style: answerButtonTextDesign,
        ),
        style: answerButtonDesign(intervalNumber,number,'easy',context)
    );
  }

  // 음정과 음정이름을 함께 보여주는 버튼을 생성하는 함수
  Widget secondeElevatedButton(String intervalName,String
  intervalNumber){
    return ElevatedButton(
        onPressed: answerInterval==null?
            () {
                setState(() {
                  answerInterval = intervalNameKorEng[intervalName] + intervalNumber;
                  showBottomResult(answerInterval!);
                });
              }:
            (){
              // nothing
            },
        child: Text(
            intervalName + intervalNumber + '도',
            style: answerButtonTextDesign
        ),
        style: answerButtonDesign(answerInterval,intervalNameKorEng[intervalName] + intervalNumber,'easy',context)
    );
  }

  Widget showIntervalNameBefore(String intervalNumber){
    return SizedBox(
      child: Column(
        children: [
          Text('음정의 이름을 고르세요',style: explainTextStyle),
          SizedBox(height: 30.0.h,),
          SizedBox(
            height: buttonSizeBasic,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                secondeElevatedButton(
                    '감',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '완전',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '증',
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
                    '겹감',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '단',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '장',
                    intervalNumber
                ),
                secondeElevatedButton(
                    '겹증',
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

  String? answerInterval = null;

  void showBottomResult(String answerInterval){

    // 정답 계산
    List<dynamic> resultAll = getResultAllEasy(randomNote, false);

    // 정답 배분/입력
    List<dynamic> randomNoteAnswer = resultAll[0] ;
    String answerReal = resultAll[1] ;
    String answerRealKor = resultAll[2] ;

    // 해석 해설
    String commentaryResult = commentaryKeyReturn(randomNoteAnswer,
        answerRealKor);

    if (answerInterval == answerReal){

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
                  Text('정답 : ' + answerRealKor + '도',
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
                  Text('정답 : ' + answerRealKor + '도',
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

            answerInterval = null;
            intervalNumber = null;

            problemNumber += 1;
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

            answerInterval = null;
            intervalNumber = null;

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

            randomItems =
            [note_height_list_fix[randomNoteNumber[0]][0],
              note_height_list_fix[randomNoteNumber[1]][0]];
            // randomItems.sort();
            randomNote =
            [note_height_list_fix[randomNoteNumber[0]][2],
              note_height_list_fix[randomNoteNumber[1]][2]];
            // randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

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

          wrongProblems = [] ;

          setState(() {
            // 문제 적용
            randomNoteNumber = wrongProblemsSave[0];
            // randomNoteNumber.sort();

            randomItems =
            [note_height_list_fix[randomNoteNumber[0]][0],
              note_height_list_fix[randomNoteNumber[1]][0]];
            // randomItems.sort();
            randomNote =
            [note_height_list_fix[randomNoteNumber[0]][2],
              note_height_list_fix[randomNoteNumber[1]][2]];
            // randomNote.sort();

            answerInterval = null;
            intervalNumber = null;

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
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
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
                  wrongProblemMode = false ;
                  numberOfRight = 0 ;
                  Navigator.popUntil
                    (context, ModalRoute.withName("/FirstProblemTypeList"));
                },
              );
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

    List<dynamic> randomNoteAnswerTemp = [] ;

    randomNoteAnswerTemp.add(randomNote[0]);
    randomNoteAnswerTemp.add(randomNote[1]);

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

    // return Consumer<Counter>(
    //   builder: (context, counter, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: wrongProblemMode?
            Text("오답문제",
                style: appBarTitleStyle
            ) :
            Text("Easy",
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
                'easy',
                context,
              ),
              // SizedBox(height: 5,),
              Container(
                height: 300.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.black)
                ),
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
                    ),
                    addLine3(randomNote[0],130.w),
                    // Positioned(
                    //   top: 50.75.h, // [50.75,3,Note.a.inOctave(5)],
                    //   left: 130.w,
                    //   child: SizedBox(
                    //     height: 26.5.h,
                    //     child: Stack(
                    //       children: [
                    //         // Image.asset('assets/whole_note_lean.png'),
                    //         addLine1(randomNote[0]),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // addLine2(randomNote[0],130.w),
                    // 음표 2
                    Positioned(
                      top: randomItems[1].h,
                      left: 230.w,
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
                    addLine3(randomNote[1],230.w),
                  ],
                ),
              ),
              // const SizedBox(height: 10.0,),

              Text('음정의 간격을 고르세요',style: explainTextStyle),
              Stack(
                  children: [
                    SizedBox(height: 25.0.h,),
                    // ElevatedButton(onPressed: ()
                    //   {
                    //     setState(() {
                    //       // counter.increment();
                    //       // print('counter.count ${counter.count}');
                    //       // problemNumber = 10;
                    //     });
                    //   }, child: Text('test')
                    // ),
                  ]
              ),
              SizedBox(
                child: Column(
                  children: [
                    SizedBox(
                      height: buttonSizeBasic,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          intervalNumberButton('1'),
                          intervalNumberButton('2'),
                          intervalNumberButton('3'),
                          intervalNumberButton('4'),
                        ],
                      ),
                    ),
                    SizedBox(height: 13.0.h,),
                    SizedBox(
                      height: buttonSizeBasic,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          intervalNumberButton('5'),
                          intervalNumberButton('6'),
                          intervalNumberButton('7'),
                          intervalNumberButton('8'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.0.h,),
              showIntervalName(intervalNumber),
              // SizedBox(height: 30.h,),
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
              SizedBox(height: 30.h,),
            ],
          ),
        );
      }
    // );
  // }
}
