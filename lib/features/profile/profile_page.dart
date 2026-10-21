import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/storage/storage_service.dart';
import '../../models/user_profile.dart';
import '../../services/unit_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final raw = StorageService.getProfile();
    if (raw == null) {
      return Scaffold(
        body: Center(child: Text(context.tr('profile'))),
      );
    }

    final profile = UserProfile.fromMap(raw);
    final unit = StorageService.getUnit();
    final units = const UnitService();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('profile')),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await context.push('/profile/edit');
              if (result == true && mounted) setState(() {});
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _item(
            context.tr('gender'),
            profile.gender == Gender.male
                ? context.tr('male')
                : context.tr('female'),
          ),
          _item(
            context.tr('age'),
            '${profile.age} ${context.tr('years')}',
          ),
          _item(
            context.tr('height'),
            '${profile.heightCm.toStringAsFixed(1)} cm',
          ),
          _item(
            context.tr('currentWeight'),
            '${units.fromKg(profile.currentWeightKg, unit).toStringAsFixed(1)} ${units.label(unit)}',
          ),
          _item(
            context.tr('targetWeight'),
            '${units.fromKg(profile.targetWeightKg, unit).toStringAsFixed(1)} ${units.label(unit)}',
          ),
          _item(
            context.tr('activityLevel'),
            context.tr(profile.activityLevel.name),
          ),
        ],
      ),
    );
  }

  Widget _item(String title, String value) => Card(
        child: ListTile(
          title: Text(title),
          trailing: Text(value),
        ),
      );
}
