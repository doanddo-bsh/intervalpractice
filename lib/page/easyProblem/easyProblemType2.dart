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
import 'package:provider/provider.dart';
import '../problemFunc/providerCounter.dart';
import '../problemFunc/admobFunc.dart';

class EasyProblemType2 extends StatefulWidget {
  const EasyProblemType2({super.key});

  @override
  State<EasyProblemType2> createState() => _EasyProblemType2State();
}

class _EasyProblemType2State extends State<EasyProblemType2> {

  List<double> randomItems = [];
  late List<int> randomNoteNumber ;
  late List<dynamic> randomNote ;

  List<List<int>> wrongProblems = [];
  List<List<int>> wrongProblemsSave = [];

  bool wrongProblemMode = false ;

  int numberOfRight = 0 ;

  // 위에음 보여줄지 아래음 보여줄지? // type2 전용
  int upDown = 0 ;
  List<int> upDownWorngList = [];
  List<int> upDownWorngListSave = [];

  String? intervalNumber = null;

  Widget intervalNumberButton(String number){
    return ElevatedButton(
        onPressed: answerInterval==null?
            (){
          // for Full-page advertisement count solved problem
          Provider.of<CounterClass>(context, listen: false).incrementSolvedProblemCount();

          setState(() {
            intervalNumber = number;
            // type2는 여기서 결과를 보여줌
            showBottomResult(intervalNumber!);
          });
        } :
            (){
          // print('정답이 이미 들어옴');
        },
        child: Text(number
          , style: answerButtonTextDesign,
        ),
        style:answerButtonDesign(intervalNumber,number,'easy',context)
    );
  }

  // type2는 음정이름 보여주는 부분이 삭제됨
  // 삭제 //

  String? answerInterval = null;

