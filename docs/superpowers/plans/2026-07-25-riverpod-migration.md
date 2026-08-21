# Riverpod Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `provider` and `MainPageModel` with Riverpod 3 while preserving the existing game, progress, and banner-ad behavior.

**Architecture:** A session-scoped `GameController extends Notifier<GameState>` owns the synchronous game state and 10 ms loops. Progress and banner ads are separate session-scoped controllers behind replaceable repository/gateway providers, while the UI reads only the state slices it renders.

**Tech Stack:** Flutter 3.44.6, Dart 3.12.2, `flutter_riverpod: ^3.3.2`, `flutter_test`, `shared_preferences`, `google_mobile_ads`

## Global Constraints

- Do not use Riverpod code generation or any API from `flutter_riverpod/legacy.dart`.
- Preserve the 10 ms loop interval, formulas, collision thresholds, level mapping, mode transitions, and visual stacking order.
- Preserve `clearLevel`, its default value `1`, and the existing level-10 result `11`.
- Preserve `BANNER_UNIT_ID_ANDROID`, `BANNER_UNIT_ID_IOS`, debug test IDs, and the no-retry behavior after an ad load failure.
- Keep `gameControllerProvider`, `clearProgressProvider`, and `bannerAdProvider` session-scoped and non-`autoDispose`.
- Stop loops, delayed callbacks, and banner resources from updating state after provider disposal.
- Do not add OS background pause/resume behavior or unrelated Android/iOS changes.
- Do not move the existing `lib/mode/` or `lib/objects/` files.
- Final state must contain no direct `provider` dependency, `package:provider` import, `MainPageModel`, or `notifyListeners()`.
- Use FVM for every Flutter and Dart command.

---

### Task 1: Add Riverpod and immutable game state

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `lib/game/game_state.dart`
- Create: `lib/game/game_loop.dart`
- Create: `lib/game/game_providers.dart`
- Create: `test/game/game_state_test.dart`
- Create: `test/game/game_loop_test.dart`

**Interfaces:**
- Produces: `GameMode`, `HorizontalDirection`, `UfoState`, `GameState`
- Produces: `GameLoop`, `TimerGameLoop`, `GameLoopFactory`
- Produces: `RandomSource`, `DartRandomSource`, `gameLoopFactoryProvider`, `randomSourceProvider`, `nowProvider`

- [ ] **Step 1: Add failing immutable-state tests**

Create tests that import the not-yet-created state classes and assert hand-derived initial values and defensive list copies:

```dart
test('initial state matches the existing game positions', () {
  final state = GameState.initial();

  expect(state.mode, GameMode.top);
  expect(state.selectedLevel, 1);
  expect(state.level, 1);
  expect(state.rocketY, 0);
  expect(state.ufos.length, 9);
  expect(state.ufos.first.laneY, -1);
  expect(state.cloudYs, [-1.0, -0.8, -0.6]);
  expect(state.meteoriteYs, [-3.0, -2.8, -2.6, -2.3, -2.0]);
  expect(state.starYs, [-2.0, -2.5, -3.0]);
});

test('state collections cannot be mutated through callers', () {
  final source = <double>[-1, -0.8, -0.6];
  final state = GameState.initial().copyWith(cloudYs: source);
  source[0] = 99;

  expect(state.cloudYs.first, -1);
  expect(() => state.cloudYs.add(0), throwsUnsupportedError);
});
```

Name the break: these fail if the initial values drift or a mutable list escapes.

- [ ] **Step 2: Run the tests and verify RED**

Run:

```bash
fvm flutter test test/game/game_state_test.dart
```

Expected: compilation failure because `lib/game/game_state.dart` does not exist.

- [ ] **Step 3: Implement typed immutable game state**

Implement these exact public types in `lib/game/game_state.dart`:

```dart
enum GameMode { top, howToPlay, ready, playing, clear, gameOver }

enum HorizontalDirection { left, right }

@immutable
class UfoState {
  const UfoState({
    required this.laneY,
    required this.x,
    required this.direction,
    required this.collisionStart,
    required this.collisionEnd,
  });

  final double laneY;
  final double x;
  final HorizontalDirection direction;
  final double collisionStart;
  final double collisionEnd;

  UfoState copyWith({
    double? x,
    HorizontalDirection? direction,
  });
}
```

