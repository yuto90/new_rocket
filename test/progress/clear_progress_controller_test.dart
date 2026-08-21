import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:new_rocket/progress/clear_progress_repository.dart';
import 'package:new_rocket/progress/progress_providers.dart';

class FakeClearProgressRepository implements ClearProgressRepository {
  FakeClearProgressRepository({
    required this.initialValue,
    this.shouldFailLoad = false,
    this.shouldFailSave = false,
  });

  final int initialValue;
  final bool shouldFailLoad;
  final bool shouldFailSave;
  final List<int> savedValues = [];

  @override
  Future<int> load() async {
    if (shouldFailLoad) {
      throw StateError('load failed');
    }
    return initialValue;
  }

  @override
  Future<void> save(int value) async {
    if (shouldFailSave) {
      throw StateError('save failed');
    }
    savedValues.add(value);
  }
}

void main() {
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

  test(
    'completing a lower level does not reduce or re-save progress',
    () async {
      final repository = FakeClearProgressRepository(initialValue: 3);
      final container = ProviderContainer(
        overrides: [
          clearProgressRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      await container.read(clearProgressProvider.future);

      await container.read(clearProgressProvider.notifier).completeLevel(2);

      expect(container.read(clearProgressProvider).requireValue, 3);
      expect(repository.savedValues, isEmpty);
    },
  );

  test('completing level 10 stores 11', () async {
    final repository = FakeClearProgressRepository(initialValue: 10);
    final container = ProviderContainer(
      overrides: [
        clearProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(clearProgressProvider.future);

    await container.read(clearProgressProvider.notifier).completeLevel(10);

    expect(container.read(clearProgressProvider).requireValue, 11);
    expect(repository.savedValues, [11]);
  });

  test('a load failure falls back to level 1', () async {
    final repository = FakeClearProgressRepository(
      initialValue: 3,
      shouldFailLoad: true,
    );
    final container = ProviderContainer(
      overrides: [
        clearProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(clearProgressProvider.future), 1);
  });

  test('a save failure keeps the optimistic in-session value', () async {
    final repository = FakeClearProgressRepository(
      initialValue: 3,
      shouldFailSave: true,
    );
    final container = ProviderContainer(
      overrides: [
        clearProgressRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    await container.read(clearProgressProvider.future);

    await container.read(clearProgressProvider.notifier).completeLevel(3);

    expect(container.read(clearProgressProvider).requireValue, 4);
  });
}
