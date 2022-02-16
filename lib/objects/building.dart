import 'package:flutter/material.dart';
import '../size_config.dart';

class Building extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Image(
        image: AssetImage('lib/images/billding.png'),
        fit: BoxFit.cover,
        height: SizeConfig.blockSizeVertical! * 23,
        width: SizeConfig.blockSizeVertical! * 10,
      ),
    );
  }
}
