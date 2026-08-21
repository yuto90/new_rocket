import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/progress/progress_providers.dart';

class ClearProgressController extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    try {
      return await ref.read(clearProgressRepositoryProvider).load();
    } catch (error) {
      debugPrint('Failed to load clear progress: $error');
      return 1;
    }
  }

  Future<void> completeLevel(int selectedLevel) async {
    final currentLevel = state.requireValue;
    if (currentLevel != selectedLevel) {
      return;
    }

    final nextLevel = selectedLevel + 1;
    state = AsyncData(nextLevel);
    try {
      await ref.read(clearProgressRepositoryProvider).save(nextLevel);
    } catch (error) {
      debugPrint('Failed to save clear progress: $error');
    }
  }
}
