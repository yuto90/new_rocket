import 'package:flutter/material.dart';
import '../size_config.dart';

class Clear extends StatelessWidget {
  final model;
  Clear({this.model});

  @override
  Widget build(BuildContext context) {
    // * クリア画面
    return model.display == 'clear'
        ? Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.2),
                child: Text(
                  'C L E A R !!!',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 2,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.35),
                child: Container(
                  height: SizeConfig.blockSizeVertical! * 5,
                  width: SizeConfig.blockSizeHorizontal! * 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      //model.switchDisplay();
                      model.display = 'top';
                      model.resetPosition();
                    },
                    child: Text(
                      'E X I T',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
