import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/game/game_loop.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/progress/progress_providers.dart';

class GameController extends Notifier<GameState> {
  late final GameLoop _gameLoop;
  late final GameLoop _demoLoop;
  late final RandomSource _random;
  Timer? _boostTimer;
  Timer? _explosionTimer;
  bool _disposed = false;

  @override
  GameState build() {
    final factory = ref.read(gameLoopFactoryProvider);
    _gameLoop = factory();
    _demoLoop = factory();
    _random = ref.read(randomSourceProvider);
    ref.onDispose(_disposeResources);
    return GameState.initial();
  }

  void selectLevel(int levelIndex) {
    _stopGameLoop();
    _stopDemoLoop();
    _cancelDelayedEffects();

    final level = _levelFor(levelIndex);
    final ufos = state.ufos
        .map((ufo) {
          final direction = _randomDirection();
          return ufo.copyWith(
            direction: direction,
            x: _randomPosition(level, direction),
          );
        })
        .toList(growable: false);

    state = state.copyWith(
      mode: GameMode.ready,
      selectedLevel: levelIndex,
      level: level,
      gameHasStarted: false,
      ufos: ufos,
      boost: false,
      explosion: false,
    );
  }

  void openHowToPlay() {
    if (state.mode == GameMode.howToPlay &&
        (_demoLoop.isRunning || state.explosion)) {
      return;
    }

    _stopGameLoop();
    _cancelDelayedEffects();
    state = state.copyWith(
      mode: GameMode.howToPlay,
      gameHasStarted: true,
      boost: false,
      explosion: false,
    );
    _demoLoop.start(_tickHowToPlay);
  }

  void closeHowToPlay() {
    _stopDemoLoop();
    _cancelDelayedEffects();
    state = _resetPositions(state, GameMode.top);
  }

  void handleTap() {
    if (state.gameHasStarted) {
      _move();
    } else if (state.mode == GameMode.ready) {
      _startGame();
    }
  }

  void retry() {
    _stopGameLoop();
    _stopDemoLoop();
    _cancelDelayedEffects();
    state = _resetPositions(state, GameMode.ready);
  }

  void returnToTop() {
    _stopGameLoop();
    _stopDemoLoop();
    _cancelDelayedEffects();
    state = _resetPositions(state, GameMode.top);
  }

  Future<void> exitClear() async {
    final selectedLevel = state.selectedLevel;
    _stopGameLoop();
    _stopDemoLoop();
    _cancelDelayedEffects();
    state = _resetPositions(state, GameMode.top);

    await ref.read(clearProgressProvider.future);
    if (_disposed) {
      return;
    }
    await ref.read(clearProgressProvider.notifier).completeLevel(selectedLevel);
  }

  void _startGame() {
    if (_gameLoop.isRunning) {
      return;
    }

    _stopDemoLoop();
    _explosionTimer?.cancel();
    _explosionTimer = null;
    state = state.copyWith(
      mode: GameMode.playing,
      gameHasStarted: true,
      explosion: false,
    );
    _gameLoop.start(_tickGame);
  }

  void _move() {
    state = state.copyWith(time: 0, initialHeight: state.rocketY);
    _enableBoost();
  }

