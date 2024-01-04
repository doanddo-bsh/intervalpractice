import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intervalpractice/page/problemFunc/colorList.dart';
import 'thirdPageProblem.dart';
import 'easyProblem/easyProblemType1.dart';
import 'easyProblem/easyProblemType2.dart';
import 'easyProblem/easyProblemType3.dart';
import 'hardProblem/hardProblemType1.dart';
import 'hardProblem/hardProblemType2.dart';
import 'hardProblem/hardProblemType3.dart';
import 'easyProblem/resultTestPage.dart';

class FirstProblemTypeList extends StatefulWidget {
  const FirstProblemTypeList({Key? key}) : super(key: key);

  @override
  State<FirstProblemTypeList> createState() => _FirstProblemTypeListState();
}

class _FirstProblemTypeListState extends State<FirstProblemTypeList>
  with SingleTickerProviderStateMixin {

  late TabController tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    tabController.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _body()
    );
  }

  Widget _body() {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 610.h,
            child: Column(
              children: [
                _tabBar(),
                // Expanded 없으면 오류 발생
                // Horizontal viewport was given unbounded height.
                Expanded(child: _tabBarView()),
                // _tabBarView(),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10.w, 10.h, 30.w, 30.h),
                child: Tooltip(
                  textStyle: TextStyle(color: Colors.black54),
                  decoration: BoxDecoration(color: Color(0xffeeeeee),
                  borderRadius: BorderRadius.circular(10)),
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: Duration(milliseconds: 2500),
                  message:
                  'Easy는 임시표가 없는 기본 계이름입니다\nHard는 여러종류의 임시표를 포함하고 있습니다',
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabBar() {
    return TabBar(
      controller: tabController,
      labelColor: Colors.orangeAccent,
      unselectedLabelColor: Colors.blue,
      indicatorColor: Colors.red,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2),
        insets: EdgeInsets.symmetric(horizontal: 120)
      ),
      labelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 16,
      ),
      tabs: const [
        Tab(child: Text('Easy',
                        style: TextStyle(
                            color: Color(0xff377a46),
                            fontWeight: FontWeight.bold,
                            fontSize: 15
                        ),
                      ),
        ),
        Tab(child: Text('Hard',
                      style: TextStyle(
                          color: Color(0xff873a32),
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                      ),
                    )
        ),
      ],
    );
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        ListViewEasy(),
        ListViewHard(),
      ],
    );
  }
}

class ListViewEasy extends StatelessWidget {
  ListViewEasy({Key? key}) : super(key: key);

  List<List<String>> mainTitleAndContentsEasy = [
    ['음정 문제 1','악보 위의 음정을 계산하여\n정답을 맞춰보세요'],
    ['음정 문제 2','주어진 음정을 보고 알맞은\n계이름을 계산하여 맞춰보세요'],
    ['음정 문제 3','주어진 음정의 자리바꿈 음정을\n계산하여 정답을 맞춰보세요'],
  ];

  // List problemPage = [EasyProblemType1(),EasyProblemType2(),EasyProblemType3()];
  List problemPage = [ResultTestPage(),EasyProblemType2(),EasyProblemType3()];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 550.h,
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding:const EdgeInsets.all(10),
              itemCount:mainTitleAndContentsEasy.length,
              itemBuilder: (BuildContext context, int index){
                return Padding(
                  padding: const EdgeInsets.all(7.5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              problemPage[index]
                          )
                      );
                    },
                    child: Container(
                        height: 155.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Color(0xffdedede),
                              width: 2.3
                          ),
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child:Row(
                          children: [
                            Container(
                              width: 105.w,
                              height: 105.h,
                              child: Stack(children: [
                                Center(
                                  child: SizedBox(
                                    height: 73.h,
                                    width: 73.w,
                                    child: Image(
                                        image: AssetImage('assets/music_2805328.png')
                                    ),
                                  ),
                                ),
                              ],
                              ),
                            ),
                            // SizedBox(width: 10,),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  SizedBox(height: 7,),
                                  // const SizedBox(height: 15,),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: 180.w,
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(mainTitleAndContentsEasy[index][0],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16
                                          ),)
                                    ),
                                  ),
                                  // const SizedBox(height: 5,),
                                  SizedBox(
                                    width: 180.w,
                                    child: AutoSizeText(mainTitleAndContentsEasy[index][1],
                                      maxLines: 4,
                                    ),
                                  ),
                                ]
                            ),

                          ],
                        )
                    ),
                  ),
                );
              }

          ),
        ),

      ],
    );
  }
}


class ListViewHard extends StatelessWidget {
  ListViewHard({Key? key}) : super(key: key);

  List<List<String>> mainTitleAndContentsEasy = [
    ['음정 문제1','악보 위의 음정을 계산하여\n정답을 맞춰보세요.'],
    ['음정 문제2','주어진 음정을 보고 빈칸에 들어갈 \n계이름을 맞춰보세요.'],
    ['음정 문제3','주어진 음정의 자리바꿈 음정을 \n계산하여 정답을 맞춰보세요.'],
  ];

  List problemPage = [HardProblemType1(),HardProblemType2(),HardProblemType3()];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 530.h,
          child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding:const EdgeInsets.all(5),
              itemCount:mainTitleAndContentsEasy.length,
              itemBuilder: (BuildContext context, int index){
                return Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              problemPage[index]
                          )
                      );
                    },
                    child: Container(
                        height: 155.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.grey,
                              width: 2.0
                          ),
                          borderRadius: BorderRadius.circular(17.0),
                        ),
                        child:Row(
                          children: [
                            Container(
                              width: 130.w,
                              height: 130.h,
                              child: Stack(children: [
                                Center(
                                  child: SizedBox(
                                    height: 73.h,
                                    width: 73.w,
                                    child: Image(
                                        image: AssetImage('assets/music_2805328.png')
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 30,
                                  left: 24,
                                  child: SizedBox(
                                    height: 30.h,
                                    width: 15.w,
                                    child: Image(
                                        image: AssetImage('assets/sharp1.png',
                                        ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 70,
                                  left: 10,
                                  child: SizedBox(
                                    height: 30.h,
                                    width: 30.w,
                                    child: Image(
                                        image: AssetImage('assets/flat1.png')
                                    ),
                                  ),
                                ),
                              ],),
                              // decoration: BoxDecoration(
                              //   image: DecorationImage(
                              //     image: AssetImage('assets/music_2805328.png'),
                              //   ),
                              // ),
                            ),
                            // SizedBox(width: 10,),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children:[
                                  const SizedBox(height: 15,),
                                  Container(
                                    margin: EdgeInsets.all(10),
                                    width: 200.w,
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(mainTitleAndContentsEasy[index][0],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16
                                          ),)
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  SizedBox(
                                    width: 200.w,
                                    child: AutoSizeText(mainTitleAndContentsEasy[index][1],
                                      maxLines: 4,
                                    ),
                                  ),
                                ]
                            ),

                          ],
                        )
                    ),
                  ),
                );
              }

          ),
        ),
      ],
    );
  }
}

