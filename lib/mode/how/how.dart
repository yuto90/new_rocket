import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/objects/goal.dart';
import 'package:new_rocket/objects/star.dart';
import 'package:new_rocket/objects/ufo.dart';
import 'package:new_rocket/size_config.dart';

class How extends ConsumerWidget {
  const How({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      gameControllerProvider.select((state) => state.mode),
    );
    if (mode != GameMode.howToPlay) {
      return const SizedBox();
    }

    return Stack(
      children: [
        // クリア条件の注釈
        Align(
          alignment: const Alignment(0, -0.7),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.black,
            ),
            height: SizeConfig.blockSizeVertical! * 20,
            width: SizeConfig.blockSizeHorizontal! * 90,
            child: Column(
              children: [
                const Spacer(),
                Text(
                  '-*-*-*-*- 遊び方 -*-*-*-*-',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'ロケットに迫るUFOと星を避けて宇宙の惑星を目指そう!',
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeVertical! * 1.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Spacer(),
                    Goal(heightSize: 10, widthSize: 10),
                    const Spacer(),
                    Container(
                      height: SizeConfig.blockSizeVertical! * 8,
                      width: SizeConfig.blockSizeHorizontal! * 0.5,
                      color: Colors.white,
                    ),
                    const Spacer(),
                    Row(children: [Ufo(), Star()]),
                    const Spacer(),
                  ],
                ),
                Row(
                  children: [
                    const Spacer(flex: 5),
                    Text(
                      '惑星',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    const Spacer(flex: 8),
                    Text(
                      'UFO, 星',
                      style: TextStyle(
                        fontSize: SizeConfig.blockSizeVertical! * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(flex: 5),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        // ロケットの注釈
        Align(
          alignment: const Alignment(0, 0.16),
          child: Text(
            '↑',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical! * 6,
              color: Colors.black,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.26),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.black,
            ),
            height: SizeConfig.blockSizeVertical! * 7,
            width: SizeConfig.blockSizeHorizontal! * 90,
            child: Center(
              child: Text(
                '''
画面をタップするとロケットが上にブースト!
横から向かってくるUFOや星に当たったり、
画面外に出てしまうとゲームオーバー!
                      ''',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        // 戻るボタン
        Align(
          alignment: const Alignment(0, 0.5),
          child: Container(
            height: SizeConfig.blockSizeVertical! * 5,
            width: SizeConfig.blockSizeHorizontal! * 30,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.black,
            ),
            child: OutlinedButton(
              onPressed: ref
                  .read(gameControllerProvider.notifier)
                  .closeHowToPlay,
              child: Text(
                '戻る',
                style: TextStyle(
                  fontSize: SizeConfig.blockSizeVertical! * 1.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