  void _tickGame() {
    if (_disposed || state.mode != GameMode.playing || !state.gameHasStarted) {
      return;
    }

    var next = _applyGravity(
      state.copyWith(
        time: state.time + 0.005,
        elapsedMilliseconds: state.elapsedMilliseconds + 10,
      ),
    );

    if (next.spaceHeight < 3000 && next.elapsedMilliseconds >= 30000) {
      next = next.copyWith(
        spaceHeight: next.spaceHeight + 3,
        spaceStop: next.spaceStop + 0.001,
      );
    }

    if (next.elapsedMilliseconds >= 60000) {
      next = next.copyWith(goalY: next.goalY + 0.005);
    }

    if (next.goalY - next.rocketY >= -0.1) {
      next = next.copyWith(
        mode: GameMode.clear,
        gameHasStarted: false,
        boost: false,
      );
    }

    if (next.cityY <= 2) {
      next = next.copyWith(cityY: next.cityY + 0.005);
    }

    next = next.copyWith(ufos: _moveUfos(next.ufos, next.level));

    final clouds = next.cloudYs
        .map((cloudY) => cloudY + 0.005)
        .toList(growable: false);
    if (next.elapsedMilliseconds <= 30000) {
      if (clouds[0] > 1.5) {
        clouds[0] = -1.5;
      }
      if (clouds[1] > 1.5) {
        clouds[1] = -1.7;
      }
      if (clouds[2] > 1.5) {
        clouds[2] = -1.8;
      }
    }
    next = next.copyWith(cloudYs: clouds);

    if (next.elapsedMilliseconds >= 35000) {
      final meteorites = next.meteoriteYs
          .map((meteoriteY) => meteoriteY + 0.005)
          .toList(growable: false);
      if (meteorites[0] > 1.5) {
        meteorites[0] = -1.5;
      }
      if (meteorites[1] > 2) {
        meteorites[1] = -1.8;
      }
      if (meteorites[2] > 1.7) {
        meteorites[2] = -2;
      }
      if (meteorites[3] > 1.6) {
        meteorites[3] = -1.5;
      }
      if (meteorites[4] > 1.9) {
        meteorites[4] = -1.8;
      }

      final stars = next.starYs.toList(growable: false);
      if (next.selectedLevel >= 6) {
        stars[0] += 0.005;
        if (stars[0] > 1.2) {
          stars[0] = -1.2;
        }
      }
      if (next.selectedLevel >= 8) {
        stars[1] += 0.005;
        if (stars[1] > 1.5) {
          stars[1] = -1.2;
        }
      }
      if (next.selectedLevel >= 10) {
        stars[2] += 0.005;
        if (stars[2] > 2) {
          stars[2] = -1.2;
        }
      }
      next = next.copyWith(meteoriteYs: meteorites, starYs: stars);
    }

    if (next.rocketY >= 1.2 || next.rocketY <= -1.2) {
      next = _asGameOver(next);
    }

    if (_hasUfoCollision(next)) {
      next = _asGameOver(next);
    }

    if (_hasStarCollision(next)) {
      next = _asGameOver(next);
    }

    state = next;
    if (next.mode != GameMode.playing) {
      _stopGameLoop();
    }
  }

  void _tickHowToPlay() {
    if (_disposed ||
        state.mode != GameMode.howToPlay ||
        !state.gameHasStarted) {
      return;
    }

    var next = _applyGravity(state.copyWith(time: state.time + 0.005));
    final ufos = next.ufos.toList(growable: false);
    var demoUfo = ufos[3];
    final change = demoUfo.direction == HorizontalDirection.left ? -0.01 : 0.01;
    demoUfo = demoUfo.copyWith(x: demoUfo.x + change);
    if ((change < 0 && demoUfo.x < -1.2) || (change > 0 && demoUfo.x > 1.2)) {
      final direction = _randomDirection();
      demoUfo = demoUfo.copyWith(
        direction: direction,
        x: _randomPosition(10, direction),
      );
    }
    ufos[3] = demoUfo;
    next = next.copyWith(ufos: ufos);

    if (_ufoCollidesWithRocket(demoUfo, next.rocketY)) {
      _stopDemoLoop();
      next = next.copyWith(explosion: true);
      _explosionTimer?.cancel();
      _explosionTimer = Timer(const Duration(seconds: 1), () {
        if (_disposed || state.mode != GameMode.howToPlay) {
          return;
        }
        _boostTimer?.cancel();
        _boostTimer = null;
        state = _resetPositions(
          state,
          GameMode.howToPlay,
        ).copyWith(gameHasStarted: true);
        _demoLoop.start(_tickHowToPlay);
      });
    }

    if (next.rocketY > 0) {
      next = next.copyWith(rocketY: 0, time: 0, height: 0, initialHeight: 0);
    }

    state = next;
    _enableBoost();
  }

  GameState _applyGravity(GameState current) {
    final height = -4.5 * current.time * current.time + 0.2 + current.time;
    return current.copyWith(
      height: height,
      rocketY: current.initialHeight - height,
    );
  }

