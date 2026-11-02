import 'package:flutter_test/flutter_test.dart';

import 'package:bmi_pro/services/bmi_service.dart';

void main() {
  test('BMI calculation and category boundaries', () {
    const service = BMIService();

    final bmi = service.calculate(weightKg: 70, heightCm: 175);
    expect(bmi, closeTo(22.86, 0.01));
    expect(service.category(bmi), 'healthy');

    expect(service.category(17.0), 'underweight');
    expect(service.category(22.0), 'healthy');
    expect(service.category(27.0), 'overweight');
    expect(service.category(32.0), 'obesity');
  });
}
