import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../size_config.dart';

class GameOver extends StatelessWidget {
  final model;
  GameOver({this.model});

  @override
  Widget build(BuildContext context) {
    // * ゲームオーバー画面
    return model.display == 'game_over'
        ? Stack(
            children: [
              Align(
                alignment: Alignment(0, -0.2),
                child: Text(
                  'G A M E  O V E R',
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
                  width: SizeConfig.blockSizeHorizontal! * 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  child: OutlinedButton(
                    onPressed: () {
                      //model.switchDisplay();
                      model.display = 'ready';
                      model.resetPosition();
                    },
                    child: Text(
                      '再挑戦する',
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
                  width: SizeConfig.blockSizeHorizontal! * 35,
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
                      'トップに戻る',
                      style: TextStyle(
                          fontSize: SizeConfig.blockSizeVertical! * 1.5,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          )
        : const SizedBox();
  }
}
