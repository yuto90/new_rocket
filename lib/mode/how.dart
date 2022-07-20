import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../objects/goal.dart';
import '../objects/star.dart';
import '../objects/ufo.dart';
import '../size_config.dart';

class How extends StatelessWidget {
  final model;
  How({this.model});

  @override
  Widget build(BuildContext context) {
    // * ルール説明画面
    return model.display == 'how'
        ? Stack(
            children: [
              // ロケットの注釈
              Align(
                alignment: Alignment(0, 0.16),
                child: Text(
                  '↑',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 6,
                    color: Colors.black,
                  ),
                ),
              ),
              Align(
                alignment: Alignment(0, 0.26),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  height: SizeConfig.blockSizeVertical! * 5,
                  width: SizeConfig.blockSizeVertical! * 26,
                  child: Center(
                    child: Text(
                      '画面をタップすると上に移動するよ',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              // クリア条件の注釈
              Align(
                alignment: Alignment(0, -0.7),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    color: Colors.black,
                  ),
                  height: SizeConfig.blockSizeVertical! * 33,
                  width: SizeConfig.blockSizeVertical! * 30,
                  child: Column(
                    children: [
                      Text(
                        '-*-*-*-*- クリア条件 -*-*-*-*-',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeVertical! * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'ロケットが惑星まで到達すること',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeVertical! * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeVertical! * 0.8),
                        child: Goal(heightSize: 10, widthSize: 10),
                      ),
                      Text(
                        '※特定の障害物に当たるとゲームオーバー',
                        style: TextStyle(
                          fontSize: SizeConfig.blockSizeVertical! * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeVertical! * 0.8),
                        child: Ufo(),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeVertical! * 0.8),
                        child: Star(),
                      ),
                    ],
                  ),
                ),
              ),

              // 戻るボタン
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
                      model.switchDisplay('ready');
                    },
                    child: Text(
                      'B A C K',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.7,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // 広告
              Align(
                alignment: Alignment(0, 0.7),
                child: Container(
                  color: Colors.white.withOpacity(0),
                  height: SizeConfig.blockSizeVertical! * 8,
                  width: double.infinity,
                  child: AdWidget(ad: model.myBanner),
                ),
              )
            ],
          )
        : const SizedBox();
  }
}
