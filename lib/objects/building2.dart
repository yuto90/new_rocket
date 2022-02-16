import 'package:flutter/material.dart';
import '../size_config.dart';

class Building2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      child: Image(
        image: AssetImage('lib/images/billding2.png'),
        fit: BoxFit.cover,
        height: SizeConfig.blockSizeVertical! * 15,
        width: SizeConfig.blockSizeVertical! * 9,
      ),
    );
  }
}
