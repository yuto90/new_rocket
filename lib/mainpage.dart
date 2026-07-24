import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/ads/banner_ad_view.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/mode/clear/clear.dart';
import 'package:new_rocket/mode/game_over/game_over.dart';
import 'package:new_rocket/mode/how/how.dart';
import 'package:new_rocket/mode/ready/ready.dart';
import 'package:new_rocket/mode/top/top.dart';
import 'package:new_rocket/objects/city.dart';
import 'package:new_rocket/objects/cloud.dart';
import 'package:new_rocket/objects/explosion.dart';
import 'package:new_rocket/objects/goal.dart';
import 'package:new_rocket/objects/meteorite.dart';
import 'package:new_rocket/objects/rocket.dart';
import 'package:new_rocket/objects/star.dart';
import 'package:new_rocket/objects/ufo.dart';
import 'package:new_rocket/size_config.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Widgetサイズ最適化用クラスを初期化
    SizeConfig().init(context);
    return const Scaffold(body: GameScene());
  }
}

class GameScene extends ConsumerWidget {
  const GameScene({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameControllerProvider);
    final cloudXs = <double>[0.9, -1, 1];
    final cloudVerticalSizes = <double>[20, 15, 20];
    final cloudHorizontalSizes = <double>[60, 45, 50];
    final meteoriteXs = <double>[1, -0.8, 0.6, 0.8, -0.6];
    final meteoriteVerticalSizes = <double>[18, 15, 10, 16, 18];
    final meteoriteHorizontalSizes = <double>[27, 20, 20, 26, 27];

    return GestureDetector(
      onTap: ref.read(gameControllerProvider.notifier).handleTap,
      child: Stack(
        children: [
          // * 空背景 ----------------------------------------------------------
          Container(color: _backgroundColor(ref.read(nowProvider)())),
          //宇宙ステージ
          Container(
            height: state.spaceHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.blue.withValues(alpha: 0),
                ],
                stops: [state.spaceStop, 1.0],
              ),
            ),
          ),
          // * 地面 ----------------------------------------------------------
          Align(alignment: Alignment(0, state.cityY), child: City()),
          // * ゴール -----------------------------------------------------------
          Align(
            alignment: Alignment(0, state.goalY),
            child: Goal(heightSize: 20, widthSize: 20),
          ),
          // * ロケット (ゲーム進行中以外はz-indexを雲より前面にする)
          state.mode == GameMode.playing
              ? Align(
                  alignment: Alignment(0, state.rocketY),
                  child: MyRocket(boostFlg: state.boost),
                )
              : const SizedBox(),
          // * UFO -----------------------------------------------------------
          for (final ufo in state.ufos)
            Align(alignment: Alignment(ufo.x, ufo.laneY), child: Ufo()),
          // * 雲 -----------------------------------------------------------
          for (var index = 0; index < state.cloudYs.length; index++)
            Align(
              alignment: Alignment(cloudXs[index], state.cloudYs[index]),
              child: Cloud(
                vertical:
                    SizeConfig.blockSizeVertical! * cloudVerticalSizes[index],
                horizontal:
                    SizeConfig.blockSizeHorizontal! *
                    cloudHorizontalSizes[index],
              ),
            ),
          // * 星 -----------------------------------------------------------
          state.selectedLevel >= 6
              ? Align(
                  alignment: Alignment(-state.starYs[0], state.starYs[0]),
                  child: Star(),
                )
              : const SizedBox(),
          state.selectedLevel >= 8
              ? Align(
                  alignment: Alignment(-state.starYs[1], state.starYs[1]),
                  child: Star(),
                )
              : const SizedBox(),
          state.selectedLevel >= 10
              ? Align(
                  alignment: Alignment(-state.starYs[2], state.starYs[2]),
                  child: Star(),
                )
              : const SizedBox(),
          // * 隕石 -----------------------------------------------------------
          for (var index = 0; index < state.meteoriteYs.length; index++)
            Align(
              alignment: Alignment(
                meteoriteXs[index],
                state.meteoriteYs[index],
              ),
              child: Meteorite(
                vertical:
                    SizeConfig.blockSizeVertical! *
                    meteoriteVerticalSizes[index],
                horizontal:
                    SizeConfig.blockSizeHorizontal! *
                    meteoriteHorizontalSizes[index],
              ),
            ),
          // * ルール説明画面
          const How(),
          // * ロケット (ゲーム進行中はz-indexを雲より背面にする)
          state.mode != GameMode.playing
              ? Align(
                  alignment: Alignment(0, state.rocketY),
                  child: state.mode == GameMode.gameOver || state.explosion
                      ? Explosion()
                      : MyRocket(boostFlg: state.boost),
                )
              : const SizedBox(),
          // * タイトル画面
          const Top(),
          // * ゲーム開始画面
          const Ready(),
          // * クリア画面
          const Clear(),
          // * ゲームオーバー画面
          const GameOver(),
          const BannerAdView(),
        ],
      ),
    );
  }
}

Color? _backgroundColor(DateTime now) {
  final hour = now.hour;
  if (hour >= 4 && hour < 7) {
    return Colors.indigo[400];
  }
  if (hour >= 7 && hour < 12) {
    return Colors.blue[200];
  }
  if (hour >= 12 && hour < 16) {
    return Colors.blue[400];
  }
  if (hour >= 16 && hour < 18) {
    return Colors.orange[300];
  }
  return Colors.indigo[900];
}
