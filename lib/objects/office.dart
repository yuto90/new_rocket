import 'package:flutter/material.dart';
import '../size_config.dart';

class Office extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/office.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 10,
      width: SizeConfig.blockSizeHorizontal! * 8,
    );
  }
}