`GameState` must expose final fields for the existing model data:

```dart
final GameMode mode;
final int selectedLevel;
final double level;
final double rocketY;
final double time;
final double height;
final double initialHeight;
final bool gameHasStarted;
final List<UfoState> ufos;
final List<double> cloudYs;
final List<double> meteoriteYs;
final List<double> starYs;
final double cityY;
final double spaceHeight;
final double spaceStop;
final double goalY;
final int elapsedMilliseconds;
final bool boost;
final bool explosion;
```

Use `List.unmodifiable` in the constructor, `GameState.initial()` for existing startup values, and a typed `copyWith`. Implement value equality with `listEquals` and `Object.hash`/`Object.hashAll`.

- [ ] **Step 4: Add failing loop lifecycle tests**

Write a real `TimerGameLoop` test with a short interval and assert stopping prevents later callbacks:

```dart
test('stop prevents later timer callbacks', () async {
  var ticks = 0;
  final loop = TimerGameLoop(const Duration(milliseconds: 1));
  loop.start(() => ticks++);
  await Future<void>.delayed(const Duration(milliseconds: 5));
  loop.stop();
  final stoppedAt = ticks;
  await Future<void>.delayed(const Duration(milliseconds: 5));

  expect(stoppedAt, greaterThan(0));
  expect(ticks, stoppedAt);
  expect(loop.isRunning, isFalse);
});
```

Name the break: this fails if `stop()` leaves the periodic timer active.

- [ ] **Step 5: Run the loop test and verify RED**

Run:

```bash
fvm flutter test test/game/game_loop_test.dart
```

Expected: compilation failure because `GameLoop` and `TimerGameLoop` do not exist.

- [ ] **Step 6: Implement loop and injectable infrastructure**

Implement:

```dart
abstract interface class GameLoop {
  bool get isRunning;
  void start(void Function() onTick);
  void stop();
}

class TimerGameLoop implements GameLoop {
  TimerGameLoop(this.interval);
  final Duration interval;
  Timer? _timer;
  // start() stops the old timer before creating Timer.periodic.
}

typedef GameLoopFactory = GameLoop Function();

abstract interface class RandomSource {
  double nextDouble();
  int nextInt(int max);
}
```

Define manual providers in `lib/game/game_providers.dart`:

```dart
final gameLoopFactoryProvider = Provider<GameLoopFactory>(
  (ref) => () => TimerGameLoop(const Duration(milliseconds: 10)),
);
final randomSourceProvider = Provider<RandomSource>(
  (ref) => DartRandomSource(),
);
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);
```

- [ ] **Step 7: Add Riverpod dependency and verify GREEN**

Add only:

```yaml
dependencies:
  flutter_riverpod: ^3.3.2
```

Run:

```bash
fvm flutter pub get
fvm dart format lib/game test/game
fvm flutter test test/game
```

Expected: all Task 1 tests pass.

- [ ] **Step 8: Commit Task 1**

```bash
git add pubspec.yaml pubspec.lock lib/game test/game
git commit -m "Add immutable game state foundation"
```

---

### Task 2: Move clear progress behind AsyncNotifier

**Files:**
- Create: `lib/progress/clear_progress_repository.dart`
- Create: `lib/progress/clear_progress_controller.dart`
- Create: `lib/progress/progress_providers.dart`
- Create: `test/progress/clear_progress_controller_test.dart`

**Interfaces:**
- Produces: `ClearProgressRepository.load(): Future<int>`
- Produces: `ClearProgressRepository.save(int value): Future<void>`
- Produces: `ClearProgressController.completeLevel(int selectedLevel): Future<void>`
- Produces: `clearProgressRepositoryProvider`, `clearProgressProvider`

- [ ] **Step 1: Write failing progress tests**

Use an in-memory fake repository and a real `ProviderContainer`:

