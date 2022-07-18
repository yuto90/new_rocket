import 'package:flutter/material.dart';
import '../size_config.dart';

class Cloud extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/cloud.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 10,
      width: SizeConfig.blockSizeVertical! * 20,
    );
  }
}
