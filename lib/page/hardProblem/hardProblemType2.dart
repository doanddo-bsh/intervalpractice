// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:music_notes/music_notes.dart';
import 'dart:math';
import '../problemFunc/problemFunc.dart';
import '../problemFunc/problemFuncDeco.dart';
import '../problemFunc/problemVarList.dart';
import 'package:intervalpractice/page/problemFunc/colorList.dart';
import '../problemFunc/resultPage.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../problemFunc/admobClass.dart';
import 'package:provider/provider.dart';
import '../problemFunc/providerCounter.dart';
import '../problemFunc/admobFunc.dart';

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

  String? intervalNumber;

  Note? answerNote;

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
        style: answerButtonDesign(intervalNumber,number,'hard',context),
        child: Text(number
          , style: answerButtonTextDesign,
        )
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

            // for Full-page advertisement count solved problem
            Provider.of<CounterClass>(context, listen: false).incrementSolvedProblemCount();

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
        style:answerButtonDesign(answerNote,answerCheck,'hard',context),
        child: Text(intervalName, style: answerButtonTextDesign,)
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

    if (commentaryType2['$answerRealKor도'] == null) {
      commentaryResult = '' ;
    } else {
      commentaryResult = commentaryType2['$answerRealKor도']!;
    }


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
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            )
        ),
        enableDrag: false,
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 185.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 27.h,),
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
                const SizedBox(height: 7,),
                Text('정답 : $realNoteNoteAccidentalKr(${realNoteAccidental.toString()})',
                  style: TextStyle(
                    color: color4,
                    fontSize : 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7,),
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
          );
        },
      );

    } else {


      wrongProblems += [randomNoteNumber] ;
      wrongProblemsAccidentals += [accidentals];
      upDownWorngList += [upDown];


      showModalBottomSheet<void>(
        backgroundColor: const Color(0xffd7b1b1),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            )
        ),
        enableDrag: false,
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 185.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(height: 27.h,),
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
                const SizedBox(height: 7,),
                Text('정답 : $realNoteNoteAccidentalKr(${realNoteAccidental.toString()})',
                  style: TextStyle(
                    color: color6,
                    fontSize : 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7,),
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
          );
        },
      );
    }
  }

  Widget nextProblem(String buttonText,String rightWrong){
    return ElevatedButton(

        onPressed: (){
          if (problemNumber==10){
            setState(() {
              problemNumber = 0;
            });
          }

          List<List<dynamic>> noteHeightListProblem = getProblemListNote(
            note_height_list,
            randomItems,
          );

          setState(() {
            // 문제 적용
            randomItems = [noteHeightListProblem[0][0],noteHeightListProblem[1][0]];
            // randomItems.sort();
            randomNoteNumber = [noteHeightListProblem[0][1],noteHeightListProblem[1][1]];
            // randomNoteNumber.sort();
            randomNote = [noteHeightListProblem[0][2],noteHeightListProblem[1][2]];
            // randomNote.sort();

            upDown = Random().nextInt(2);

            answerNote = null;
            intervalNumber = null;

            problemNumber += 1;

            accidentals = accidentalsFinal(randomNote);
          });

          Navigator.pop(context);

        },
      style: nextProblemButtonStyle('easy',rightWrong),
      child: Text(buttonText,
        style: nextProblemButtonTextStyle,
      ),
    );
  }


  // for full screen ad
  InterstitialAd? _interstitialAd;

  final fullScreenAdUnitId = AdMobServiceFullScreen.fullScreenAdUnitId ;

  /// Loads an interstitial ad.
  void loadAd() {
    InterstitialAd.load(
        adUnitId: fullScreenAdUnitId!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});

            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            _interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  Widget nextProblemResult(){
    return ElevatedButton(

        onPressed: (){

          // show full ad if problemSolvedCount more then 30
          if (Provider.of<CounterClass>(context, listen: false)
              .solvedProblemCount >= criticalNumberSolved) {
            loadAd();
            if (_interstitialAd != null) {
              _interstitialAd?.show();
              Provider.of<CounterClass>(context, listen: false)
                  .resetSolvedProblemCount();
            }
          }

          numberOfRight = 0 ;
          wrongProblems = [];
          wrongProblemsAccidentals = [];
          wrongProblemMode = false ;

          List<List<dynamic>> noteHeightListProblem = getProblemListNote(
            note_height_list,
            randomItems,
          );

          setState(() {
            // 문제 적용
            randomItems = [noteHeightListProblem[0][0],noteHeightListProblem[1][0]];
            // randomItems.sort();
            randomNoteNumber = [noteHeightListProblem[0][1],noteHeightListProblem[1][1]];
            // randomNoteNumber.sort();
            randomNote = [noteHeightListProblem[0][2],noteHeightListProblem[1][2]];
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


  Widget wrongProblemNextProblem(String buttonText, String rightWrong){
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
        style: nextProblemButtonStyle('easy',rightWrong),
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


        wrongProblems = [] ;
        wrongProblemsAccidentals = [] ;

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
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700]
        ),
      ),
    );
  }

  Widget showResult(String rightWrong){

    // Navigator.pop(context);

    return ElevatedButton(
        onPressed: (){

          Navigator.pop(context);

          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            enableDrag: false,
            isDismissible:false,
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

            },
          );
        },
        style: nextProblemButtonStyle('easy',rightWrong),
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

    List<List<dynamic>> noteHeightListProblem = getProblemListNote(
        note_height_list, randomItems
    );

    randomItems = [noteHeightListProblem[0][0],noteHeightListProblem[1][0]];
    // randomItems.sort();
    randomNoteNumber = [noteHeightListProblem[0][1],noteHeightListProblem[1][1]];
    // randomNoteNumber.sort();
    randomNote = [noteHeightListProblem[0][2],noteHeightListProblem[1][2]];
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


    // (upDown!=0)?
    // print(engToKorNote[randomNote[0].note]):
    // print(engToKorNote[randomNote[1].note]);

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
          SizedBox(
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
          Text('[ 주어진 음정 : $answerRealKorTemp도 ]',style: explainTextStyle2),
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
          const Expanded(child: SizedBox()),
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
}
