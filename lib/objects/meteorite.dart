import 'package:flutter/material.dart';

class Meteorite extends StatelessWidget {
  double vertical;
  double horizontal;
  Meteorite({required this.vertical, required this.horizontal});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage('lib/images/meteorite.png'),
      fit: BoxFit.cover,
      height: vertical,
      width: horizontal,
    );
  }
}
