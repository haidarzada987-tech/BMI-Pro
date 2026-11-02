enum Gender { male, female }

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive,
}

class UserProfile {
  final String name;
  final Gender gender;
  final int age;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final ActivityLevel activityLevel;

  const UserProfile({
    this.name = '',
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.activityLevel,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'gender': gender.name,
        'age': age,
        'heightCm': heightCm,
        'currentWeightKg': currentWeightKg,
        'targetWeightKg': targetWeightKg,
        'activityLevel': activityLevel.name,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final activityName = map['activityLevel']?.toString();
    return UserProfile(
      name: map['name']?.toString() ?? '',
      gender: map['gender'] == 'female' ? Gender.female : Gender.male,
      age: (map['age'] as num).toInt(),
      heightCm: (map['heightCm'] as num).toDouble(),
      currentWeightKg: (map['currentWeightKg'] as num).toDouble(),
      targetWeightKg: (map['targetWeightKg'] as num).toDouble(),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == activityName,
        orElse: () => ActivityLevel.moderatelyActive,
      ),
    );
  }
}
