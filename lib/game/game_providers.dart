import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/game/game_controller.dart';
import 'package:new_rocket/game/game_loop.dart';
import 'package:new_rocket/game/game_state.dart';

abstract interface class RandomSource {
  double nextDouble();
  int nextInt(int max);
}

class DartRandomSource implements RandomSource {
  DartRandomSource([Random? random]) : _random = random ?? Random();

  final Random _random;

  @override
  double nextDouble() => _random.nextDouble();

  @override
  int nextInt(int max) => _random.nextInt(max);
}

final gameLoopFactoryProvider = Provider<GameLoopFactory>(
  (ref) =>
      () => TimerGameLoop(const Duration(milliseconds: 10)),
);

final randomSourceProvider = Provider<RandomSource>(
  (ref) => DartRandomSource(),
);

final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);
