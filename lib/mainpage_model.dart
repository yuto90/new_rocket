import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'const/mainpage_const.dart';

class MainPageModel extends ChangeNotifier {
  // todo リリースビルド時は【false】に切り替える ------------------------------------------
  bool debugMode = false;

  // todo デバッグ用
  void debug() {
    //pref.setInt('clearLevel', 1);
    print(pref.getInt('clearLevel') ?? 1);
    notifyListeners();
  }

  /// 表示する画面
  String display = 'top';

  /// 難易度
  double level = 1;

  /// 選択したレベル
  int selectedLevel = 1;

  /// ロケットのY座標
  double rocketYaxis = 0;

  /// ロケットのブースト関係
  double time = 0;
  double height = 0;
  double initialHeight = 0;

  /// ゲーム開始中フラグ
  bool gameHasStarted = false;

  // UFOの情報
  Map ufoStatus = {
    'ufo_1': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': -0.9, 'end': -1.1}
    },
    'ufo_075': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': -0.65, 'end': -0.85}
    },
    'ufo_05': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': -0.4, 'end': -0.6}
    },
    'ufo_025': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': -0.15, 'end': -0.35}
    },
    'ufo0': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': 0.1, 'end': -0.1}
    },
    'ufo025': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': 0.35, 'end': 0.15}
    },
    'ufo05': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': 0.6, 'end': 0.4}
    },
    'ufo075': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': 0.65, 'end': 0.85}
    },
    'ufo1': {
      'x': 2.0,
      'direction': 'minus',
      'outZone': {'start': 0.9, 'end': 1.1}
    },
  };

  Map cloudStatus = {
    'cloud1': {
      'y': -1.0,
    },
    'cloud2': {
      'y': -0.8,
    },
    'cloud3': {
      'y': -0.6,
    },
  };

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
  double city = 1.1;

  /// 宇宙ステージの背景座標用
  double space = 0;
  double spaceStops = 0;

  /// ゴール
  double goal = -3;

  /// ゲームスタートからの時間
  int count = 0;

  /// ブーストフラグ
  bool boost = false;

  /// ロケット爆発フラグ
  bool explosion = false;

  /// 広告バナー
  late BannerAd myBanner;

  /// ローカルストレージ
  late SharedPreferences pref;

  /// initState的なやつ
  MainPageModel() {
    initValue();
  }

  void initValue() {
    /// バナー広告をインスタンス化
    myBanner = BannerAd(
      adUnitId: debugMode ? getTestAdBannerUnitId() : getAdBannerUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );

    // バナー広告の読み込み
    myBanner.load();
  }

  /// どこまでレベルをクリアしているかを取得
  Future<int> getClearLevel() async {
    int clearLevelNumber;
    pref = await SharedPreferences.getInstance();
    clearLevelNumber = pref.getInt('clearLevel') ?? 1;

    return clearLevelNumber;
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
  double randomDouble(double coefficient, String direction) {
    if (direction == 'minus') {
      return (Random().nextDouble() + 1.5) * coefficient;
    } else {
      return (-(Random().nextDouble()) - 1.5) * coefficient;
    }
  }

  /// 障害物の進行方向を決める 'minus' or 'plus'を返す
  String randomDirection() {
    List<String> direction = ['minus', 'plus'];
    return direction[Random().nextInt(direction.length)];
  }

  /// レベル設定
  void switchLevel(int levelIndex) {
    selectedLevel = levelIndex;
    level = mappingLevel[levelIndex];

    // 難易度ごとに乱数の係数を調整
    ufoStatus.forEach((key, ufo) {
      ufo['direction'] = randomDirection();
      ufo['x'] = randomDouble(level, ufo['direction']);
    });

    notifyListeners();
  }

  /// 画面を切り替え
  void switchDisplay(String mode) {
    display = mode;
    notifyListeners();
  }

  // ブーストエフェクトを表示
  void boostEffect() {
    if (!boost) {
      boost = true;
      Future.delayed(Duration(seconds: 1), () {
        boost = false;
      });
    }
  }

  // ゲーム進行時に画面タップした時ジャンプさせる
  void move() {
    time = 0;
    initialHeight = rocketYaxis;
    boostEffect();
    notifyListeners();
  }

  /// 重力計算の数式
  void gravity() {
    height = -4.5 * time * time + 0.2 + time;
    rocketYaxis = initialHeight - height;
  }

  // how画面にデモ動作を実行させる
  void howDemoMove() {
    gameHasStarted = true;
    Timer.periodic(Duration(milliseconds: 10), (timer) {
      time += 0.005;
      gravity();
      boostEffect();
      // UFOが画面外に出た時にリスポーンさせる-----------------------------------------------
      double change =
          (ufoStatus['ufo_025']['direction'] == 'minus') ? -0.01 : 0.01;
      ufoStatus['ufo_025']['x'] += change;

      if ((change < 0 && ufoStatus['ufo_025']['x'] < -1.2) ||
          (change > 0 && ufoStatus['ufo_025']['x'] > 1.2)) {
        ufoStatus['ufo_025']['direction'] = randomDirection();
        ufoStatus['ufo_025']['x'] =
            randomDouble(10, ufoStatus['ufo_025']['direction']);
      }

      if ((ufoStatus['ufo_025']['x'] <= 0.1 &&
              ufoStatus['ufo_025']['x'] >= -0.1) &&
          (rocketYaxis <= ufoStatus['ufo_025']['outZone']['start'] &&
              rocketYaxis >= ufoStatus['ufo_025']['outZone']['end'])) {
        timer.cancel();
        explosion = true;
        // 1秒だけ爆発エフェクトを表示してその後に再帰処理で再開
        Future.delayed(Duration(seconds: 1), () {
          // 非同期処理中に戻るボタンを押されていたら処理は行わない
          if (display == 'how') {
            explosion = false;
            resetPosition();
            howDemoMove();
          }
        });
      }

      if (rocketYaxis > 0) {
        rocketYaxis = 0;
        time = 0;
        height = 0;
        initialHeight = 0;
      }
      // 戻るボタンを押された時
      if (!gameHasStarted) {
        timer.cancel();
        boost = false;
        resetPosition();
      }
      notifyListeners();
    });
  }

  void tapAction() {
    if (gameHasStarted) {
      move();
    } else if (display == 'ready') {
      startGame();
    }
  }

  // ゲーム開始関数
  void startGame() {
    display = 'play_game';
    gameHasStarted = true;
    Timer.periodic(
      Duration(milliseconds: 10),
      (timer) {
        time += 0.005;
        gravity();

        // 経過時間をカウントする用
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

        // ! 地面 --------------------------------------------------
        if (city <= 2) {
          city += 0.005;
        }

        // UFOが画面外に出た時にリスポーンさせる-----------------------------------------------
        ufoStatus.forEach((_, ufo) {
          double change = (ufo['direction'] == 'minus') ? -0.01 : 0.01;
          ufo['x'] += change;

          if ((change < 0 && ufo['x'] < -1.2) ||
              (change > 0 && ufo['x'] > 1.2)) {
            ufo['direction'] = randomDirection();
            ufo['x'] = randomDouble(level, ufo['direction']);
          }
        });

        //雲  --------------------------------------------------
        // 地球ステージの時
        cloudStatus['cloud1']['y'] += 0.005;
        cloudStatus['cloud2']['y'] += 0.005; // todo なぜか落下スピードが早いので調整
        cloudStatus['cloud3']['y'] += 0.005;
        if (count <= 30000) {
          if (cloudStatus['cloud1']['y'] > 1.5) {
            cloudStatus['cloud1']['y'] = -1.5;
          }
          if (cloudStatus['cloud2']['y'] > 1.5) {
            cloudStatus['cloud2']['y'] = -1.7;
          }
          if (cloudStatus['cloud3']['y'] > 1.5) {
            cloudStatus['cloud3']['y'] = -1.8;
          }
        }

        // 35秒経過したら宇宙ステージ用オブジェクトを出す
        if (count >= 35000) {
          //隕石  --------------------------------------------------
          meteorite += 0.005;
          meteorite2 += 0.005;
          meteorite3 += 0.005;
          meteorite4 += 0.005;
          meteorite5 += 0.005;

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

          // 星 -------------------------------------------------------
          if (selectedLevel >= 6) {
            star += 0.005;
            if (star > 1.2) {
              star = -1.2;
            }
          }
          if (selectedLevel >= 8) {
            star2 += 0.005;
            if (star2 > 1.5) {
              star2 = -1.2;
            }
          }
          if (selectedLevel >= 10) {
            star3 += 0.005;
            if (star3 > 2) {
              star3 = -1.2;
            }
          }
        }

        //! 当たり判定 ======================================================
        // Y軸画面外に出たらゲームオーバー
        if (!debugMode && (rocketYaxis >= 1.2 || rocketYaxis <= -1.2)) {
          timer.cancel();
          gameHasStarted = false;
          display = 'game_over';
        }

        // ufoの当たり判定
        ufoStatus.forEach((key, ufo) {
          if ((ufo['x'] <= 0.1 && ufo['x'] >= -0.1) &&
              (rocketYaxis <= ufo['outZone']['start'] &&
                  rocketYaxis >= ufo['outZone']['end'])) {
            timer.cancel();
            gameHasStarted = false;
            display = 'game_over';
          }
        });

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

  /// ステージクリア時の処理
  void clearLevel() {
    int? displayLevel = pref.getInt('clearLevel');
    // レベル1を初めてクリアした時はまだ値がセットされておらずnullになるので値を入れておく
    if (displayLevel == null) {
      pref.setInt('clearLevel', 2);
    }
    // 画面に表示されている最大レベルをクリアしたら次のレベルを開放する
    else if (displayLevel == selectedLevel) {
      pref.setInt('clearLevel', displayLevel + 1);
    }

    display = 'top';
    resetPosition();
  }

  /// ステージをクリアしているか判定
  bool isClear(int level) {
    int displayLevel = pref.getInt('clearLevel') ?? 0;
    return displayLevel > level;
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
    goal = -3;
    city = 1.1;

    ufoStatus.forEach((_, ufo) => ufo['x'] = randomDouble(level, 'minus'));

    cloudStatus['cloud1']['y'] = -1.0;
    cloudStatus['cloud2']['y'] = -0.8;
    cloudStatus['cloud3']['y'] = -0.6;

    meteorite = -3;
    meteorite2 = -2.8;
    meteorite3 = -2.6;
    meteorite4 = -2.3;
    meteorite5 = -2.0;

    star = -2;
    star2 = -2.8;
    star3 = -2.6;

    notifyListeners();
  }

  void returnHowToTop() {
    switchDisplay('top');
    gameHasStarted = false;
    explosion = false;
    boost = false;
    resetPosition();
    notifyListeners();
  }

  /// プレイ中時間に応じて背景の色を変えるロジック
  Color? backgroundColor() {
    final hour = DateTime.now().hour;

    if (hour >= 4 && hour < 7) {
      return Colors.indigo[400];
    } else if (hour >= 7 && hour < 12) {
      return Colors.blue[200];
    } else if (hour >= 12 && hour < 16) {
      return Colors.blue[400];
    } else if (hour >= 16 && hour < 18) {
      return Colors.orange[300];
    } else {
      return Colors.indigo[900];
    }
  }
}