```dart
test('loads the existing clearLevel value', () async {
  final repository = FakeClearProgressRepository(initialValue: 3);
  final container = ProviderContainer(
    overrides: [
      clearProgressRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);

  expect(await container.read(clearProgressProvider.future), 3);
});

test('completing the highest unlocked level saves the next level', () async {
  final repository = FakeClearProgressRepository(initialValue: 3);
  final container = ProviderContainer(
    overrides: [
      clearProgressRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  await container.read(clearProgressProvider.future);

  await container.read(clearProgressProvider.notifier).completeLevel(3);

  expect(container.read(clearProgressProvider).requireValue, 4);
  expect(repository.savedValues, [4]);
});
```

Also cover:

- Completing a lower level does not reduce or re-save progress.
- Completing level 10 stores 11.
- Load failure resolves to `1`.
- Save failure keeps the optimistic in-session value.

Name the breaks: wrong compatibility key/default, lost progression, or a storage failure that makes the game unusable.

- [ ] **Step 2: Run tests and verify RED**

Run:

```bash
fvm flutter test test/progress/clear_progress_controller_test.dart
```

Expected: compilation failure because the progress types do not exist.

- [ ] **Step 3: Implement repository and providers**

Implement:

```dart
abstract interface class ClearProgressRepository {
  Future<int> load();
  Future<void> save(int value);
}

class SharedPreferencesClearProgressRepository
    implements ClearProgressRepository {
  static const key = 'clearLevel';

  @override
  Future<int> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key) ?? 1;
  }

  @override
  Future<void> save(int value) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setInt(key, value);
    if (!saved) {
      throw StateError('Failed to save clear progress');
    }
  }
}
```

Define `ClearProgressController extends AsyncNotifier<int>`. `build()` catches load errors, logs with `debugPrint`, and returns `1`. `completeLevel()` computes `selectedLevel + 1` only when the current value equals the selected level, updates `state` before saving, and catches/logs save failures without reverting the in-session value.

- [ ] **Step 4: Verify GREEN and commit**

Run:

```bash
fvm dart format lib/progress test/progress
fvm flutter test test/progress
```

Expected: all progress tests pass.

Commit:

```bash
git add lib/progress test/progress
git commit -m "Move clear progress to Riverpod"
```

---

### Task 3: Implement GameController with deterministic loops

**Files:**
- Create: `lib/game/game_controller.dart`
- Modify: `lib/game/game_providers.dart`
- Create: `test/game/game_controller_test.dart`

**Interfaces:**
- Consumes: `GameState`, `GameLoopFactory`, `RandomSource`, `clearProgressProvider`
- Produces: `GameController`
- Produces: `gameControllerProvider`
- Produces public commands: `selectLevel`, `openHowToPlay`, `closeHowToPlay`, `handleTap`, `retry`, `returnToTop`, `exitClear`

- [ ] **Step 1: Write failing controller transition tests**

Create deterministic fakes:

```dart
class ManualGameLoop implements GameLoop {
  void Function()? callback;
  @override
  bool get isRunning => callback != null;
  @override
  void start(void Function() onTick) => callback = onTick;
  @override
  void stop() => callback = null;
  void tick() => callback?.call();
}

class FixedRandomSource implements RandomSource {
  @override
  double nextDouble() => 0;
  @override
  int nextInt(int max) => 0;
}
```

Test observable behavior:

```dart
test('selectLevel updates difficulty and deterministic UFO positions', () {
  final harness = GameHarness();
  addTearDown(harness.dispose);

  harness.controller.selectLevel(3);

  expect(harness.state.selectedLevel, 3);
  expect(harness.state.level, 5);
  expect(harness.state.ufos.every((ufo) => ufo.direction == HorizontalDirection.left), isTrue);
  expect(harness.state.ufos.every((ufo) => ufo.x == 7.5), isTrue);
});

test('tap on ready starts exactly one game loop', () {
  final harness = GameHarness();
  addTearDown(harness.dispose);
  harness.controller.selectLevel(1);
  harness.controller.handleTap();
  harness.controller.handleTap();

  expect(harness.state.mode, GameMode.playing);
  expect(harness.createdLoops.single.isRunning, isTrue);
});
```

