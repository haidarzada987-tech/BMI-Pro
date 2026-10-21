import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_pro/models/user_profile.dart';
import 'package:bmi_pro/services/health_service.dart';

void main() {
  const service = HealthService();

  test('BMR uses Mifflin-St Jeor for male', () {
    expect(
      service.bmr(
        gender: Gender.male,
        age: 25,
        weightKg: 70,
        heightCm: 175,
      ),
      closeTo(1648.75, 0.01),
    );
  });

  test('TDEE uses the selected activity multiplier', () {
    expect(
      service.tdee(1600, ActivityLevel.moderatelyActive),
      closeTo(2480, 0.01),
    );
  });
}
