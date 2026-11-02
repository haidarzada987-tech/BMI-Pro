import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/storage/storage_service.dart';
import '../../models/user_profile.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController name, age, height, weight, target;
  late Gender gender;
  late ActivityLevel activity;
  String? error;

  @override
  void initState() {
    super.initState();
    final profile = UserProfile.fromMap(StorageService.getProfile()!);
    name = TextEditingController(text: profile.name);
    age = TextEditingController(text: '${profile.age}');
    height = TextEditingController(text: '${profile.heightCm}');
    weight = TextEditingController(text: '${profile.currentWeightKg}');
    target = TextEditingController(text: '${profile.targetWeightKg}');
    gender = profile.gender;
    activity = profile.activityLevel;
  }

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
    final old = UserProfile.fromMap(StorageService.getProfile()!);
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

    if ((weightValue - old.currentWeightKg).abs() > 0.001) {
      await StorageService.addWeight(weightValue);
    }
    await StorageService.saveProfile(profile.toMap());
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('editProfile'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(context.tr(value.name)),
                    ))
                .toList(),
            onChanged: (value) => setState(() => activity = value ?? activity),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: save,
            child: Text(context.tr('saveChanges')),
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
