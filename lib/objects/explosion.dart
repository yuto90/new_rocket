import 'package:flutter/material.dart';
import '../size_config.dart';

class Explosion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/explosion.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 15,
      width: SizeConfig.blockSizeHorizontal! * 30,
    );
  }
}
