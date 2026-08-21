import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:new_rocket/progress/clear_progress_controller.dart';
import 'package:new_rocket/progress/clear_progress_repository.dart';

final clearProgressRepositoryProvider = Provider<ClearProgressRepository>(
  (ref) => SharedPreferencesClearProgressRepository(),
);

final clearProgressProvider =
    AsyncNotifierProvider<ClearProgressController, int>(
      ClearProgressController.new,
    );
