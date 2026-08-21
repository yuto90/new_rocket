import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/size_config.dart';

class GameOver extends ConsumerWidget {
  const GameOver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      gameControllerProvider.select((state) => state.mode),
    );
    if (mode != GameMode.gameOver) {
      return const SizedBox();
    }

    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -0.2),
          child: Text(
            'G A M E  O V E R',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical! * 2,
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.35),
          child: Container(
            height: SizeConfig.blockSizeVertical! * 5,
            width: SizeConfig.blockSizeHorizontal! * 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.black,
            ),
            child: OutlinedButton(
              onPressed: ref.read(gameControllerProvider.notifier).retry,
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
          alignment: const Alignment(0, 0.5),
          child: Container(
            height: SizeConfig.blockSizeVertical! * 5,
            width: SizeConfig.blockSizeHorizontal! * 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.black,
            ),
            child: OutlinedButton(
              onPressed: ref.read(gameControllerProvider.notifier).returnToTop,
              child: Text(
                'トップに戻る',
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
