import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:new_rocket/size_config.dart';
import 'package:provider/provider.dart';
import 'mainpage_model.dart';
import 'mode/clear/clear.dart';
import 'mode/game_over/game_over.dart';
import 'mode/how/how.dart';
import 'mode/ready/ready.dart';
import 'mode/top/top.dart';
import 'objects/cloud.dart';
import 'objects/explosion.dart';
import 'objects/goal.dart';
import 'objects/meteorite.dart';
import 'objects/rocket.dart';
import 'objects/star.dart';
import 'objects/ufo.dart';
import 'package:new_rocket/ground.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Widgetサイズ最適化用クラスを初期化
    SizeConfig().init(context);
    return Scaffold(
      body: Consumer<MainPageModel>(
        builder: (context, model, child) {
          return GestureDetector(
            onTap: () {
              model.tapAction();
            },
            child: Stack(
              children: [
                // * 空背景 ----------------------------------------------------------
                Container(color: model.backgroundColor()),
                //宇宙ステージ
                Container(
                  height: model.space,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.blue.withOpacity(0.0),
                      ],
                      stops: [
                        model.spaceStops,
                        1.0,
                      ],
                    ),
                  ),
                ),
                // * 地面 ----------------------------------------------------------
                ...Ground().tokyo(model),
                // * ゴール -----------------------------------------------------------
                Align(
                  alignment: Alignment(0, model.goal),
                  child: Goal(heightSize: 20, widthSize: 20),
                ),
                // * ロケット (ゲーム進行中以外はz-indexを雲より前面にする)
                model.display == 'play_game'
                    ? Align(
                        // ロケットの初期位置
                        alignment: Alignment(0, model.rocketYaxis),
                        child: MyRocket(boostFlg: model.boost),
                      )
                    : const SizedBox(),
                // * UFO -----------------------------------------------------------
                Align(
                  alignment: Alignment(model.ufoStatus['ufo_1']['x'], -1),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo_075']['x'], -0.75),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo_05']['x'], -0.5),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo_025']['x'], -0.25),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo0']['x'], 0),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo025']['x'], 0.25),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo05']['x'], 0.5),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo075']['x'], 0.75),
                  child: Ufo(),
                ),
                Align(
                  alignment: Alignment(model.ufoStatus['ufo1']['x'], 1),
                  child: Ufo(),
                ),
                // * 雲 -----------------------------------------------------------
                Align(
                  alignment: Alignment(0.9, model.cloudStatus['cloud1']['y']),
                  child: Cloud(
                    vertical: SizeConfig.blockSizeVertical! * 20,
                    horizontal: SizeConfig.blockSizeHorizontal! * 60,
                  ),
                ),
                Align(
                  alignment: Alignment(-1, model.cloudStatus['cloud2']['y']),
                  child: Cloud(
                    vertical: SizeConfig.blockSizeVertical! * 15,
                    horizontal: SizeConfig.blockSizeHorizontal! * 45,
                  ),
                ),
                Align(
                  alignment: Alignment(1, model.cloudStatus['cloud3']['y']),
                  child: Cloud(
                    vertical: SizeConfig.blockSizeVertical! * 20,
                    horizontal: SizeConfig.blockSizeHorizontal! * 50,
                  ),
                ),
                // * 星 -----------------------------------------------------------
                model.selectedLevel >= 6
                    ? Align(
                        alignment: Alignment((model.star * -1), model.star),
                        child: Star(),
                      )
                    : const SizedBox(),
                model.selectedLevel >= 8
                    ? Align(
                        alignment: Alignment((model.star2 * -1), model.star2),
                        child: Star(),
                      )
                    : const SizedBox(),
                model.selectedLevel >= 10
                    ? Align(
                        alignment: Alignment((model.star3 * -1), model.star3),
                        child: Star(),
                      )
                    : const SizedBox(),
                // * 隕石 -----------------------------------------------------------
                Align(
                  alignment: Alignment(1, model.meteorite),
                  child: Meteorite(
                    vertical: SizeConfig.blockSizeVertical! * 18,
                    horizontal: SizeConfig.blockSizeHorizontal! * 27,
                  ),
                ),
                Align(
                  alignment: Alignment(-0.8, model.meteorite2),
                  child: Meteorite(
                    vertical: SizeConfig.blockSizeVertical! * 15,
                    horizontal: SizeConfig.blockSizeHorizontal! * 20,
                  ),
                ),
                Align(
                  alignment: Alignment(0.6, model.meteorite3),
                  child: Meteorite(
                    vertical: SizeConfig.blockSizeVertical! * 10,
                    horizontal: SizeConfig.blockSizeHorizontal! * 20,
                  ),
                ),
                Align(
                  alignment: Alignment(0.8, model.meteorite4),
                  child: Meteorite(
                    vertical: SizeConfig.blockSizeVertical! * 16,
                    horizontal: SizeConfig.blockSizeHorizontal! * 26,
                  ),
                ),
                Align(
                  alignment: Alignment(-0.6, model.meteorite5),
                  child: Meteorite(
                    vertical: SizeConfig.blockSizeVertical! * 18,
                    horizontal: SizeConfig.blockSizeHorizontal! * 27,
                  ),
                ),

                // * ルール説明画面
                How(model: model),
                // * ロケット (ゲーム進行中はz-indexを雲より背面にする)
                model.display != 'play_game'
                    ? Align(
                        // ロケットの初期位置
                        alignment: Alignment(0, model.rocketYaxis),
                        child: model.display == 'game_over'
                            ? Explosion()
                            : MyRocket(boostFlg: model.boost),
                      )
                    : const SizedBox(),
                // * タイトル画面
                Top(model: model),
                // * ゲーム開始画面
                Ready(model: model),
                // * クリア画面
                Clear(model: model),
                // * ゲームオーバー画面
                GameOver(model: model),

                model.display == 'clear' ||
                        model.display == 'ready' ||
                        model.display == 'play_game'
                    ? const SizedBox()
                    : Align(
                        alignment: Alignment(0, 1),
                        child: Container(
                          color: Colors.white.withOpacity(0),
                          height: SizeConfig.blockSizeVertical! * 8,
                          width: double.infinity,
                          child: AdWidget(ad: model.myBanner),
                        ),
                      )
              ],
            ),
          );
        },
      ),
    );
  }
}
