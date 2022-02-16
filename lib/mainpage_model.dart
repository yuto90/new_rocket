import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MainPageModel extends ChangeNotifier {
  String display = 'top';
  // 難易度
  late double difficulty;

  double rocketYaxis = 0;
  double time = 0;
  double height = 0;
  double initialHeight = 0;
  bool gameHasStarted = false;

  // 障害物
  double ufo_1 = 2;
  double ufo_075 = 2;
  double ufo_05 = 2;
  double ufo_025 = 2;
  double ufo0 = 2;
  double ufo025 = 2;
  double ufo05 = 2;
  double ufo075 = 2;
  double ufo1 = 2;

  // 背景の雲
  double back = -1;
  double back2 = -0.8;
  double back3 = -0.6;

  // 背景の隕石
  double meteorite = -3;
  double meteorite2 = -2.8;
  double meteorite3 = -2.6;

  // 背景の雲
  double star = -2;
  double star2 = -2.5;
  double star3 = -3;

  // 発射台
  double ground = 1.1;

  // 宇宙の背景色
  double space = 0;

  // ゴール
  double goal = -3;
  // ゲームスタートからの時間
  int count = 0;

  // initState的なやつ
  MainPageModel() {
    initValue();
  }

  void initValue() {
    print('init');
  }

  // オブジェクト位置リセット用の乱数を生成
  double randomDouble(double coefficient) {
    return (Random().nextDouble() + 1) * coefficient;
  }

  // 難易度設定
  void switchDiffculty(String diff) {
    if (diff == 'hard') {
      difficulty = 1.5;
    } else if (diff == 'normal') {
      difficulty = 3;
    } else {
      // easy
      difficulty = 5;
    }

    // 難易度ごとに乱数の係数を調整
    ufo_1 = randomDouble(difficulty);
    ufo_075 = randomDouble(difficulty);
    ufo_05 = randomDouble(difficulty);
    ufo_025 = randomDouble(difficulty);
    ufo0 = randomDouble(difficulty);
    ufo025 = randomDouble(difficulty);
    ufo05 = randomDouble(difficulty);
    ufo075 = randomDouble(difficulty);
    ufo1 = randomDouble(difficulty);
    notifyListeners();
  }

  // 画面を切り替え
  void switchDisplay(String mode) {
    display = mode;
    notifyListeners();
  }

  void move() {
    time = 0;
    initialHeight = rocketYaxis;
    notifyListeners();
  }

  void startGame(context) {
    gameHasStarted = true;
    Timer.periodic(
      Duration(milliseconds: 30),
      (timer) {
        time += 0.015;
        height = -4.9 * time * time + 0.2 + time;
        rocketYaxis = initialHeight - height;
        notifyListeners();

        count += 30;
        // 30秒経過したら背景を黒にする
        if (space < 1500 && count >= 30000) {
          space += 3.7;
        }

        // 1分経過したら背景を黒にする
        if (count >= 60000) {
          goal += 0.01;
        }

        // ! 惑星に近づいたらクリア
        if ((goal - rocketYaxis) >= -0.1) {
          timer.cancel();
          display = 'clear';
        }

        // 障害物 -----------------------------------------------
        // 画面外に出たら
        if (ufo_1 < -1.2) {
          ufo_1 = randomDouble(difficulty);
        } else {
          ufo_1 -= 0.03;
        }
        if (ufo_075 < -1.2) {
          ufo_075 = randomDouble(difficulty);
        } else {
          ufo_075 -= 0.03;
        }
        if (ufo_05 < -1.2) {
          ufo_05 = randomDouble(difficulty);
        } else {
          ufo_05 -= 0.03;
        }
        if (ufo_025 < -1.2) {
          ufo_025 = randomDouble(difficulty);
        } else {
          ufo_025 -= 0.03;
        }
        if (ufo0 < -1.2) {
          ufo0 = randomDouble(difficulty);
        } else {
          ufo0 -= 0.03;
        }
        if (ufo025 < -1.2) {
          ufo025 = randomDouble(difficulty);
        } else {
          ufo025 -= 0.03;
        }
        if (ufo05 < -1.2) {
          ufo05 = randomDouble(difficulty);
        } else {
          ufo05 -= 0.03;
        }
        if (ufo075 < -1.2) {
          ufo075 = randomDouble(difficulty);
        } else {
          ufo075 -= 0.03;
        }
        if (ufo1 < -1.2) {
          ufo1 = randomDouble(difficulty);
        } else {
          ufo1 -= 0.03;
        }

        //雲  --------------------------------------------------
        if (back > 1.2 && count <= 30000) {
          back = -1.2;
        } else {
          back += 0.01;
        }

        if (back2 > 1.5 && count <= 30000) {
          back2 = -1.2;
        } else {
          back2 += 0.01;
        }

        if (back3 > 1.8 && count <= 30000) {
          back3 = -1.2;
        } else {
          back3 += 0.01;
        }

        //隕石  --------------------------------------------------
        if (meteorite > 1.2 && count >= 30000) {
          meteorite = -1.2;
        } else if (count >= 30000) {
          meteorite += 0.01;
        }

        if (meteorite2 > 1.5 && count >= 30000) {
          meteorite2 = -1.2;
        } else if (count >= 30000) {
          meteorite2 += 0.01;
        }

        if (meteorite3 > 1.8 && count >= 30000) {
          meteorite3 = -1.2;
        } else if (count >= 30000) {
          meteorite3 += 0.01;
        }

        // 星 -------------------------------------------------------
        if (star > 1.2 && count >= 30000) {
          star = -1.2;
        } else if (count >= 30000) {
          star += 0.01;
        }

        if (star2 > 1.5 && count >= 30000) {
          star2 = -1.2;
        } else if (count >= 30000) {
          star2 += 0.01;
        }

        if (star3 > 1.8 && count >= 30000) {
          star3 = -1.2;
        } else if (count >= 30000) {
          star3 += 0.01;
        }

        // 地面 --------------------------------------------------
        if (ground > 0) {
          ground += 0.01;
          notifyListeners();
        }

        //! 当たり判定 ======================================================
        // Y軸画面外に出たらゲームオーバー
        if (rocketYaxis >= 1.2 || rocketYaxis <= -1.2) {
          timer.cancel();
          display = 'game_over';
        }

        if ((ufo_1 <= 0.1 && ufo_1 >= -0.1) &&
            (rocketYaxis <= -0.9 && rocketYaxis >= -1.1)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo_075 <= 0.1 && ufo_075 >= -0.1) &&
            (rocketYaxis <= -0.65 && rocketYaxis >= -0.85)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo_05 <= 0.1 && ufo_05 >= -0.1) &&
            (rocketYaxis <= -0.4 && rocketYaxis >= -0.6)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo_025 <= 0.1 && ufo_025 >= -0.1) &&
            (rocketYaxis <= -0.15 && rocketYaxis >= -0.35)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo0 <= 0.1 && ufo0 >= -0.1) &&
            (rocketYaxis <= 0.1 && rocketYaxis >= -0.1)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo025 <= 0.1 && ufo025 >= -0.1) &&
            (rocketYaxis <= 0.35 && rocketYaxis >= 0.15)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo05 <= 0.1 && ufo05 >= -0.1) &&
            (rocketYaxis <= 0.6 && rocketYaxis >= 0.4)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo075 <= 0.1 && ufo075 >= -0.1) &&
            (rocketYaxis <= 0.85 && rocketYaxis >= 0.65)) {
          timer.cancel();
          display = 'game_over';
        }
        if ((ufo1 <= 0.1 && ufo1 >= -0.1) &&
            (rocketYaxis <= 1.1 && rocketYaxis >= 0.9)) {
          timer.cancel();
          display = 'game_over';
        }

        if (((star - rocketYaxis) >= -0.1 && (star - rocketYaxis) <= 0.1) &&
            (star <= 0.15 && star >= -0.15)) {
          timer.cancel();
          display = 'game_over';
        }
        if (((star2 - rocketYaxis) >= -0.1 && (star2 - rocketYaxis) <= 0.1) &&
            (star2 <= 0.15 && star2 >= -0.15)) {
          timer.cancel();
          display = 'game_over';
        }
        if (((star3 - rocketYaxis) >= -0.1 && (star3 - rocketYaxis) <= 0.1) &&
            (star3 <= 0.15 && star3 >= -0.15)) {
          timer.cancel();
          display = 'game_over';
        }
        notifyListeners();
      },
    );
  }

  void resetPosition() {
    rocketYaxis = 0;
    time = 0;
    height = 0;
    initialHeight = rocketYaxis;
    gameHasStarted = false;
    ground = 150;
    space = 0;

    count = 0;
    // UFO
    ufo_1 = randomDouble(difficulty);
    ufo_075 = randomDouble(difficulty);
    ufo_05 = randomDouble(difficulty);
    ufo_025 = randomDouble(difficulty);
    ufo0 = randomDouble(difficulty);
    ufo025 = randomDouble(difficulty);
    ufo05 = randomDouble(difficulty);
    ufo075 = randomDouble(difficulty);
    ufo1 = randomDouble(difficulty);

    back = -1;
    back2 = -0.8;
    back3 = -0.6;

    meteorite = -2;
    meteorite2 = -1.8;
    meteorite3 = -1.6;

    star = -2;
    star2 = -2.8;
    star3 = -2.6;

    goal = -3;
    ground = 1.1;
  }

  void reload() {
    notifyListeners();
  }
}
