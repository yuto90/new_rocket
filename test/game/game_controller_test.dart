import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/game/game_controller.dart';
import 'package:new_rocket/game/game_loop.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/progress/clear_progress_repository.dart';
import 'package:new_rocket/progress/progress_providers.dart';

class ManualGameLoop implements GameLoop {
  void Function()? callback;
  int startCount = 0;
  int stopCount = 0;

  @override
  bool get isRunning => callback != null;

  @override
  void start(void Function() onTick) {
    startCount++;
    callback = onTick;
  }

  @override
  void stop() {
    stopCount++;
    callback = null;
  }

  void tick() => callback?.call();
}

class FixedRandomSource implements RandomSource {
  FixedRandomSource({this.doubleValue = 0, this.intValue = 0});

  final double doubleValue;
  final int intValue;

  @override
  double nextDouble() => doubleValue;

  @override
  int nextInt(int max) => intValue;
}

class DelayedThenNearRandomSource implements RandomSource {
  int _doubleCalls = 0;

  @override
  double nextDouble() => _doubleCalls++ < 9 ? 0.999 : 0;

  @override
  int nextInt(int max) => 0;
}

class FakeClearProgressRepository implements ClearProgressRepository {
  FakeClearProgressRepository(this.initialValue);

  final int initialValue;
  final List<int> savedValues = [];

  @override
  Future<int> load() async => initialValue;

  @override
  Future<void> save(int value) async => savedValues.add(value);
}

class GameHarness {
  GameHarness({
    RandomSource? randomSource,
    FakeClearProgressRepository? progressRepository,
  }) : progressRepository =
           progressRepository ?? FakeClearProgressRepository(1) {
    container = ProviderContainer(
      overrides: [
        gameLoopFactoryProvider.overrideWithValue(() {
          final loop = ManualGameLoop();
          createdLoops.add(loop);
          return loop;
        }),
        randomSourceProvider.overrideWithValue(
          randomSource ?? FixedRandomSource(),
        ),
        clearProgressRepositoryProvider.overrideWithValue(
          this.progressRepository,
        ),
      ],
    );
    controller = container.read(gameControllerProvider.notifier);
  }

  late final ProviderContainer container;
  late final GameController controller;
  final List<ManualGameLoop> createdLoops = [];
  final FakeClearProgressRepository progressRepository;

  GameState get state => container.read(gameControllerProvider);
  ManualGameLoop get gameLoop => createdLoops[0];
  ManualGameLoop get demoLoop => createdLoops[1];

  void dispose() => container.dispose();
}

void tickWhileKeepingRocketBelow(
  GameHarness harness, {
  required double ceiling,
}) {
  harness.gameLoop.tick();
  if (harness.state.mode == GameMode.playing &&
      harness.state.rocketY > ceiling) {
    harness.controller.handleTap();
  }
}

void advanceSafely(GameHarness harness, int ticks, {double ceiling = 1}) {
  for (var index = 0; index < ticks; index++) {
    tickWhileKeepingRocketBelow(harness, ceiling: ceiling);
  }
}

bool hasUfoCollision(GameState state) {
  return state.ufos.any(
    (ufo) =>
        ufo.x <= 0.1 &&
        ufo.x >= -0.1 &&
        state.rocketY <= ufo.collisionStart &&
        state.rocketY >= ufo.collisionEnd,
  );
}

bool hasStarCollision(GameState state) {
  return state.starYs.any(
    (starY) =>
        starY - state.rocketY >= -0.1 &&
        starY - state.rocketY <= 0.1 &&
        starY <= 0.15 &&
        starY >= -0.15,
  );
}

