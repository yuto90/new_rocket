import 'package:flutter/material.dart';
import '../size_config.dart';

class MyRocket extends StatelessWidget {
  bool turboFlg;
  MyRocket({required this.turboFlg});

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Colors.green,
      height: SizeConfig.blockSizeVertical! * 14,
      width: SizeConfig.blockSizeHorizontal! * 8,
      child: Stack(
        children: [
          Align(
            alignment: Alignment(0, 0),
            child: Container(
              //color: Colors.green,
              child: Image(
                image: AssetImage('lib/images/rocket.png'),
                fit: BoxFit.cover,
                height: SizeConfig.blockSizeVertical! * 8,
                width: SizeConfig.blockSizeHorizontal! * 8,
              ),
            ),
          ),
          turboFlg
              ? Align(
                  alignment: Alignment(0, 1.5),
                  child: Container(
                    //color: Colors.yellow,
                    child: Image(
                      image: AssetImage('lib/images/turbo.png'),
                      fit: BoxFit.cover,
                      height: SizeConfig.blockSizeVertical! * 6,
                      width: SizeConfig.blockSizeHorizontal! * 10,
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
