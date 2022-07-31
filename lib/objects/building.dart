import 'package:flutter/material.dart';
import '../size_config.dart';

class Building extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/billding.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 25,
      width: SizeConfig.blockSizeHorizontal! * 22,
    );
  }
}
