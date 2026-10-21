import 'package:hive_flutter/hive_flutter.dart';
import '../../models/weight_entry.dart';

class StorageService {
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox('bmi_pro');
  }

  static Future<void> saveProfile(Map<String, dynamic> value) =>
      _box.put('profile', value);

  static Map<String, dynamic>? getProfile() {
    final value = _box.get('profile');
    if (value == null) return null;
    return Map<String, dynamic>.from(value as Map);
  }

  static Future<void> updateCurrentWeight(double weightKg) async {
    final profile = getProfile();
    if (profile == null) return;
    profile['currentWeightKg'] = weightKg;
    await saveProfile(profile);
  }

  static Future<void> saveStartWeight(double value) =>
      _box.put('startWeight', value);

  static double? getStartWeight() {
    final value = _box.get('startWeight');
    return value is num ? value.toDouble() : null;
  }

  static Future<void> addWeight(double weightKg) async {
    final list = getWeightHistory();
    list.add(
      WeightEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        weightKg: weightKg,
        date: DateTime.now(),
      ),
    );
    await _box.put('weights', list.map((e) => e.toMap()).toList());
  }

  static List<WeightEntry> getWeightHistory() {
    final raw = _box.get('weights', defaultValue: <dynamic>[]);
    if (raw is! List) return [];
    return raw
        .map((e) => WeightEntry.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

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
}
