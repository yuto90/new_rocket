import 'package:flutter/material.dart';

class Heri extends StatelessWidget {
  final heightSize;
  final widthSize;
  Heri({this.heightSize, this.widthSize});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/heri.png'),
      fit: BoxFit.cover,
      height: 40,
      width: 40,
    );
  }
}
