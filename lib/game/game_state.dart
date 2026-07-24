import 'package:flutter/foundation.dart';

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

  UfoState copyWith({double? x, HorizontalDirection? direction}) {
    return UfoState(
      laneY: laneY,
      x: x ?? this.x,
      direction: direction ?? this.direction,
      collisionStart: collisionStart,
      collisionEnd: collisionEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UfoState &&
      laneY == other.laneY &&
      x == other.x &&
      direction == other.direction &&
      collisionStart == other.collisionStart &&
      collisionEnd == other.collisionEnd;

  @override
  int get hashCode =>
      Object.hash(laneY, x, direction, collisionStart, collisionEnd);
}

@immutable
class GameState {
  GameState({
    required this.mode,
    required this.selectedLevel,
    required this.level,
    required this.rocketY,
    required this.time,
    required this.height,
    required this.initialHeight,
    required this.gameHasStarted,
    required List<UfoState> ufos,
    required List<double> cloudYs,
    required List<double> meteoriteYs,
    required List<double> starYs,
    required this.cityY,
    required this.spaceHeight,
    required this.spaceStop,
    required this.goalY,
    required this.elapsedMilliseconds,
    required this.boost,
    required this.explosion,
  }) : ufos = List.unmodifiable(ufos),
       cloudYs = List.unmodifiable(cloudYs),
       meteoriteYs = List.unmodifiable(meteoriteYs),
       starYs = List.unmodifiable(starYs);

  factory GameState.initial() {
    return GameState(
      mode: GameMode.top,
      selectedLevel: 1,
      level: 1,
      rocketY: 0,
      time: 0,
      height: 0,
      initialHeight: 0,
      gameHasStarted: false,
      ufos: const [
        UfoState(
          laneY: -1,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: -0.9,
          collisionEnd: -1.1,
        ),
        UfoState(
          laneY: -0.75,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: -0.65,
          collisionEnd: -0.85,
        ),
        UfoState(
          laneY: -0.5,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: -0.4,
          collisionEnd: -0.6,
        ),
        UfoState(
          laneY: -0.25,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: -0.15,
          collisionEnd: -0.35,
        ),
        UfoState(
          laneY: 0,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: 0.1,
          collisionEnd: -0.1,
        ),
        UfoState(
          laneY: 0.25,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: 0.35,
          collisionEnd: 0.15,
        ),
        UfoState(
          laneY: 0.5,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: 0.6,
          collisionEnd: 0.4,
        ),
        UfoState(
          laneY: 0.75,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: 0.65,
          collisionEnd: 0.85,
        ),
        UfoState(
          laneY: 1,
          x: 2,
          direction: HorizontalDirection.left,
          collisionStart: 0.9,
          collisionEnd: 1.1,
        ),
      ],
      cloudYs: const [-1.0, -0.8, -0.6],
      meteoriteYs: const [-3.0, -2.8, -2.6, -2.3, -2.0],
      starYs: const [-2.0, -2.5, -3.0],
      cityY: 1.1,
      spaceHeight: 0,
      spaceStop: 0,
      goalY: -3,
      elapsedMilliseconds: 0,
      boost: false,
      explosion: false,
    );
  }

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

  GameState copyWith({
    GameMode? mode,
    int? selectedLevel,
    double? level,
    double? rocketY,
    double? time,
    double? height,
    double? initialHeight,
    bool? gameHasStarted,
    List<UfoState>? ufos,
    List<double>? cloudYs,
    List<double>? meteoriteYs,
    List<double>? starYs,
    double? cityY,
    double? spaceHeight,
    double? spaceStop,
    double? goalY,
    int? elapsedMilliseconds,
    bool? boost,
    bool? explosion,
  }) {
    return GameState(
      mode: mode ?? this.mode,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      level: level ?? this.level,
      rocketY: rocketY ?? this.rocketY,
      time: time ?? this.time,
      height: height ?? this.height,
      initialHeight: initialHeight ?? this.initialHeight,
      gameHasStarted: gameHasStarted ?? this.gameHasStarted,
      ufos: ufos ?? this.ufos,
      cloudYs: cloudYs ?? this.cloudYs,
      meteoriteYs: meteoriteYs ?? this.meteoriteYs,
      starYs: starYs ?? this.starYs,
      cityY: cityY ?? this.cityY,
      spaceHeight: spaceHeight ?? this.spaceHeight,
      spaceStop: spaceStop ?? this.spaceStop,
      goalY: goalY ?? this.goalY,
      elapsedMilliseconds: elapsedMilliseconds ?? this.elapsedMilliseconds,
      boost: boost ?? this.boost,
      explosion: explosion ?? this.explosion,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GameState &&
      mode == other.mode &&
      selectedLevel == other.selectedLevel &&
      level == other.level &&
      rocketY == other.rocketY &&
      time == other.time &&
      height == other.height &&
      initialHeight == other.initialHeight &&
      gameHasStarted == other.gameHasStarted &&
      listEquals(ufos, other.ufos) &&
      listEquals(cloudYs, other.cloudYs) &&
      listEquals(meteoriteYs, other.meteoriteYs) &&
      listEquals(starYs, other.starYs) &&
      cityY == other.cityY &&
      spaceHeight == other.spaceHeight &&
      spaceStop == other.spaceStop &&
      goalY == other.goalY &&
      elapsedMilliseconds == other.elapsedMilliseconds &&
      boost == other.boost &&
      explosion == other.explosion;

  @override
  int get hashCode => Object.hash(
    mode,
    selectedLevel,
    level,
    rocketY,
    time,
    height,
    initialHeight,
    gameHasStarted,
    Object.hashAll(ufos),
    Object.hashAll(cloudYs),
    Object.hashAll(meteoriteYs),
    Object.hashAll(starYs),
    cityY,
    spaceHeight,
    spaceStop,
    goalY,
    elapsedMilliseconds,
    boost,
    explosion,
  );
}
