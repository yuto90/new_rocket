import 'package:flutter/material.dart';
import '../size_config.dart';

class City extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/city.png'),
      fit: BoxFit.cover,
      height: SizeConfig.blockSizeVertical! * 45,
      width: double.infinity,
    );
  }
}
