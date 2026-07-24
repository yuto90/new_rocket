import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:new_rocket/ads/ad_providers.dart';
import 'package:new_rocket/game/game_loop.dart';
import 'package:new_rocket/game/game_providers.dart';
import 'package:new_rocket/game/game_state.dart';
import 'package:new_rocket/mainpage.dart';
import 'package:new_rocket/objects/lock.dart';
import 'package:new_rocket/objects/ufo.dart';
import 'package:new_rocket/progress/clear_progress_repository.dart';
import 'package:new_rocket/progress/progress_providers.dart';

class ManualGameLoop implements GameLoop {
  void Function()? _onTick;

  @override
  bool get isRunning => _onTick != null;

  @override
  void start(void Function() onTick) {
    _onTick = onTick;
  }

  @override
  void stop() {
    _onTick = null;
  }

  void tick() => _onTick?.call();
}

class FarAwayFixedRandomSource implements RandomSource {
  @override
  double nextDouble() => 0.999;

  @override
  int nextInt(int max) => 0;
}

class InMemoryClearProgressRepository implements ClearProgressRepository {
  int clearLevel = 1;

  @override
  Future<int> load() async => clearLevel;

  @override
  Future<void> save(int value) async {
    clearLevel = value;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rendered UFO movement and clear exit unlock level 2 on iOS', (
    tester,
  ) async {
    final loops = <ManualGameLoop>[];
    final progressRepository = InMemoryClearProgressRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          gameLoopFactoryProvider.overrideWithValue(() {
            final loop = ManualGameLoop();
            loops.add(loop);
            return loop;
          }),
          randomSourceProvider.overrideWithValue(FarAwayFixedRandomSource()),
          nowProvider.overrideWithValue(() => DateTime(2026, 7, 25, 12)),
          clearProgressRepositoryProvider.overrideWithValue(progressRepository),
          bannerAdsEnabledProvider.overrideWithValue(false),
        ],
        child: const MaterialApp(home: MainPage()),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MainPage)),
    );
    final controller = container.read(gameControllerProvider.notifier);
    final gameLoop = loops.first;

    await tester.tap(find.text('1'));
    await tester.pump();
    expect(container.read(gameControllerProvider).mode, GameMode.ready);

    await tester.tap(find.text('画面をタップしたらスタートするよ'));
    await tester.pump();
    expect(container.read(gameControllerProvider).mode, GameMode.playing);
    expect(find.byType(Ufo), findsNWidgets(9));

    final renderedUfos = find.byWidgetPredicate(
      (widget) => widget is Align && widget.child is Ufo,
    );
    final firstAlignmentBefore = tester
        .widget<Align>(renderedUfos.first)
        .alignment;
    final firstXBefore = container.read(gameControllerProvider).ufos.first.x;

    gameLoop.tick();
    await tester.pump();

    final firstXAfter = container.read(gameControllerProvider).ufos.first.x;
    final firstAlignmentAfter = tester
        .widget<Align>(renderedUfos.first)
        .alignment;
    expect(firstXAfter, lessThan(firstXBefore));
    expect(firstAlignmentAfter, isNot(firstAlignmentBefore));
    expect(firstAlignmentAfter, Alignment(firstXAfter, -1));

    var ticks = 1;
    while (ticks < 6800 &&
        container.read(gameControllerProvider).mode == GameMode.playing) {
      gameLoop.tick();
      ticks++;
      final state = container.read(gameControllerProvider);
      if (state.mode == GameMode.playing && state.rocketY > 1) {
        controller.handleTap();
      }
    }
    await tester.pump();

    expect(ticks, inInclusiveRange(6500, 6800));
    expect(container.read(gameControllerProvider).mode, GameMode.clear);
    expect(find.text('C L E A R !!!'), findsOneWidget);

    await tester.tap(find.text('E X I T'));
    await tester.pumpAndSettle();

    expect(container.read(gameControllerProvider).mode, GameMode.top);
    expect(progressRepository.clearLevel, 2);
    expect(find.text('CLEAR'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.byType(Lock), findsNWidgets(8));
  });
}
