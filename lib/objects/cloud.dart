import 'package:flutter/material.dart';
import '../size_config.dart';

class Cloud extends StatelessWidget {
  double vertical;
  double horizontal;
  Cloud({required this.vertical, required this.horizontal});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.red,
      child: Image(
        image: AssetImage('lib/images/cloud.png'),
        fit: BoxFit.cover,
        height: vertical,
        width: horizontal,
      ),
    );
  }
}
