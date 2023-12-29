import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe8d3d6),
      body: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height/2-85,
              left: MediaQuery.of(context).size.width/2-5 ,
              child: Container(
                // color: Colors.grey,
                child: Image.asset('assets/images/note11.png',
                  fit: BoxFit.contain,
                  height: 80,
                  width: 80,),
              ),
            ),
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   child:Container(
            //     alignment: Alignment.center,
            //     child: Lottie.asset('assets/images/Animation - 1700747597611.json'),
            //   ),
            // ),
            Center(
              child: Container(
                alignment: Alignment.center,
                child: Lottie.asset('assets/images/Animation - 1700747597611.json'),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height/2+45,
                left: MediaQuery.of(context).size.width/2-38,
                child: Text('음 정 박 사',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                )
            )
          ]
      ),
    );

  }
}