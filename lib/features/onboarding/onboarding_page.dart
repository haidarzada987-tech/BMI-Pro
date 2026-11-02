import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/storage/storage_service.dart';
import '../../models/user_profile.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final name = TextEditingController();
  final age = TextEditingController(text: '25');
  final height = TextEditingController(text: '175');
  final weight = TextEditingController(text: '70');
  final target = TextEditingController(text: '65');

  Gender gender = Gender.male;
  ActivityLevel activity = ActivityLevel.moderatelyActive;
  String? error;

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    height.dispose();
    weight.dispose();
    target.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final ageValue = int.tryParse(age.text.trim());
    final heightValue = double.tryParse(height.text.trim());
    final weightValue = double.tryParse(weight.text.trim());
    final targetValue = double.tryParse(target.text.trim());

    if (ageValue == null ||
        ageValue < 13 ||
        ageValue > 120 ||
        heightValue == null ||
        heightValue < 80 ||
        heightValue > 250 ||
        weightValue == null ||
        weightValue <= 0 ||
        targetValue == null ||
        targetValue <= 0) {
      setState(() => error = 'Please enter valid values.');
      return;
    }

    final profile = UserProfile(
      name: name.text.trim(),
      gender: gender,
      age: ageValue,
      heightCm: heightValue,
      currentWeightKg: weightValue,
      targetWeightKg: targetValue,
      activityLevel: activity,
    );

    await StorageService.saveProfile(profile.toMap());
    await StorageService.saveStartWeight(profile.currentWeightKg);
    await StorageService.addWeight(profile.currentWeightKg);

    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('appName'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.tr('createProfile'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(context.tr('profileIntro')),
          const SizedBox(height: 24),
          TextField(
            controller: name,
            decoration: InputDecoration(labelText: context.tr('name')),
          ),
          const SizedBox(height: 14),
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
          _field(age, context.tr('age')),
          _field(height, '${context.tr('height')} (cm)'),
          _field(weight, '${context.tr('currentWeight')} (kg)'),
          _field(target, '${context.tr('targetWeight')} (kg)'),
          const SizedBox(height: 14),
          DropdownButtonFormField<ActivityLevel>(
            value: activity,
            decoration:
                InputDecoration(labelText: context.tr('activityLevel')),
            items: ActivityLevel.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(context.tr(value.name)),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => activity = value ?? activity),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: save,
              child: Text(context.tr('getStarted')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: TextField(
        controller: controller,
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
