import 'package:flutter/material.dart';
import '../size_config.dart';

class GameOver extends StatelessWidget {
  final model;
  GameOver({this.model});

  @override
  Widget build(BuildContext context) {
    // * ゲームオーバー画面
    return model.display == 'game_over'
        ? Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'G A M E  O V E R',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: 180,
                ),
                OutlinedButton(
                  onPressed: () {
                    //model.switchDisplay();
                    model.display = 'ready';
                    model.resetPosition();
                    model.reload();
                  },
                  child: Text(
                    'C O N T I N U E',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 2,
                        color: Colors.white),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    //model.switchDisplay();
                    model.display = 'top';
                    model.resetPosition();
                    model.reload();
                  },
                  child: Text(
                    'E X I T',
                    style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 2,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          )
        : Text('');
  }
}
