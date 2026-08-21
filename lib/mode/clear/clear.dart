import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/size_config.dart';

class Clear extends ConsumerWidget {
  const Clear({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      gameControllerProvider.select((state) => state.mode),
    );
    if (mode != GameMode.clear) {
      return const SizedBox();
    }

    final selectedLevel = ref.watch(
      gameControllerProvider.select((state) => state.selectedLevel),
    );
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -0.3),
          child: Text(
            'L E V E L $selectedLevel',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical! * 2,
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.2),
          child: Text(
            'C L E A R !!!',
            style: TextStyle(
              fontSize: SizeConfig.blockSizeVertical! * 2,
              color: Colors.white,
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.3),
          child: Container(
            height: SizeConfig.blockSizeVertical! * 5,
            width: SizeConfig.blockSizeHorizontal! * 30,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.black,
            ),
            child: OutlinedButton(
              onPressed: () async {
                await ref.read(gameControllerProvider.notifier).exitClear();
              },
              child: Text(
                'E X I T',
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
