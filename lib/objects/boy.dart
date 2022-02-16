import 'package:flutter/material.dart';

class Boy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.red,
      child: Image(
        image: AssetImage('lib/images/boy.png'),
        fit: BoxFit.cover,
        height: 40,
        width: 40,
      ),
    );
  }
}
