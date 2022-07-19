import 'package:flutter/material.dart';
import '../size_config.dart';

class MyRocket extends StatelessWidget {
  bool turboFlg;
  MyRocket({required this.turboFlg});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.green,
      height: SizeConfig.blockSizeVertical! * 10,
      width: SizeConfig.blockSizeHorizontal! * 10,
      child: Stack(
        children: [
          turboFlg
              ? Align(
                  alignment: Alignment(0, 1.4),
                  child: SizedBox(
                    child: Image(
                      image: AssetImage('lib/images/turbo.png'),
                      fit: BoxFit.cover,
                      height: SizeConfig.blockSizeVertical! * 4,
                      width: SizeConfig.blockSizeHorizontal! * 5,
                    ),
                  ),
                )
              : SizedBox(),
          Align(
            alignment: Alignment(0, 0),
            child: SizedBox(
              child: Image(
                image: AssetImage('lib/images/rocket.png'),
                fit: BoxFit.cover,
                height: SizeConfig.blockSizeVertical! * 8,
                width: SizeConfig.blockSizeHorizontal! * 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
