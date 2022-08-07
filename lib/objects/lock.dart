import 'package:flutter/material.dart';
import '../size_config.dart';

class Lock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/lock.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 3,
      width: SizeConfig.blockSizeHorizontal! * 6,
    );
  }
}
