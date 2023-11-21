import 'package:flutter/material.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:lottie/lottie.dart';

class ScorePage extends StatelessWidget {
  const ScorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
            child: Column(
                  children: [
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 7,),
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 600,
                                  height: 450,
                                  color: Colors.lightGreen.withOpacity(0.4),
                                ),),
                            ),
                            Center(
                              child: Container(
                                child: Column(
                                  children: [
                                    SizedBox(height: 60,),
                                    Container(
                                        child: Text('이번 문제의 점수는',
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.grey[700]
                                          ),)),
                                    // SizedBox(height: 30,),
                                    Stack(
                                      children:[
                                        Container(
                                          child: Lottie.asset
                                            ('assets/animation/star2.json'),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(40, 60, 0, 0),
                                          child: Container(
                                            child: Text('85점',
                                            style: TextStyle(
                                              fontSize: 60,
                                              fontWeight: FontWeight.bold
                                               )),
                                            ),
                                        ),
                                     ],),
                                    // SizedBox(height: 30,),
                                    Container(
                                        child: Text('정말 멋져요! 내가바로 음정고수🎉',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.grey[700]
                                            ))),
                                    SizedBox(height: 20,),
                                    Container(
                                        child: Text('10문제중에서 8문제를 맞췄습니다',
                                            style:
                                            TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold
                                            ))),
                                    SizedBox(height: 20,),
                                    Container(
                                      height: 40,
                                      width: 300,
                                      child: ElevatedButton(
                                        child: Text('틀린 문제 다시 풀기',
                                        style: TextStyle(
                                          color: Colors.grey[700]
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.yellow[200]

                                        ),
                                        onPressed: () {},
                                      ) ,
                                    )
                                ]),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 1, 0, 2),
                    child: Divider(thickness: 1,
                      indent: 7,
                      endIndent: 7,),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                            width: 600,
                            height: 400,
                            color: Colors.grey[300],
                          ),),
                          Container(
                            margin: EdgeInsets.all(15),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(child:
                                Text('계속해서 문제를 푸시겠습니까?',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold
                                  ),),
                                ),
                                SizedBox(height: 13,),
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(onPressed: (){},
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)
                                              )
                                          ),
                                          child: Text('네',
                                            style: TextStyle(
                                                color: Colors.grey[700]
                                            ),)),
                                      SizedBox(width: 40,),
                                      ElevatedButton(onPressed: (){},
                                          style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10)
                                              )
                                          ),
                                          child: Text('아니오',
                                              style: TextStyle(
                                                  color: Colors.grey[700]))
                                      )],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}
