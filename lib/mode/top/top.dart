import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/objects/lock.dart';
import 'package:new_rocket/progress/progress_providers.dart';
import 'package:new_rocket/size_config.dart';

class Top extends ConsumerWidget {
  const Top({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      gameControllerProvider.select((state) => state.mode),
    );
    if (mode != GameMode.top) {
      return const SizedBox();
    }

    final clearProgress = ref.watch(clearProgressProvider);
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -0.2),
          child: Text(
            'Unlucky Rocket',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical! * 3,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.15),
          child: Text(
            'version 1.2',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical! * 1.5,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.5),
          child: SizedBox(
            height: SizeConfig.blockSizeVertical! * 18,
            width: double.infinity,
            child: clearProgress.when(
              data: (clearLevel) => Center(
                child: Wrap(
                  spacing: SizeConfig.blockSizeHorizontal! * 2,
                  runSpacing: SizeConfig.blockSizeVertical! * 1,
                  children: [
                    for (var level = 1; level <= 10; level++)
                      Container(
                        height: SizeConfig.blockSizeVertical! * 8,
                        width: SizeConfig.blockSizeHorizontal! * 18,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          color: Colors.black,
                        ),
                        child: Center(
                          child: clearLevel < level
                              ? Lock()
                              : OutlinedButton(
                                  onPressed: () => ref
                                      .read(gameControllerProvider.notifier)
                                      .selectLevel(level),
                                  child: Stack(
                                    children: [
                                      clearLevel > level
                                          ? Align(
                                              alignment: const Alignment(0, 1),
                                              child: Text(
                                                'CLEAR',
                                                style: TextStyle(
                                                  fontSize:
                                                      SizeConfig
                                                          .blockSizeVertical! *
                                                      1.7,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      Align(
                                        alignment: const Alignment(0, -0.8),
                                        child: Text(
                                          'LEVEL',
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                1.3,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: const Alignment(0, 0),
                                        child: Text(
                                          level.toString(),
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.blockSizeVertical! *
                                                2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              error: (_, _) => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.75),
          child: Container(
            height: SizeConfig.blockSizeVertical! * 5,
            width: SizeConfig.blockSizeHorizontal! * 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.black,
            ),
            child: OutlinedButton(
              onPressed: ref
                  .read(gameControllerProvider.notifier)
                  .openHowToPlay,
              child: Text(
                '遊び方',
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