  void showBottomResult(String answerPitchName){

    // 정답 계산
    List<dynamic> resultAll = getResultAllEasy(randomNote, false);

    // 정답 배분/입력
    List<dynamic> randomNoteAnswer = resultAll[0] ;
    String answerReal = resultAll[1] ;
    String answerRealKor = resultAll[2] ;

    print('randomNoteAnswer $randomNoteAnswer');
    print('answerRealKor $answerRealKor');

    // 해석 해설
    // type2 해설은 answerRealKor만 활용함
    String commentaryResult = '' ;

    if (commentaryType2[answerRealKor+'도'] == null) {
      commentaryResult = '' ;
    } else {
      commentaryResult = commentaryType2[answerRealKor+'도']!;
    }

    print('commentaryResult $commentaryResult');

    // type2는 화면에서 보여주지 않은 음이 정답임
    var ptichNameReal = (upDown != 0)?
    randomNote[0]:randomNote[1];

    String ptichNameRealKr = pitchNameEngToKr[ptichNameReal] ;

    if (answerPitchName == ptichNameRealKr){

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
        enableDrag: false,
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
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
                        commentaryToolTip(commentaryResult),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 7,),
                Text('정답 : ' + ptichNameRealKr,
                  style: TextStyle(
                    color: color4,
                    fontSize : 13.0,
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
          );
        },
      );

    } else {

      wrongProblems += [randomNoteNumber] ;
      upDownWorngList += [upDown];

      print('wrongProblems $wrongProblems');
      print('upDownWorngList $upDownWorngList');

      showModalBottomSheet<void>(
        backgroundColor: Color(0xffd7b1b1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0)
            )
        ),
        enableDrag: false,
        isDismissible:false,
        context: context,
        builder: (BuildContext context) {
          return Container(
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
                SizedBox(height: 7,),
                Text('정답 : ' + ptichNameRealKr,
                  style: TextStyle(
                    color: Color(0xff79474e),
                    fontSize : 13.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 7,),
                // const Text('풀이 : ...'),
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

  Widget nextProblem(String buttonText, String right_wrong){
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
          upDownWorngList = [];
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
            upDown = upDownWorngListSave[problemNumber-1];

            randomItems =
            [note_height_list_fix[randomNoteNumber[0]][0],
              note_height_list_fix[randomNoteNumber[1]][0]];
            randomNote =
            [note_height_list_fix[randomNoteNumber[0]][2],
              note_height_list_fix[randomNoteNumber[1]][2]];

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
        upDownWorngListSave = upDownWorngList;

        print('wrongProblemsSave $wrongProblemsSave');
        print('wrongProblems $wrongProblems');
        wrongProblems = [] ;

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
      style: nextProblemButtonStyle('easy',right_wrong),
      child: Text('결과보기',
        style: nextProblemButtonTextStyle,
      ),
    );
  }

  // Widget showResult(String right_wrong){
  //
  //   // Navigator.pop(context);
  //
  //   return ElevatedButton(
  //       onPressed: (){
  //
  //         Navigator.pop(context);
  //
  //         showModalBottomSheet<void>(
  //           context: context,
  //           isScrollControlled: true,
  //           builder: (BuildContext context) {
  //             return Container(
  //               decoration: const BoxDecoration(
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(30),
  //                   topRight: Radius.circular(30),
  //                 ),
  //               ),
  //               height: MediaQuery.of(context).size.height * 1.0,
  //               child: Center(
  //                 child:
  //                 SafeArea(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Column(
  //                       children: [
  //                         Container(
  //                           child: Column(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             crossAxisAlignment: CrossAxisAlignment.center,
  //                             children: [
  //                               SizedBox(height: 40,),
  //                               Stack(
  //                                 children: [
  //                                   Padding(
  //                                     padding: const EdgeInsets.all(15.0),
  //                                     child: ClipRRect(
  //                                       borderRadius: BorderRadius.circular(20),
  //                                       child: Container(
  //                                         width: 600.w,
  //                                         height: 450.h,
  //                                         color: Colors.lightGreen.withOpacity(0.4),
  //                                       ),),
  //                                   ),
  //                                   Center(
  //                                     child: Container(
  //                                       child: Column(
  //                                           children: [
  //                                             SizedBox(height: 60,),
  //                                             Container(
  //                                                 child: Text('이번 문제의 점수는',
  //                                                   style: TextStyle(
  //                                                       fontSize: 25,
  //                                                       color: Colors.grey[700]
  //                                                   ),)),
  //                                             // SizedBox(height: 30,),
  //                                             Stack(
  //                                               children:[
  //                                                 Container(
  //                                                   child: Lottie.asset
  //                                                     ('assets/animation/star2.json'),
  //                                                 ),
  //                                                 Padding(
  //                                                   padding: const EdgeInsets.fromLTRB(40, 60, 0, 0),
  //                                                   child: Container(
  //                                                     child:
  //                                                     wrongProblemMode?
  //                                                     Text
  //                                                       ('${
  //                                                         (numberOfRight/wrongProblemsSave.length *
  //                                                             100).round()}점',
  //                                                         style: TextStyle(
  //                                                             fontSize: 60,
  //                                                             fontWeight: FontWeight.bold
  //                                                         )
  //                                                     ):Text
  //                                                       ('${
  //                                                         (numberOfRight/10 *
  //                                                             100).round()}점',
  //                                                         style: TextStyle(
  //                                                             fontSize: 60,
  //                                                             fontWeight: FontWeight.bold
  //                                                         )
  //                                                     ),
  //                                                   ),
  //                                                 ),
  //                                               ],),
  //                                             // SizedBox(height: 30,),
  //                                             Container(
  //                                                 child: Text('정말 멋져요! 내가바로 음정고수🎉',
  //                                                     style: TextStyle(
  //                                                         fontSize: 20,
  //                                                         color: Colors.grey[700]
  //                                                     ))),
  //                                             SizedBox(height: 20,),
  //                                             Container(
  //                                                 child: wrongProblemMode?
  //                                                 Text
  //                                                   ('${wrongProblemsSave.length
  //                                                     .toString()}문제중에서 '
  //                                                     '${numberOfRight}문제를 '
  //                                                     '맞췄습니다',
  //                                                     style:
  //                                                     TextStyle(
  //                                                         fontSize: 20,
  //                                                         fontWeight: FontWeight.bold
  //                                                     )
  //                                                 ) : Text
  //                                                   ('10문제중에서 '
  //                                                     '${numberOfRight}문제를 '
  //                                                     '맞췄습니다',
  //                                                     style:
  //                                                     TextStyle(
  //                                                         fontSize: 20,
  //                                                         fontWeight: FontWeight.bold
  //                                                     )
  //                                                 )
  //                                             ),
  //                                             SizedBox(height: 20,),
  //                                             Container(
  //                                               height: 40,
  //                                               width: 300,
  //                                               child: wrongProblemSolveStart
  //                                                 ('틀린 문제 다시 풀기'),
  //                                             )
  //                                           ]),
  //                                     ),
  //                                   ),
  //
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.fromLTRB(0, 1, 0, 2),
  //                           child: Divider(thickness: 1,
  //                             indent: 7,
  //                             endIndent: 7,),
  //                         ),
  //                         Expanded(
  //                           child: Padding(
  //                             padding: const EdgeInsets.all(8.0),
  //                             child: Stack(
  //                               children: [
  //                                 ClipRRect(
  //                                   borderRadius: BorderRadius.circular(20),
  //                                   child: Container(
  //                                     width: 600,
  //                                     height: 400,
  //                                     color: Colors.grey[300],
  //                                   ),),
  //                                 Container(
  //                                   margin: EdgeInsets.all(15),
  //                                   child: Column(
  //                                     mainAxisAlignment: MainAxisAlignment.center,
  //                                     children: [
  //                                       Container(child:
  //                                       Text('계속해서 문제를 푸시겠습니까?',
  //                                         style: TextStyle(
  //                                             fontSize: 17,
  //                                             fontWeight: FontWeight.bold
  //                                         ),),
  //                                       ),
  //                                       SizedBox(height: 13,),
  //                                       Center(
  //                                         child: Row(
  //                                           mainAxisAlignment: MainAxisAlignment.center,
  //                                           children: [
  //                                             nextProblemResult(),
  //                                             SizedBox(width: 40,),
  //                                             ElevatedButton(
  //                                               onPressed: (){
  //                                                 wrongProblems = [];
  //                                                 upDownWorngList = [];
  //                                                 wrongProblemMode = false ;
  //                                                 numberOfRight = 0 ;
  //                                                 Navigator.popUntil
  //                                                   (context, ModalRoute.withName(Navigator.defaultRouteName));
  //                                               },
  //                                               style: ElevatedButton.styleFrom(
  //                                                   shape: RoundedRectangleBorder(
  //                                                       borderRadius: BorderRadius.circular(10)
  //                                                   )
  //                                               ),
  //                                               child: Text('아니오',
  //                                                   style: TextStyle(
  //                                                       color: Colors.grey[700])
  //                                               ),
  //                                             )],
  //                                         ),
  //                                       ),
  //
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       },
  //       style: nextProblemButtonStyle('easy',right_wrong),
  //       child: Text('결과보기',
  //         style: nextProblemButtonTextStyle,
  //       ),
  //   );
  // }

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

    (upDown==0)?
    print(engToKorNote[randomNote[0].note]):
    print(engToKorNote[randomNote[1].note]);

    List<dynamic> randomNoteAnswerTemp = [] ;

    randomNoteAnswerTemp.add(randomNote[0]);
    randomNoteAnswerTemp.add(randomNote[1]);

    randomNoteAnswerTemp.sort();

    print('randomNoteAnswerTemp $randomNoteAnswerTemp');

    print([pitchNameEngToKr[randomNoteAnswerTemp[0]],
      pitchNameEngToKr[randomNoteAnswerTemp[1]]]);

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
    // 주어진 음정!
    print('answerRealKorTemp $answerRealKorTemp');

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
              ],
            ),
          ),
          // const SizedBox(height: 10.0,),

          Text('[ 주어진 음정 : $answerRealKorTemp'+'도 ]',style: explainTextStyle2),
          Stack(
              children:[
                SizedBox(height: 55.h,),
                // ElevatedButton(onPressed: (){
                //   setState(() {
                //     problemNumber = 10;
                //   });
                // },
                //     child: Text('test')
                // ),
              ]
          ),
          (upDown == 0)?
          (randomNoteNumber[0] < randomNoteNumber[1])?
          Text('주어진 음정을 위해 필요한 아래↓ 계이름은?',style: explainTextStyle):
          Text('주어진 음정을 위해 필요한 위↑ 계이름은?',style: explainTextStyle):
          (randomNoteNumber[0] < randomNoteNumber[1])?
          Text('주어진 음정을 위해 필요한 위↑ 계이름은?',style: explainTextStyle):
          Text('주어진 음정을 위해 필요한 아래↓ 계이름은?',style: explainTextStyle),
          SizedBox(height: 30.0.h,),
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
}
