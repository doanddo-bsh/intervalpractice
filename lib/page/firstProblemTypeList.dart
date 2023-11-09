import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'secondePageProblem.dart';

class FirstProblemTypeList extends StatefulWidget {
  FirstProblemTypeList({Key? key}) : super(key: key);

  @override
  State<FirstProblemTypeList> createState() => _FirstProblemTypeListState();
}

class _FirstProblemTypeListState extends State<FirstProblemTypeList> {
  bool isEasy = true ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(),
                  TextButton(
                      child: Text('easy',
                          style: TextStyle(
                            color: Colors.black
                          ),
                      ),
                      onPressed: (){
                        setState(() {
                          isEasy = true;
                        });
                      },
                  ),
                  VerticalDivider(),
                  TextButton(
                    child: Text('hard',
                      style: TextStyle(
                        color: Colors.black
                    ),
                  ),
                    onPressed: (){
                      isEasy = false;
                    },
                  ),
                  SizedBox(),
                ],
              ),
            ),
            Container(
              height: 30.0,
              child: TextButton(
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SecondePageProblem()
                      ),
                    );
                  }, child: Text('임시버튼2222ㅈㅈㄴㄴ')
              ),
            ),
            Expanded(child:isEasy? ListViewEasy() : ListViewHard()
            )
          ],
        ),
      ),
    );
  }
}

class ListViewEasy extends StatelessWidget {
  ListViewEasy({Key? key}) : super(key: key);

  List<List<String>> mainTitleAndContentsEasy = [
    ['음정 문제1','악보 위의 음정을 계산하여 정답을 맞춰보세요.'],
    ['음정 문제2','주어진 음정을 보고 등러갈 음을 계산해보세요.'],
    ['음정 문제3','인벌스 넣을 거임.'],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding:const EdgeInsets.all(8),
        itemCount:mainTitleAndContentsEasy.length,
        itemBuilder: (BuildContext context, int index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 150,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black
                    )
                ),
                child:Row(
                  children: [
                    Container(
                        height:100,
                        width: 100,
                        child: FittedBox(
                          child: Icon(Icons.music_note,
                          ),
                        )
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:[
                          SizedBox(height: 15,),
                          SizedBox(
                            width: 200,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(mainTitleAndContentsEasy[index][0])
                            ),
                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            width: 200,
                            child: AutoSizeText(mainTitleAndContentsEasy[index][1],
                              maxLines: 4,
                            ),
                          ),
                        ]
                    ),
                  ],
                )
            ),
          );
        }

    );
  }
}


class ListViewHard extends StatelessWidget {
  ListViewHard({Key? key}) : super(key: key);

  List<List<String>> mainTitleAndContentsHard = [
    ['음정 문제1','악보 위의 음정을 계산하여 정답을 맞춰보세요.'],
    ['음정 문제2','주어진 음정을 보고 등러갈 음을 계산해보세요.'],
    ['음정 문제3','인벌스 넣을 거임.'],
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding:const EdgeInsets.all(8),
        itemCount:mainTitleAndContentsHard.length,
        itemBuilder: (BuildContext context, int index){
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: 150,
                decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.black
                    )
                ),
                child:Row(
                  children: [
                    Container(
                        height:100,
                        width: 100,
                        child: FittedBox(
                          child: Icon(Icons.music_note,
                          ),
                        )
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children:[
                          SizedBox(height: 15,),
                          SizedBox(
                            width: 200,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(mainTitleAndContentsHard[index][0])
                            ),
                          ),
                          SizedBox(height: 10,),
                          SizedBox(
                            width: 200,
                            child: AutoSizeText(mainTitleAndContentsHard[index][1],
                              maxLines: 4,
                            ),
                          ),
                        ]
                    ),
                  ],
                )
            ),
          );
        }

    );
  }
}

