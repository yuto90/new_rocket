import 'package:flutter/material.dart';
import '../size_config.dart';

class TokyoTower extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.red,
      child: Image(
        image: AssetImage('lib/images/tokyo_tower.png'),
        fit: BoxFit.cover,
        height: SizeConfig.blockSizeVertical! * 30,
        width: SizeConfig.blockSizeVertical! * 18,
      ),
    );
  }
}