Also cover:

- A playing tap resets time, captures initial height, and enables boost.
- One manual tick preserves the existing gravity formula.
- Ground, goal, UFO, and star collision branches reach the same modes, while meteorites preserve their existing movement/respawn behavior without adding a new collision rule.
- `retry()` resets positions and returns to ready.
- `returnToTop()` resets positions and returns to top.
- `openHowToPlay()` and `closeHowToPlay()` manage only one demo loop.
- `exitClear()` records the selected level and returns to top.
- Disposing the container stops both loops and prevents delayed callbacks.

Name the breaks: changed gameplay formulas, missed collision branches, loop duplication, or post-disposal updates.

- [ ] **Step 2: Run tests and verify RED**

Run:

```bash
fvm flutter test test/game/game_controller_test.dart
```

Expected: compilation failure because `GameController` and `gameControllerProvider` do not exist.

- [ ] **Step 3: Implement controller setup and commands**

Define:

```dart
class GameController extends Notifier<GameState> {
  late final GameLoop _gameLoop;
  late final GameLoop _demoLoop;
  Timer? _boostTimer;
  Timer? _explosionTimer;
  bool _disposed = false;

  @override
  GameState build() {
    final factory = ref.read(gameLoopFactoryProvider);
    _gameLoop = factory();
    _demoLoop = factory();
    ref.onDispose(_disposeResources);
    return GameState.initial();
  }
}

final gameControllerProvider =
    NotifierProvider<GameController, GameState>(GameController.new);
```

Implement the public commands exactly as designed. Do not expose a generic mode setter or a public state mutation method.

- [ ] **Step 4: Port the existing formulas without changing constants**

Port the existing `MainPageModel` behavior into private methods:

```dart
void _startGame();
void _tickGame();
void _tickHowToPlay();
GameState _applyGravity(GameState current);
GameState _resetPositions(GameState current, GameMode targetMode);
void _stopGameLoop();
void _stopDemoLoop();
void _disposeResources();
```

Keep these existing values verbatim:

- Loop interval: 10 ms
- Per-tick `time`: `+0.005`
- Gravity: `-4.5 * time * time + 0.2 + time`
- Background transition: starts after 30,000 ms
- Goal movement: starts after 60,000 ms
- Reset meteorites: `[-3, -2.8, -2.6, -2.3, -2]`
- Reset stars: `[-2, -2.8, -2.6]`
- UFO respawn and collision boundaries from the existing model

Every delayed callback must check `_disposed` and the expected current mode before assigning `state`.

- [ ] **Step 5: Verify GREEN and commit**

Run:

```bash
fvm dart format lib/game test/game
fvm flutter test test/game
```

Expected: all state, loop, and controller tests pass.

Commit:

```bash
git add lib/game test/game
git commit -m "Implement Riverpod game controller"
```

---

### Task 4: Move banner ads behind a disposable Riverpod controller

**Files:**
- Create: `lib/ads/banner_ad_state.dart`
- Create: `lib/ads/banner_ad_gateway.dart`
- Create: `lib/ads/banner_ad_controller.dart`
- Create: `lib/ads/banner_ad_view.dart`
- Create: `lib/ads/ad_providers.dart`
- Create: `test/ads/banner_ad_controller_test.dart`

**Interfaces:**
- Produces: `BannerAdPhase`, `BannerAdState`, `BannerAdResource`
- Produces: `BannerAdGateway.initializeAndLoad(String adUnitId)`
- Produces: `bannerAdGatewayProvider`, `bannerAdsEnabledProvider`, `bannerAdProvider`

- [ ] **Step 1: Write failing banner lifecycle tests**

Create a fake gateway that returns a fake disposable resource and test:

