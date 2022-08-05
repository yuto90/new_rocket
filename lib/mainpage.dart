import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:new_rocket/size_config.dart';
import 'package:provider/provider.dart';
import 'mainpage_model.dart';
import 'mode/clear.dart';
import 'mode/game_over.dart';
import 'mode/how.dart';
import 'mode/ready.dart';
import 'mode/top.dart';
import 'objects/building.dart';
import 'objects/building2.dart';
import 'objects/explosion.dart';
import 'objects/goal.dart';
import 'objects/office.dart';
import 'objects/rocket.dart';
import 'level/level4.dart';
import 'level/level5.dart';
import 'objects/tokyo_tower.dart';
import 'objects/wood.dart';

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
              model.tapAction(context);
            },
            child: Stack(
              children: [
                // * 空背景 ----------------------------------------------------------
                Container(
                  color: Colors.blue,
                ),
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
                Align(
                  alignment: Alignment(0.6, model.ground),
                  child: Building2(),
                ),
                Align(
                  alignment: Alignment(-1.3, model.ground),
                  child: Building2(),
                ),
                Align(
                  alignment: Alignment(-0.1, model.ground),
                  child: Office(),
                ),
                Align(
                  alignment: Alignment(1.2, model.ground),
                  child: Building2(),
                ),
                Align(
                  alignment: Alignment(1.1, model.ground),
                  child: TokyoTower(),
                ),
                Align(
                  alignment: Alignment(1.1, model.ground),
                  child: Wood(),
                ),
                Align(
                  alignment: Alignment(-0.9, model.ground),
                  child: Office(),
                ),
                Align(
                  alignment: Alignment(0.2, model.ground),
                  child: Building(),
                ),
                Align(
                  alignment: Alignment(0, model.ground),
                  child: Wood(),
                ),
                Align(
                  alignment: Alignment(-0.8, model.ground),
                  child: Building(),
                ),
                Align(
                  alignment: Alignment(-0.4, model.ground),
                  child: Building2(),
                ),
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

                // ! レベル毎に出現オブジェクトを変える -----------------
                model.selectedLevel == 4
                    ? Level4(model: model)
                    : const SizedBox(),
                model.selectedLevel == 5
                    ? Level5(model: model)
                    : const SizedBox(),
                model.selectedLevel == 6
                    ? Level5(model: model)
                    : const SizedBox(),
                // ! -------------------------------------------

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
