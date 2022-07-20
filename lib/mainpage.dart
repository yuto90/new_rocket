import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mode/clear.dart';
import 'mode/game_over.dart';
import 'mode/how.dart';
import 'mainpage_model.dart';
import 'mode/ready.dart';
import 'mode/top.dart';
import 'objects/building.dart';
import 'objects/building2.dart';
import 'objects/explosion.dart';
import 'objects/goal.dart';
import 'objects/meteorite.dart';
import 'objects/office.dart';
import 'objects/star.dart';
import 'objects/tokyo_tower.dart';
import 'objects/ufo.dart';
import 'objects/rocket.dart';
import 'objects/cloud.dart';
import 'objects/wood.dart';
import 'size_config.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Widgetサイズ最適化用クラスを初期化
    SizeConfig().init(context);

    return Scaffold(
      body: ChangeNotifierProvider<MainPageModel>(
        create: (_) => MainPageModel(),
        child: Consumer<MainPageModel>(
          builder: (context, model, child) {
            return GestureDetector(
              onTap: () {
                if (model.gameHasStarted) {
                  model.move();
                } else if (model.display == 'ready') {
                  model.startGame(context);
                }
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
                  // * ロケット ---------------------------------------------------------
                  Align(
                    // ロケットの初期位置
                    alignment: Alignment(0, model.rocketYaxis),
                    child: model.display == 'game_over'
                        ? Explosion()
                        : MyRocket(boostFlg: model.boost),
                  ),
                  // * 障害物 -----------------------------------------------------------
                  Align(
                    alignment: Alignment(model.ufo_1, -1),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo_075, -0.75),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo_05, -0.5),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo_025, -0.25),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo0, 0),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo025, 0.25),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo05, 0.5),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo075, 0.75),
                    child: Ufo(),
                  ),
                  Align(
                    alignment: Alignment(model.ufo1, 1),
                    child: Ufo(),
                  ),
                  // * 雲 -----------------------------------------------------------
                  Align(
                    alignment: Alignment(0.6, model.cloud3),
                    child: Cloud(),
                  ),
                  Align(
                    alignment: Alignment(-1, model.cloud2),
                    child: Cloud(),
                  ),
                  Align(
                    alignment: Alignment(1, model.cloud),
                    child: Cloud(),
                  ),
                  // * 星 -----------------------------------------------------------
                  model.difficulty != 7
                      ? Align(
                          alignment: Alignment((model.star * -1), model.star),
                          child: Star(),
                        )
                      : const SizedBox(),
                  model.difficulty != 5 || model.difficulty != 7
                      ? Align(
                          alignment: Alignment((model.star2 * -1), model.star2),
                          child: Star(),
                        )
                      : const SizedBox(),
                  model.difficulty == 2
                      ? Align(
                          alignment: Alignment((model.star3 * -1), model.star3),
                          child: Star(),
                        )
                      : const SizedBox(),
                  // * 隕石 -----------------------------------------------------------
                  Align(
                    alignment: Alignment(0.6, model.meteorite3),
                    child: Meteorite(),
                  ),
                  Align(
                    alignment: Alignment(-1, model.meteorite2),
                    child: Meteorite(),
                  ),
                  Align(
                    alignment: Alignment(1, model.meteorite),
                    child: Meteorite(),
                  ),

                  // * ルール説明画面
                  How(model: model),
                  // * タイトル画面
                  Top(model: model),
                  // * ゲーム開始画面
                  Ready(model: model),
                  // * クリア画面
                  Clear(model: model),
                  // * ゲームオーバー画面
                  GameOver(model: model),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
