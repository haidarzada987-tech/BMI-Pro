import 'package:flutter_test/flutter_test.dart';
import 'package:bmi_pro/services/bmi_service.dart';
void main(){test('BMI calculation',(){expect(const BMIService().calculate(weightKg:70,heightCm:175),closeTo(22.857,0.01));});}
