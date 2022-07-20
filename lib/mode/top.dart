import 'package:flutter/material.dart';
import '../size_config.dart';

class Top extends StatelessWidget {
  final model;
  Top({this.model});

  @override
  Widget build(BuildContext context) {
    // * タイトル画面
    return model.display == 'top'
        ? Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 18,
                ),
                Text(
                  'Unlucky Rocket',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 3,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 20,
                ),
                OutlinedButton(
                  onPressed: () {
                    model.switchDifficulty('hard');
                    model.switchDisplay('ready');
                  },
                  child: Text(
                    'H A R D',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! * 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    model.switchDifficulty('normal');
                    model.switchDisplay('ready');
                  },
                  child: Text(
                    'N O R M A L',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! * 2,
                      color: Colors.white,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    model.switchDifficulty('easy');
                    model.switchDisplay('ready');
                  },
                  child: Text(
                    'E A S Y',
                    style: TextStyle(
                      fontSize: SizeConfig.blockSizeVertical! * 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
