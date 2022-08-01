import 'package:flutter/material.dart';
import '../size_config.dart';

class Top extends StatelessWidget {
  final model;
  Top({this.model});

  @override
  Widget build(BuildContext context) {
    // * タイトル画面
    return model.display == 'top'
        ? Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.2),
                child: Text(
                  'Unlucky Rocket',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 3,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.2),
                child: Container(
                  height: SizeConfig.blockSizeVertical! * 5,
                  width: SizeConfig.blockSizeHorizontal! * 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      model.switchLevel(2.0);
                      model.switchDisplay('ready');
                    },
                    child: Text(
                      'LEVEL 3',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        color: Colors.white,
                      ),
                    ),
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
                      model.switchLevel(5.0);
                      model.switchDisplay('ready');
                    },
                    child: Text(
                      'LEVEL 2',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.5),
                child: Container(
                  height: SizeConfig.blockSizeVertical! * 5,
                  width: SizeConfig.blockSizeHorizontal! * 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      model.switchLevel(7.0);
                      model.switchDisplay('ready');
                    },
                    child: Text(
                      'LEVEL 1',
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
