import 'package:flutter/material.dart';
import '../size_config.dart';

class Star extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/star.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 5,
      width: SizeConfig.blockSizeVertical! * 5,
    );
  }
}
