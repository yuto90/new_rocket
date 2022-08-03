import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainPageModel extends ChangeNotifier {
  /// 表示する画面
  String display = 'top';

  /// 難易度
  double level = 1;

  /// レベルとUFOの出現頻度のマッピング
  /// todo レベル設定
  Map mappingLevel = {
    1: 7.0,
    2: 5.0,
    3: 2.0,
    4: 2.0,
    5: 2.0,
    6: 7.0,
    7: 5.0,
    8: 2.0,
    9: 2.0,
    10: 2.0,
  };

  /// ロケットのY座標
  double rocketYaxis = 0;

  /// ロケットのブースト関係
  double time = 0;
  double height = 0;
  double initialHeight = 0;

  /// ゲーム開始中フラグ
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

  /// 雲オブジェクト
  double cloud = -1;
  double cloud2 = -0.8;
  double cloud3 = -0.6;

  /// 隕石オブジェクト
  double meteorite = -3;
  double meteorite2 = -2.8;
  double meteorite3 = -2.6;
  double meteorite4 = -2.3;
  double meteorite5 = -2.0;

  /// 星オブジェクト
  double star = -2;
  double star2 = -2.5;
  double star3 = -3;

  /// 地面
  double ground = 1.1;

  /// 宇宙ステージの背景座標用
  double space = 0;
  double spaceStops = 0;

  /// グラデーション用
  /// ゴール
  double goal = -3;

  /// ゲームスタートからの時間
  int count = 0;

  /// ブーストフラグ
  bool boost = false;

  late BannerAd myBanner;

  /// initState的なやつ
  MainPageModel() {
    initValue();
  }

  void initValue() {
    //print('init');

    /// バナー広告をインスタンス化
    myBanner = BannerAd(
      // ! リリースビルド時に切り替える ------------------------------------------
      adUnitId: getTestAdBannerUnitId(),
      //adUnitId: getAdBannerUnitId(),
      // ! ---------------------------------------------------------------
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    // バナー広告の読み込み
    myBanner.load();
  }

  /// プラットフォーム（iOS / Android）に合わせて本番用広告IDを返す
  String getAdBannerUnitId() {
    String bannerUnitId = "";

    // Android のとき
    if (Platform.isAndroid) {
      // Androidのバナー広告ID
      bannerUnitId = dotenv.env['BANNER_UNIT_ID_ANDROID']!;

      // iOSのとき
    } else if (Platform.isIOS) {
      // iOSのバナー広告ID
      bannerUnitId = dotenv.env['BANNER_UNIT_ID_IOS']!;
    }
    return bannerUnitId;
  }

  /// プラットフォーム（iOS / Android）に合わせてデモ用広告IDを返す
  String getTestAdBannerUnitId() {
    String testBannerUnitId = "";

    // Android のとき
    if (Platform.isAndroid) {
      // Androidのデモ用バナー広告ID
      testBannerUnitId = "ca-app-pub-3940256099942544/6300978111";
      // iOSのとき
    } else if (Platform.isIOS) {
      // iOSのデモ用バナー広告ID
      testBannerUnitId = "ca-app-pub-3940256099942544/2934735716";
    }
    return testBannerUnitId;
  }

  /// オブジェクト位置リセット用の乱数を生成
  double randomDouble(double coefficient) {
    return (Random().nextDouble() + 1) * coefficient;
  }

  /// レベル設定
  void switchLevel(double selectedLevel) {
    level = selectedLevel;

    // 難易度ごとに乱数の係数を調整
    ufo_1 = randomDouble(level);
    ufo_075 = randomDouble(level);
    ufo_05 = randomDouble(level);
    ufo_025 = randomDouble(level);
    ufo0 = randomDouble(level);
    ufo025 = randomDouble(level);
    ufo05 = randomDouble(level);
    ufo075 = randomDouble(level);
    ufo1 = randomDouble(level);
    notifyListeners();
  }

  /// 画面を切り替え
  void switchDisplay(String mode) {
    display = mode;
    notifyListeners();
  }

  // ゲーム進行時に画面タップした時
  void move() {
    // how画面からready画面に戻った時はmoveさせない
    if (display != 'ready') {
      time = 0;
      initialHeight = rocketYaxis;

      // 1秒だけターボエフェクトを表示
      boost = true;
      Future.delayed(Duration(seconds: 1), () {
        boost = false;
        notifyListeners();
      });

      notifyListeners();
    }
  }

  // how画面にデモ動作を実行させる
  void howDemoMove() {
    gameHasStarted = true;
    move();

    Timer.periodic(Duration(milliseconds: 10), (timer) {
      time += 0.005;
      height = -4.5 * time * time + 0.2 + time;
      rocketYaxis = initialHeight - height;

      if (rocketYaxis > 0) {
        timer.cancel();
        gameHasStarted = false;
        rocketYaxis = 0;
        time = 0;
        height = 0;
        initialHeight = 0;
      }
      notifyListeners();
    });
  }

  // ゲーム開始関数
  void startGame(context) {
    display = 'play_game';
    gameHasStarted = true;
    Timer.periodic(
      Duration(milliseconds: 10),
      (timer) {
        time += 0.005;
        height = -4.5 * time * time + 0.2 + time;
        rocketYaxis = initialHeight - height;
        //notifyListeners();

        count += 10;

        // 30秒経過したら背景を黒にする
        if (space < 3000 && count >= 30000) {
          space += 3;
          spaceStops += 0.001;
        }

        // 1分経過したらゴールを画面に表示させる
        if (count >= 60000) {
          goal += 0.005;
        }

        // ! 惑星に近づいたらクリア
        if ((goal - rocketYaxis) >= -0.1) {
          timer.cancel();
          gameHasStarted = false;
          display = 'clear';
        }

        // UFO -----------------------------------------------
        // 画面外に出たら
        if (ufo_1 < -1.2) {
          ufo_1 = randomDouble(level);
        } else {
          ufo_1 -= 0.01;
        }
        if (ufo_075 < -1.2) {
          ufo_075 = randomDouble(level);
        } else {
          ufo_075 -= 0.01;
        }
        if (ufo_05 < -1.2) {
          ufo_05 = randomDouble(level);
        } else {
          ufo_05 -= 0.01;
        }
        if (ufo_025 < -1.2) {
          ufo_025 = randomDouble(level);
        } else {
          ufo_025 -= 0.01;
        }
        if (ufo0 < -1.2) {
          ufo0 = randomDouble(level);
        } else {
          ufo0 -= 0.01;
        }
        if (ufo025 < -1.2) {
          ufo025 = randomDouble(level);
        } else {
          ufo025 -= 0.01;
        }
        if (ufo05 < -1.2) {
          ufo05 = randomDouble(level);
        } else {
          ufo05 -= 0.01;
        }
        if (ufo075 < -1.2) {
          ufo075 = randomDouble(level);
        } else {
          ufo075 -= 0.01;
        }
        if (ufo1 < -1.2) {
          ufo1 = randomDouble(level);
        } else {
          ufo1 -= 0.01;
        }

        //雲  --------------------------------------------------
        if (count <= 30000) {
          if (cloud > 1.5) {
            cloud = -1.5;
          }
          if (cloud2 > 1.5) {
            cloud2 = -1.7;
          }
          if (cloud3 > 1.5) {
            cloud3 = -1.8;
          }
        }
        cloud += 0.005;
        cloud2 += 0.0047; // todo なぜか落下スピードが早いので調整
        cloud3 += 0.005;

        // 35秒経過したら宇宙ステージ用オブジェクトを出す
        if (count >= 35000) {
          //隕石  --------------------------------------------------
          if (meteorite > 1.5) {
            meteorite = -1.5;
          }
          if (meteorite2 > 2) {
            meteorite2 = -1.8;
          }
          if (meteorite3 > 1.7) {
            meteorite3 = -2.0;
          }
          if (meteorite4 > 1.6) {
            meteorite4 = -1.5;
          }
          if (meteorite5 > 1.9) {
            meteorite5 = -1.8;
          }

          meteorite += 0.005;
          meteorite2 += 0.005;
          meteorite3 += 0.005;
          meteorite4 += 0.005;
          meteorite5 += 0.005;

          // 星 -------------------------------------------------------
          // EASY以外
          if (level != 7) {
            if (star > 1.2) {
              star = -1.2;
            } else {
              star += 0.005;
            }
          }
          // EASY以外またはNORMAL以外
          if (level != 5 || level != 7) {
            if (star2 > 1.5) {
              star2 = -1.2;
            } else {
              star2 += 0.005;
            }
          }
          // HARDだったら
          if (level == 2) {
            if (star3 > 1.8) {
              star3 = -1.2;
            } else {
              star3 += 0.005;
            }
          }
        }

        // 地面 --------------------------------------------------
        if (ground <= 2) {
          ground += 0.005;
        }

        //! 当たり判定 ======================================================
        // Y軸画面外に出たらゲームオーバー
        if (rocketYaxis >= 1.2 || rocketYaxis <= -1.2) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }

        // ufoの当たり判定
        if ((ufo_1 <= 0.1 && ufo_1 >= -0.1) &&
            (rocketYaxis <= -0.9 && rocketYaxis >= -1.1)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo_075 <= 0.1 && ufo_075 >= -0.1) &&
            (rocketYaxis <= -0.65 && rocketYaxis >= -0.85)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo_05 <= 0.1 && ufo_05 >= -0.1) &&
            (rocketYaxis <= -0.4 && rocketYaxis >= -0.6)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo_025 <= 0.1 && ufo_025 >= -0.1) &&
            (rocketYaxis <= -0.15 && rocketYaxis >= -0.35)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo0 <= 0.1 && ufo0 >= -0.1) &&
            (rocketYaxis <= 0.1 && rocketYaxis >= -0.1)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo025 <= 0.1 && ufo025 >= -0.1) &&
            (rocketYaxis <= 0.35 && rocketYaxis >= 0.15)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo05 <= 0.1 && ufo05 >= -0.1) &&
            (rocketYaxis <= 0.6 && rocketYaxis >= 0.4)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo075 <= 0.1 && ufo075 >= -0.1) &&
            (rocketYaxis <= 0.85 && rocketYaxis >= 0.65)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if ((ufo1 <= 0.1 && ufo1 >= -0.1) &&
            (rocketYaxis <= 1.1 && rocketYaxis >= 0.9)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }

        // 星の当たり判定
        if (((star - rocketYaxis) >= -0.1 && (star - rocketYaxis) <= 0.1) &&
            (star <= 0.15 && star >= -0.15)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if (((star2 - rocketYaxis) >= -0.1 && (star2 - rocketYaxis) <= 0.1) &&
            (star2 <= 0.15 && star2 >= -0.15)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        if (((star3 - rocketYaxis) >= -0.1 && (star3 - rocketYaxis) <= 0.1) &&
            (star3 <= 0.15 && star3 >= -0.15)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }
        notifyListeners();
      },
    );
  }

  /// パラメータのリセット
  void resetPosition() {
    rocketYaxis = 0;
    time = 0;
    height = 0;
    initialHeight = rocketYaxis;
    gameHasStarted = false;
    space = 0;
    spaceStops = 0;
    count = 0;

    ufo_1 = randomDouble(level);
    ufo_075 = randomDouble(level);
    ufo_05 = randomDouble(level);
    ufo_025 = randomDouble(level);
    ufo0 = randomDouble(level);
    ufo025 = randomDouble(level);
    ufo05 = randomDouble(level);
    ufo075 = randomDouble(level);
    ufo1 = randomDouble(level);

    cloud = -1;
    cloud2 = -0.8;
    cloud3 = -0.6;

    meteorite = -3;
    meteorite2 = -2.8;
    meteorite3 = -2.6;
    meteorite4 = -2.3;
    meteorite5 = -2.0;

    star = -2;
    star2 = -2.8;
    star3 = -2.6;

    goal = -3;
    ground = 1.1;

    notifyListeners();
  }
}