```dart
test('loads one banner for the app session', () async {
  final gateway = FakeBannerAdGateway.success();
  final container = ProviderContainer(
    overrides: [
      bannerAdGatewayProvider.overrideWithValue(gateway),
      bannerAdsEnabledProvider.overrideWithValue(true),
    ],
  );
  addTearDown(container.dispose);

  container.read(bannerAdProvider);
  await gateway.completed;

  expect(container.read(bannerAdProvider).phase, BannerAdPhase.loaded);
  expect(gateway.loadCount, 1);
});

test('disposing the container disposes a loaded banner', () async {
  final gateway = FakeBannerAdGateway.success();
  final container = ProviderContainer(
    overrides: [
      bannerAdGatewayProvider.overrideWithValue(gateway),
      bannerAdsEnabledProvider.overrideWithValue(true),
    ],
  );
  container.read(bannerAdProvider);
  await gateway.completed;

  container.dispose();

  expect(gateway.resource.disposeCount, 1);
});
```

Also cover disabled ads, initialization/load failure resulting in `failed`, no retry, and a late load completion being disposed without updating provider state.

Name the breaks: multiple loads, leaked resources, or a failure that crashes the game.

- [ ] **Step 2: Run tests and verify RED**

Run:

```bash
fvm flutter test test/ads/banner_ad_controller_test.dart
```

Expected: compilation failure because the ad abstractions do not exist.

- [ ] **Step 3: Implement the gateway and state**

Define:

```dart
enum BannerAdPhase { initial, loading, loaded, failed, disabled }

abstract interface class BannerAdResource {
  Widget buildWidget();
  void dispose();
}

abstract interface class BannerAdGateway {
  Future<BannerAdResource> initializeAndLoad(String adUnitId);
}
```

The production gateway must:

- Await `MobileAds.instance.initialize()`.
- Create exactly one `BannerAd`.
- Complete only from `onAdLoaded`.
- Dispose and complete with the load error from `onAdFailedToLoad`.
- Wrap the loaded ad in a `BannerAdResource` whose `buildWidget()` returns `AdWidget(ad: banner)`.

- [ ] **Step 4: Implement the session-scoped controller and view**

`BannerAdController extends Notifier<BannerAdState>` starts one asynchronous load from `build()`. It tracks `_disposed`, disposes a late result, and registers resource cleanup with `ref.onDispose`.

Use existing IDs:

```dart
const androidTestAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const iosTestAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
```

Release reads `BANNER_UNIT_ID_ANDROID` or `BANNER_UNIT_ID_IOS`. `BannerAdView` watches both `GameMode` and `BannerAdState`, hides the banner in clear/ready/playing modes, and renders only a loaded resource.

- [ ] **Step 5: Verify GREEN and commit**

Run:

```bash
fvm dart format lib/ads test/ads
fvm flutter test test/ads
```

Expected: all banner tests pass without initializing the real ad SDK.

Commit:

```bash
git add lib/ads test/ads
git commit -m "Move banner ads to Riverpod"
```

---

### Task 5: Convert the UI and remove Provider

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/mainpage.dart`
- Modify: `lib/mode/top/top.dart`
- Modify: `lib/mode/how/how.dart`
- Modify: `lib/mode/ready/ready.dart`
- Modify: `lib/mode/clear/clear.dart`
- Modify: `lib/mode/game_over/game_over.dart`
- Delete: `lib/mainpage_model.dart`
- Replace: `test/widget_test.dart`
- Create: `test/main_page_flow_test.dart`
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`

**Interfaces:**
- Consumes: all providers from Tasks 1-4
- Produces: `ProviderScope`-rooted application and Consumer-based screens

- [ ] **Step 1: Write failing Riverpod widget-flow tests**

Build the real UI with `ProviderScope` and overrides for deterministic infrastructure, progress, and disabled ads. Cover:

```dart
testWidgets('top selects level 1 and enters ready mode', (tester) async {
  final harness = MainPageHarness(clearLevel: 1);
  await tester.pumpWidget(harness.app);
  await tester.pumpAndSettle();

  expect(find.text('Unlucky Rocket'), findsOneWidget);
  await tester.tap(find.text('1'));
  await tester.pump();

  expect(find.text('L E V E L 1'), findsOneWidget);
  expect(find.text('画面をタップしたらスタートするよ'), findsOneWidget);
});
```

Add separate tests for:

- Ready tap starts playing.
- How-to screen returns to top.
- Game-over retry returns to ready.
- Game-over top action returns to top.
- Clear exit updates progress and returns to top.
- Locked and cleared level indicators use the async progress state.

