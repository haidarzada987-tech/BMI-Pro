import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_pro/services/goal_service.dart';

void main() {
  const service = GoalService();

  test('weight-loss progress moves toward a lower target', () {
    expect(
      service.progress(start: 80, current: 75, target: 70),
      closeTo(0.5, 0.001),
    );
  });

  test('weight-gain progress moves toward a higher target', () {
    expect(
      service.progress(start: 60, current: 65, target: 70),
      closeTo(0.5, 0.001),
    );
  });
}
