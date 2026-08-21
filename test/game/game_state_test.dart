import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/game/game_state.dart';

void main() {
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
}