void main() {
  test('build creates exactly two independent game loops', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);

    expect(harness.createdLoops, hasLength(2));
    expect(harness.gameLoop, isNot(same(harness.demoLoop)));
    expect(harness.state, GameState.initial());
  });

  test('selectLevel updates difficulty and deterministic UFO positions', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);

    harness.controller.selectLevel(3);

    expect(harness.state.mode, GameMode.ready);
    expect(harness.state.selectedLevel, 3);
    expect(harness.state.level, 5);
    expect(
      harness.state.ufos.every(
        (ufo) => ufo.direction == HorizontalDirection.left,
      ),
      isTrue,
    );
    expect(harness.state.ufos.every((ufo) => ufo.x == 7.5), isTrue);
  });

  test('tap on ready starts exactly one game loop', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);

    harness.controller.handleTap();
    harness.controller.handleTap();

    expect(harness.state.mode, GameMode.playing);
    expect(harness.gameLoop.isRunning, isTrue);
    expect(harness.gameLoop.startCount, 1);
    expect(harness.demoLoop.isRunning, isFalse);
  });

  test('playing tap resets time, captures height, and enables boost', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();
    harness.gameLoop.tick();
    final heightBeforeTap = harness.state.rocketY;

    harness.controller.handleTap();

    expect(harness.state.time, 0);
    expect(harness.state.initialHeight, heightBeforeTap);
    expect(harness.state.boost, isTrue);
  });

  test('one game tick applies the existing gravity formula', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();

    harness.gameLoop.tick();

    expect(harness.state.time, 0.005);
    expect(harness.state.height, closeTo(0.2048875, 0.0000000001));
    expect(harness.state.rocketY, closeTo(-0.2048875, 0.0000000001));
    expect(harness.state.elapsedMilliseconds, 10);
    expect(harness.state.cityY, 1.105);
    expect(harness.state.cloudYs, [-0.995, -0.795, -0.595]);
  });

  test('screen boundary collision reaches game over and stops the loop', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();

    for (
      var index = 0;
      index < 500 && harness.state.mode == GameMode.playing;
      index++
    ) {
      harness.gameLoop.tick();
    }

    expect(harness.state.mode, GameMode.gameOver);
    expect(harness.state.rocketY, greaterThanOrEqualTo(1.2));
    expect(harness.state.gameHasStarted, isFalse);
    expect(harness.gameLoop.isRunning, isFalse);
  });

  test('UFO collision uses the existing position boundaries', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(10);
    harness.controller.handleTap();

    for (
      var index = 0;
      index < 300 && harness.state.mode == GameMode.playing;
      index++
    ) {
      tickWhileKeepingRocketBelow(harness, ceiling: 0.2);
    }

    expect(harness.state.mode, GameMode.gameOver);
    expect(hasUfoCollision(harness.state), isTrue);
    expect(harness.state.rocketY.abs(), lessThan(1.2));
  });

  test('UFOs respawn from the source side after crossing the boundary', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(10);
    harness.controller.handleTap();

    advanceSafely(harness, 346);

    expect(harness.state.mode, GameMode.playing);
    expect(
      harness.state.ufos.every(
        (ufo) => ufo.direction == HorizontalDirection.left && ufo.x == 2.25,
      ),
      isTrue,
    );
  });

  test('background and goal movement start at their existing times', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();

    advanceSafely(harness, 2999);
    expect(harness.state.elapsedMilliseconds, 29990);
    expect(harness.state.spaceHeight, 0);
    expect(harness.state.spaceStop, 0);

    advanceSafely(harness, 1);
    expect(harness.state.elapsedMilliseconds, 30000);
    expect(harness.state.spaceHeight, 3);
    expect(harness.state.spaceStop, 0.001);

    advanceSafely(harness, 2999);
    expect(harness.state.elapsedMilliseconds, 59990);
    expect(harness.state.goalY, -3);

    advanceSafely(harness, 1);
    expect(harness.state.elapsedMilliseconds, 60000);
    expect(harness.state.goalY, -2.995);
  });

  test('goal collision reaches clear and stops the loop', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();

    for (
      var index = 0;
      index < 7000 && harness.state.mode == GameMode.playing;
      index++
    ) {
      tickWhileKeepingRocketBelow(harness, ceiling: 1);
    }

    expect(harness.state.mode, GameMode.clear);
    expect(
      harness.state.goalY - harness.state.rocketY,
      greaterThanOrEqualTo(-0.1),
    );
    expect(harness.state.gameHasStarted, isFalse);
    expect(harness.gameLoop.isRunning, isFalse);
  });

  test('meteorites move, respawn, and do not create a collision branch', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();

    advanceSafely(harness, 3499);
    expect(harness.state.meteoriteYs, [-3.0, -2.8, -2.6, -2.3, -2.0]);

    advanceSafely(harness, 1);
    expect(harness.state.meteoriteYs, [-2.995, -2.795, -2.595, -2.295, -1.995]);

    advanceSafely(harness, 900);
    expect(harness.state.mode, GameMode.playing);
    expect(harness.state.meteoriteYs.first, -1.5);
  });

  test('star collision reaches game over at the existing boundaries', () {
    final harness = GameHarness(randomSource: DelayedThenNearRandomSource());
    addTearDown(harness.dispose);
    harness.controller.selectLevel(6);
    harness.controller.handleTap();

    advanceSafely(harness, 3600);
    expect(harness.state.mode, GameMode.playing);

    for (
      var index = 0;
      index < 500 && harness.state.mode == GameMode.playing;
      index++
    ) {
      tickWhileKeepingRocketBelow(harness, ceiling: 0.2);
    }

    expect(harness.state.mode, GameMode.gameOver);
    expect(hasStarCollision(harness.state), isTrue);
    expect(hasUfoCollision(harness.state), isFalse);
  });

  test('retry resets positions and returns to ready', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();
    for (
      var index = 0;
      index < 500 && harness.state.mode == GameMode.playing;
      index++
    ) {
      harness.gameLoop.tick();
    }

    harness.controller.retry();

    expect(harness.state.mode, GameMode.ready);
    expect(harness.state.rocketY, 0);
    expect(harness.state.time, 0);
    expect(harness.state.height, 0);
    expect(harness.state.initialHeight, 0);
    expect(harness.state.gameHasStarted, isFalse);
    expect(harness.state.spaceHeight, 0);
    expect(harness.state.spaceStop, 0);
    expect(harness.state.elapsedMilliseconds, 0);
    expect(harness.state.goalY, -3);
    expect(harness.state.cityY, 1.1);
    expect(harness.state.ufos.every((ufo) => ufo.x == 9), isTrue);
    expect(harness.state.cloudYs, [-1.0, -0.8, -0.6]);
    expect(harness.state.meteoriteYs, [-3.0, -2.8, -2.6, -2.3, -2.0]);
    expect(harness.state.starYs, [-2.0, -2.8, -2.6]);
  });

  test('returnToTop stops gameplay and resets positions', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.selectLevel(2);
    harness.controller.handleTap();
    harness.gameLoop.tick();

    harness.controller.returnToTop();

    expect(harness.state.mode, GameMode.top);
    expect(harness.state.rocketY, 0);
    expect(harness.state.elapsedMilliseconds, 0);
    expect(harness.state.ufos.every((ufo) => ufo.x == 8.25), isTrue);
    expect(harness.gameLoop.isRunning, isFalse);
  });

  test('how-to commands manage only the independent demo loop', () {
    final harness = GameHarness();
    addTearDown(harness.dispose);

    harness.controller.openHowToPlay();
    harness.controller.openHowToPlay();

    expect(harness.state.mode, GameMode.howToPlay);
    expect(harness.state.gameHasStarted, isTrue);
    expect(harness.demoLoop.isRunning, isTrue);
    expect(harness.demoLoop.startCount, 1);
    expect(harness.gameLoop.isRunning, isFalse);

    harness.controller.closeHowToPlay();

    expect(harness.state.mode, GameMode.top);
    expect(harness.state.gameHasStarted, isFalse);
    expect(harness.state.explosion, isFalse);
    expect(harness.state.boost, isFalse);
    expect(harness.demoLoop.isRunning, isFalse);
  });

  testWidgets('closing how-to prevents the delayed demo restart', (
    tester,
  ) async {
    final harness = GameHarness();
    addTearDown(harness.dispose);
    harness.controller.openHowToPlay();

    for (var index = 0; index < 250 && !harness.state.explosion; index++) {
      harness.demoLoop.tick();
    }
    expect(harness.state.explosion, isTrue);
    expect(harness.demoLoop.isRunning, isFalse);

    harness.controller.closeHowToPlay();
    await tester.pump(const Duration(seconds: 1));

    expect(harness.state.mode, GameMode.top);
    expect(harness.state.explosion, isFalse);
    expect(harness.demoLoop.startCount, 1);
    expect(harness.demoLoop.isRunning, isFalse);
  });

  test('exitClear records the selected level and returns to top', () async {
    final repository = FakeClearProgressRepository(1);
    final harness = GameHarness(progressRepository: repository);
    addTearDown(harness.dispose);
    harness.controller.selectLevel(1);
    harness.controller.handleTap();
    for (
      var index = 0;
      index < 7000 && harness.state.mode == GameMode.playing;
      index++
    ) {
      tickWhileKeepingRocketBelow(harness, ceiling: 1);
    }
    expect(harness.state.mode, GameMode.clear);

    await harness.controller.exitClear();

    expect(repository.savedValues, [2]);
    expect(harness.state.mode, GameMode.top);
    expect(harness.state.rocketY, 0);
  });

  testWidgets(
    'container disposal stops both loops and makes stale callbacks inert',
    (tester) async {
      final harness = GameHarness();
      harness.controller.openHowToPlay();
      final staleCallback = harness.demoLoop.callback!;

      for (var index = 0; index < 250 && !harness.state.explosion; index++) {
        harness.demoLoop.tick();
      }
      expect(harness.state.explosion, isTrue);

      harness.dispose();

      expect(harness.gameLoop.isRunning, isFalse);
      expect(harness.demoLoop.isRunning, isFalse);
      expect(staleCallback, returnsNormally);
      await tester.pump(const Duration(seconds: 1));
      expect(harness.demoLoop.startCount, 1);
    },
  );
}