  GameState _resetPositions(GameState current, GameMode targetMode) {
    final ufos = current.ufos
        .map(
          (ufo) => ufo.copyWith(
            x: _randomPosition(current.level, HorizontalDirection.left),
          ),
        )
        .toList(growable: false);

    return current.copyWith(
      mode: targetMode,
      rocketY: 0,
      time: 0,
      height: 0,
      initialHeight: 0,
      gameHasStarted: false,
      ufos: ufos,
      cloudYs: const [-1.0, -0.8, -0.6],
      meteoriteYs: const [-3.0, -2.8, -2.6, -2.3, -2.0],
      starYs: const [-2.0, -2.8, -2.6],
      cityY: 1.1,
      spaceHeight: 0,
      spaceStop: 0,
      goalY: -3,
      elapsedMilliseconds: 0,
      boost: false,
      explosion: false,
    );
  }

  List<UfoState> _moveUfos(List<UfoState> current, double level) {
    return current
        .map((ufo) {
          final change = ufo.direction == HorizontalDirection.left
              ? -0.01
              : 0.01;
          var moved = ufo.copyWith(x: ufo.x + change);
          if ((change < 0 && moved.x < -1.2) || (change > 0 && moved.x > 1.2)) {
            final direction = _randomDirection();
            moved = moved.copyWith(
              direction: direction,
              x: _randomPosition(level, direction),
            );
          }
          return moved;
        })
        .toList(growable: false);
  }

  bool _hasUfoCollision(GameState current) {
    return current.ufos.any(
      (ufo) => _ufoCollidesWithRocket(ufo, current.rocketY),
    );
  }

  bool _ufoCollidesWithRocket(UfoState ufo, double rocketY) {
    return ufo.x <= 0.1 &&
        ufo.x >= -0.1 &&
        rocketY <= ufo.collisionStart &&
        rocketY >= ufo.collisionEnd;
  }

  bool _hasStarCollision(GameState current) {
    return current.starYs.any(
      (starY) =>
          starY - current.rocketY >= -0.1 &&
          starY - current.rocketY <= 0.1 &&
          starY <= 0.15 &&
          starY >= -0.15,
    );
  }

  GameState _asGameOver(GameState current) {
    return current.copyWith(
      mode: GameMode.gameOver,
      gameHasStarted: false,
      boost: false,
    );
  }

  void _enableBoost() {
    if (state.boost) {
      return;
    }

    final expectedMode = state.mode;
    state = state.copyWith(boost: true);
    _boostTimer = Timer(const Duration(seconds: 1), () {
      if (_disposed || state.mode != expectedMode) {
        return;
      }
      state = state.copyWith(boost: false);
      _boostTimer = null;
    });
  }

  HorizontalDirection _randomDirection() {
    return _random.nextInt(2) == 0
        ? HorizontalDirection.left
        : HorizontalDirection.right;
  }

  double _randomPosition(double coefficient, HorizontalDirection direction) {
    if (direction == HorizontalDirection.left) {
      return (_random.nextDouble() + 1.5) * coefficient;
    }
    return (-_random.nextDouble() - 1.5) * coefficient;
  }

  double _levelFor(int levelIndex) {
    return switch (levelIndex) {
      1 => 6,
      2 => 5.5,
      3 => 5,
      4 => 4.5,
      5 => 4,
      6 => 3.5,
      7 => 3,
      8 => 2.5,
      9 => 2,
      10 => 1.5,
      _ => throw ArgumentError.value(levelIndex, 'levelIndex'),
    };
  }

  void _stopGameLoop() {
    _gameLoop.stop();
  }

  void _stopDemoLoop() {
    _demoLoop.stop();
  }

  void _cancelDelayedEffects() {
    _boostTimer?.cancel();
    _boostTimer = null;
    _explosionTimer?.cancel();
    _explosionTimer = null;
  }

  void _disposeResources() {
    _disposed = true;
    _cancelDelayedEffects();
    _stopGameLoop();
    _stopDemoLoop();
  }
}
