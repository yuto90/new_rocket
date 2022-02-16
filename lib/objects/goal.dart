import 'package:flutter/material.dart';
import '../size_config.dart';

class Goal extends StatelessWidget {
  final double heightSize;
  final double widthSize;
  Goal({required this.heightSize, required this.widthSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.red,
      child: Image(
        image: AssetImage('lib/images/goal.png'),
        fit: BoxFit.cover,
        height: SizeConfig.blockSizeVertical! * heightSize,
        width: SizeConfig.blockSizeVertical! * widthSize,
      ),
    );
  }
}
