import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/ads/ad_providers.dart';
import 'package:new_rocket/game/game_controller.dart';
import 'package:new_rocket/game/game_loop.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/mainpage.dart';
import 'package:new_rocket/objects/lock.dart';
import 'package:new_rocket/progress/clear_progress_repository.dart';
import 'package:new_rocket/progress/progress_providers.dart';

class ManualGameLoop implements GameLoop {
  void Function()? callback;

  @override
  bool get isRunning => callback != null;

  @override
  void start(void Function() onTick) {
    callback = onTick;
  }

  @override
  void stop() {
    callback = null;
  }

  void tick() => callback?.call();
}

class FixedRandomSource implements RandomSource {
  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => 0;
}

class FakeClearProgressRepository implements ClearProgressRepository {
  FakeClearProgressRepository(this.clearLevel);

  final int clearLevel;
  final List<int> savedValues = [];

  @override
  Future<int> load() async => clearLevel;

  @override
  Future<void> save(int value) async {
    savedValues.add(value);
  }
}

class MainPageHarness {
  MainPageHarness({required int clearLevel})
    : progressRepository = FakeClearProgressRepository(clearLevel);

  final FakeClearProgressRepository progressRepository;
  final List<ManualGameLoop> createdLoops = [];
  late final ProviderContainer container;

  Widget get app {
    return ProviderScope(
      overrides: [
        gameLoopFactoryProvider.overrideWithValue(() {
          final loop = ManualGameLoop();
          createdLoops.add(loop);
          return loop;
        }),
        randomSourceProvider.overrideWithValue(FixedRandomSource()),
        nowProvider.overrideWithValue(() => DateTime(2026, 7, 25, 12)),
        clearProgressRepositoryProvider.overrideWithValue(progressRepository),
        bannerAdsEnabledProvider.overrideWithValue(false),
      ],
      child: const MaterialApp(home: MainPage()),
    );
  }

  GameController get controller =>
      container.read(gameControllerProvider.notifier);
  GameState get state => container.read(gameControllerProvider);
  ManualGameLoop get gameLoop => createdLoops[0];

  void captureContainer(WidgetTester tester) {
    container = ProviderScope.containerOf(
      tester.element(find.byType(MainPage)),
    );
  }

  void reachGameOver() {
    for (
      var index = 0;
      index < 500 && state.mode == GameMode.playing;
      index++
    ) {
      gameLoop.tick();
    }
  }

  void reachClear() {
    for (
      var index = 0;
      index < 7000 && state.mode == GameMode.playing;
      index++
    ) {
      gameLoop.tick();
      if (state.mode == GameMode.playing && state.rocketY > 1) {
        controller.handleTap();
      }
    }
  }
}

Future<MainPageHarness> pumpHarness(
  WidgetTester tester, {
  required int clearLevel,
}) async {
  final harness = MainPageHarness(clearLevel: clearLevel);
  await tester.pumpWidget(harness.app);
  await tester.pumpAndSettle();
  harness.captureContainer(tester);
  return harness;
}

Future<void> selectLevelOne(
  WidgetTester tester,
  MainPageHarness harness,
) async {
  await tester.tap(find.text('1'));
  await tester.pump();
  expect(harness.state.mode, GameMode.ready);
}

void main() {
  testWidgets('top selects level 1 and enters ready mode', (tester) async {
    final harness = await pumpHarness(tester, clearLevel: 1);

    expect(find.text('Unlucky Rocket'), findsOneWidget);
    await selectLevelOne(tester, harness);

    expect(find.text('L E V E L 1'), findsOneWidget);
    expect(find.text('画面をタップしたらスタートするよ'), findsOneWidget);
  });

  testWidgets('ready screen tap starts playing', (tester) async {
    final harness = await pumpHarness(tester, clearLevel: 1);
    await selectLevelOne(tester, harness);

    await tester.tap(find.text('画面をタップしたらスタートするよ'));
    await tester.pump();

    expect(harness.state.mode, GameMode.playing);
    expect(find.text('画面をタップしたらスタートするよ'), findsNothing);
    expect(harness.gameLoop.isRunning, isTrue);
  });

  testWidgets('how-to back action returns to top', (tester) async {
    final harness = await pumpHarness(tester, clearLevel: 1);

    await tester.tap(find.text('遊び方'));
    await tester.pump();
    expect(harness.state.mode, GameMode.howToPlay);
    expect(find.text('-*-*-*-*- 遊び方 -*-*-*-*-'), findsOneWidget);

    await tester.tap(find.text('戻る'));
    await tester.pump();

    expect(harness.state.mode, GameMode.top);
    expect(find.text('Unlucky Rocket'), findsOneWidget);
  });

  testWidgets('game-over retry returns to ready', (tester) async {
    final harness = await pumpHarness(tester, clearLevel: 1);
    await selectLevelOne(tester, harness);
    await tester.tap(find.text('画面をタップしたらスタートするよ'));
    await tester.pump();
    harness.reachGameOver();
    await tester.pump();
    expect(find.text('G A M E  O V E R'), findsOneWidget);

    await tester.tap(find.text('再挑戦する'));
    await tester.pump();

    expect(harness.state.mode, GameMode.ready);
    expect(find.text('L E V E L 1'), findsOneWidget);
  });

  testWidgets('game-over top action returns to top', (tester) async {
    final harness = await pumpHarness(tester, clearLevel: 1);
    await selectLevelOne(tester, harness);
    await tester.tap(find.text('画面をタップしたらスタートするよ'));
    await tester.pump();
    harness.reachGameOver();
    await tester.pump();
    expect(find.text('G A M E  O V E R'), findsOneWidget);

    await tester.tap(find.text('トップに戻る'));
    await tester.pump();

    expect(harness.state.mode, GameMode.top);
    expect(find.text('Unlucky Rocket'), findsOneWidget);
  });

  testWidgets('clear exit updates progress and returns to top', (tester) async {
    final harness = await pumpHarness(tester, clearLevel: 1);
    await selectLevelOne(tester, harness);
    await tester.tap(find.text('画面をタップしたらスタートするよ'));
    await tester.pump();
    harness.reachClear();
    await tester.pump();
    expect(harness.state.mode, GameMode.clear);
    expect(find.text('C L E A R !!!'), findsOneWidget);

    await tester.tap(find.text('E X I T'));
    await tester.pumpAndSettle();

    expect(harness.state.mode, GameMode.top);
    expect(harness.progressRepository.savedValues, [2]);
    expect(find.text('Unlucky Rocket'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('top shows cleared and locked levels from async progress', (
    tester,
  ) async {
    await pumpHarness(tester, clearLevel: 3);

    expect(find.text('CLEAR'), findsNWidgets(2));
    expect(find.byType(Lock), findsNWidgets(7));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsNothing);
  });
}
