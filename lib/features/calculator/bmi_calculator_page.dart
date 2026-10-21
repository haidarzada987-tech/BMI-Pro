import 'package:flutter/material.dart';
import '../../core/localization/localization_extension.dart';
import '../../models/user_profile.dart';
import '../../services/bmi_service.dart';
import '../../services/health_service.dart';
import '../../services/unit_service.dart';
import '../../core/storage/storage_service.dart';

class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final height = TextEditingController();
  final weight = TextEditingController();
  final age = TextEditingController(text: '25');

  Gender gender = Gender.male;
  ActivityLevel activity = ActivityLevel.moderatelyActive;
  double? bmi;
  double? energy;
  String? error;

  void calculate() {
    final h = double.tryParse(height.text.trim());
    final wInput = double.tryParse(weight.text.trim());
    final unit = StorageService.getUnit();
    final w = wInput == null ? null : const UnitService().toKg(wInput, unit);
    final a = int.tryParse(age.text.trim());

    if (h == null || w == null || a == null ||
        h <= 0 || w <= 0 || a < 13 || a > 120) {
      setState(() => error = 'Please enter valid values.');
      return;
    }

    final bmiValue =
        const BMIService().calculate(weightKg: w, heightCm: h);
    final health = const HealthService();
    final bmr = health.bmr(
      gender: gender,
      age: a,
      weightKg: w,
      heightCm: h,
    );

    setState(() {
      bmi = bmiValue;
      energy = health.tdee(bmr, activity);
      error = null;
    });
  }

  @override
  void dispose() {
    height.dispose();
    weight.dispose();
    age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('calculator'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(height, '${context.tr('height')} (cm)'),
          _field(weight, '${context.tr('currentWeight')} (${const UnitService().label(StorageService.getUnit())})'),
          _field(age, context.tr('age')),
          DropdownButtonFormField<Gender>(
            value: gender,
            decoration: InputDecoration(labelText: context.tr('gender')),
            items: [
              DropdownMenuItem(
                value: Gender.male,
                child: Text(context.tr('male')),
              ),
              DropdownMenuItem(
                value: Gender.female,
                child: Text(context.tr('female')),
              ),
            ],
            onChanged: (value) => setState(() => gender = value ?? gender),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<ActivityLevel>(
            value: activity,
            decoration:
                InputDecoration(labelText: context.tr('activityLevel')),
            items: ActivityLevel.values
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(context.tr(value.name)),
                    ))
                .toList(),
            onChanged: (value) => setState(() => activity = value ?? activity),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: calculate,
            child: Text(context.tr('calculate')),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (bmi != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(context.tr('result')),
                    Text(
                      bmi!.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(context.tr(const BMIService().category(bmi!))),
                    const SizedBox(height: 8),
                    Text(
                      '${context.tr('dailyEnergy')}: ${energy!.round()} kcal',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
