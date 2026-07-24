import 'dart:async';

abstract interface class GameLoop {
  bool get isRunning;
  void start(void Function() onTick);
  void stop();
}

class TimerGameLoop implements GameLoop {
  TimerGameLoop(this.interval);

  final Duration interval;
  Timer? _timer;

  @override
  bool get isRunning => _timer?.isActive ?? false;

  @override
  void start(void Function() onTick) {
    stop();
    _timer = Timer.periodic(interval, (_) => onTick());
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}

typedef GameLoopFactory = GameLoop Function();
