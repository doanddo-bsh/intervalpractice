import 'package:flutter/material.dart';

class ThirdPageProblem extends StatefulWidget {
  const ThirdPageProblem({super.key});

  @override
  State<ThirdPageProblem> createState() => _ThirdPageProblemState();
}

class _ThirdPageProblemState extends State<ThirdPageProblem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('test'),),
      body: Column(
        children: [
          Text('thirdPage test')
        ],
      ),
    );
  }
}