Name the breaks: any user-visible flow differs from the Provider-managed application.

- [ ] **Step 2: Run tests and verify RED**

Run:

```bash
fvm flutter test test/main_page_flow_test.dart
```

Expected: compilation failure because the current app still expects `ChangeNotifierProvider`.

- [ ] **Step 3: Convert app startup**

Change `main()` to load dotenv and orientation before:

```dart
runApp(const ProviderScope(child: MyApp()));
```

Remove `MobileAds.instance.initialize()` from `main()`. The ad controller owns initialization. Make `MyApp` const where possible.

- [ ] **Step 4: Convert MainPage and preserve stacking**

Make `MainPage` a `ConsumerWidget` that initializes `SizeConfig` and hosts a high-frequency `GameScene`. `GameScene` watches `gameControllerProvider` once and reproduces the existing Stack child order exactly.

Use typed lists for repeated objects:

```dart
for (final ufo in state.ufos)
  Align(alignment: Alignment(ufo.x, ufo.laneY), child: const Ufo()),
```

Keep mode widgets and `BannerAdView` as const children at the same z-order positions as the existing implementation.

- [ ] **Step 5: Convert mode widgets to ConsumerWidget**

Each mode widget:

- Uses `ref.watch(gameControllerProvider.select((state) => state.mode))` and equivalent primitive/enum selections only for fields it displays.
- Invokes `ref.read(gameControllerProvider.notifier)` commands.
- Never receives a controller or state object through its constructor.
- Uses `clearProgressProvider` only in the top-level selector.

The clear EXIT button calls `exitClear()`. Game-over buttons call `retry()` and `returnToTop()` rather than mutating state.

- [ ] **Step 6: Remove Provider and old model**

Delete `lib/mainpage_model.dart`, remove `provider` from `pubspec.yaml`, run `fvm flutter pub get`, and replace the old Provider-based widget test.

Verify absence:

```bash
rg -n "package:provider|MainPageModel|ChangeNotifier|notifyListeners|MultiProvider" lib test pubspec.yaml
```

Expected: no matches.

- [ ] **Step 7: Verify GREEN and commit**

Run:

```bash
fvm dart format lib test
fvm flutter test
fvm flutter analyze
```

Expected: all tests pass and analysis reports no issues.

Commit:

```bash
git add lib test pubspec.yaml pubspec.lock
git commit -m "Migrate UI from Provider to Riverpod"
```

---

### Task 6: Full completion gate

**Files:**
- Modify only files required by a failing completion check.

**Interfaces:**
- Consumes the complete Riverpod application.
- Produces fresh verification evidence for Issue #2 and the pull request.

- [ ] **Step 1: Run repository and migration checks**

```bash
git status --short
rg -n "package:provider|MainPageModel|ChangeNotifier|notifyListeners|MultiProvider" lib test pubspec.yaml
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```

Expected: only intended changes before commit, no forbidden-symbol matches, dependency resolution succeeds, analysis is clean, and all tests pass.

- [ ] **Step 2: Build both supported platforms**

```bash
fvm flutter build apk --debug
fvm flutter build ios --simulator --debug --no-codesign
```

Expected: both commands exit successfully.

- [ ] **Step 3: Perform runtime smoke test**

On an available Android emulator or iOS Simulator, verify:

1. Top screen renders unlocked and locked levels.
2. Level 1 opens Ready and tap starts the game.
3. Rocket moves and obstacles update.
4. How-to opens and returns.
5. Game-over retry and top actions work.
6. Clear exit unlocks the next level.
7. Debug banner loads where the existing app displayed it.

- [ ] **Step 4: Fix only reproduced failures with TDD**

For any failure, add a focused failing test that reproduces it, run the test to verify RED, make the minimal fix, and rerun the focused test plus the full suite.

- [ ] **Step 5: Commit completion-gate fixes if any**

```bash
git add lib test pubspec.yaml pubspec.lock
git commit -m "Fix Riverpod migration regressions"
```

Skip this commit when Step 4 required no source changes.
