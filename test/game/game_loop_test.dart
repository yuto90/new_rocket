import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/game/game_loop.dart';

void main() {
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
}
