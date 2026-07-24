import 'package:shared_preferences/shared_preferences.dart';

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
