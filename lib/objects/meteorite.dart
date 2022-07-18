import 'package:flutter/material.dart';

class Meteorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/meteorite.png'),
      fit: BoxFit.cover,
      height: 100,
      width: 100,
    );
  }
}
