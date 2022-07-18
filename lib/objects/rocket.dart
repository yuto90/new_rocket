import 'package:flutter/material.dart';
import '../size_config.dart';

class MyRocket extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/rocket.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 8,
      width: SizeConfig.blockSizeHorizontal! * 8,
    );
  }
}
