import 'package:hive_flutter/hive_flutter.dart';
import '../../models/weight_entry.dart';

class StorageService {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('bmi_pro');
    _migrate();
  }

  // ---------- multi-profile storage (v2) ----------
  // 'profiles' holds a list of profile maps, each with an 'id'.
  // 'activeProfileId' marks the person currently in use.
  // Weights and start weight are stored per person:
  //   'weights_<id>' and 'startWeight_<id>'.

  static String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  static void _migrate() {
    if (_box.get('profiles') != null) return;
    final profiles = <Map<String, dynamic>>[];
    String? activeId;
    final legacy = _box.get('profile');
    if (legacy is Map) {
      final id = 'p${_newId()}';
      final map = Map<String, dynamic>.from(legacy);
      map['id'] = id;
      profiles.add(map);
      activeId = id;
      final weights = _box.get('weights');
      if (weights is List) {
        _box.put('weights_$id', weights);
      }
      final start = _box.get('startWeight');
      if (start is num) {
        _box.put('startWeight_$id', start.toDouble());
      }
    }
    _box.put('profiles', profiles);
    _box.put('activeProfileId', activeId);
  }

  static List<Map<String, dynamic>> _profiles() {
    final raw = _box.get('profiles', defaultValue: <dynamic>[]);
    if (raw is! List) return [];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  static Future<void> _saveProfiles(List<Map<String, dynamic>> list) =>
      _box.put('profiles', list);

  static String? get activeProfileId =>
      _box.get('activeProfileId') as String?;

  static List<Map<String, dynamic>> getProfiles() => _profiles();

  static Future<void> saveProfile(Map<String, dynamic> value) async {
    final profiles = _profiles();
    final id = activeProfileId;
    if (id == null || profiles.isEmpty) {
      final newId = 'p${_newId()}';
      final map = Map<String, dynamic>.from(value);
      map['id'] = newId;
      profiles.add(map);
      await _saveProfiles(profiles);
      await _box.put('activeProfileId', newId);
      return;
    }
    final index = profiles.indexWhere((p) => p['id'] == id);
    final map = Map<String, dynamic>.from(value);
    map['id'] = id;
    if (index >= 0) {
      profiles[index] = map;
    } else {
      profiles.add(map);
    }
    await _saveProfiles(profiles);
  }

  static Map<String, dynamic>? getProfile() {
    final id = activeProfileId;
    if (id == null) return null;
    for (final p in _profiles()) {
      if (p['id'] == id) return p;
    }
    return null;
  }

  static Future<String> addProfile(Map<String, dynamic> value) async {
    final profiles = _profiles();
    final id = 'p${_newId()}';
    final map = Map<String, dynamic>.from(value);
    map['id'] = id;
    profiles.add(map);
    await _saveProfiles(profiles);
    return id;
  }

  static Future<void> setActiveProfile(String id) =>
      _box.put('activeProfileId', id);

  static Future<bool> deleteProfile(String id) async {
    final profiles = _profiles();
    if (profiles.length <= 1) return false;
    profiles.removeWhere((p) => p['id'] == id);
    await _saveProfiles(profiles);
    await _box.delete('weights_$id');
    await _box.delete('startWeight_$id');
    if (activeProfileId == id && profiles.isNotEmpty) {
      await _box.put('activeProfileId', profiles.first['id']);
    }
    return true;
  }

  static Future<void> updateCurrentWeight(double weightKg) async {
    final profile = getProfile();
    if (profile == null) return;
    profile['currentWeightKg'] = weightKg;
    await saveProfile(profile);
  }

  static Future<void> saveStartWeight(double value) {
    final id = activeProfileId;
    if (id == null) return _box.put('startWeight', value);
    return _box.put('startWeight_$id', value);
  }

  static double? getStartWeight() {
    final id = activeProfileId;
    final value =
        id == null ? _box.get('startWeight') : _box.get('startWeight_$id');
    return value is num ? value.toDouble() : null;
  }

  // ---------- weight history (per active person) ----------

  static String get _weightsKey => 'weights_${activeProfileId ?? 'none'}';

  static Future<void> _saveHistory(List<WeightEntry> list) =>
      _box.put(_weightsKey, list.map((e) => e.toMap()).toList());

  static Future<void> addWeight(double weightKg) async {
    final list = getWeightHistory();
    list.add(
      WeightEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        weightKg: weightKg,
        date: DateTime.now(),
      ),
    );
    await _saveHistory(list);
  }

  static List<WeightEntry> getWeightHistory() {
    final raw = _box.get(_weightsKey, defaultValue: <dynamic>[]);
    if (raw is! List) return [];
    return raw
        .map((e) => WeightEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static Future<void> updateWeightEntry(String id, double weightKg) async {
    final list = getWeightHistory();
    final index = list.indexWhere((e) => e.id == id);
    if (index < 0) return;
    list[index] = WeightEntry(
      id: list[index].id,
      weightKg: weightKg,
      date: list[index].date,
    );
    await _saveHistory(list);
  }

  static Future<void> deleteWeightEntry(String id) async {
    final list = getWeightHistory()..removeWhere((e) => e.id == id);
    await _saveHistory(list);
  }

  /// Keeps the profile's current weight in sync with the newest record.
  static Future<void> syncCurrentWeightToLatest() async {
    final list = getWeightHistory();
    if (list.isEmpty) return;
    final latest = list.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    await updateCurrentWeight(latest.weightKg);
  }

  // ---------- app settings ----------

  static Future<void> saveLanguage(String value) =>
      _box.put('language', value);

  static String getLanguage() =>
      _box.get('language', defaultValue: 'system') as String;

  static Future<void> saveTheme(String value) => _box.put('theme', value);

  static String getTheme() =>
      _box.get('theme', defaultValue: 'system') as String;

  static Future<void> saveUnit(String value) => _box.put('unit', value);

  static String getUnit() =>
      _box.get('unit', defaultValue: 'kg') as String;

  static Future<void> saveReminder(bool value) => _box.put('reminder', value);

  static bool getReminder() =>
      _box.get('reminder', defaultValue: false) as bool;

  // ---------- backup: export / import everything as JSON ----------

  static Map<String, dynamic> exportData() {
    final out = <String, dynamic>{};
    for (final key in _box.keys) {
      out[key.toString()] = _jsonSafe(_box.get(key));
    }
    return out;
  }

  static dynamic _jsonSafe(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _jsonSafe(v)));
    }
    if (value is List) return value.map(_jsonSafe).toList();
    return value;
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    await _box.clear();
    for (final entry in data.entries) {
      await _box.put(entry.key, entry.value);
    }
  }
}
