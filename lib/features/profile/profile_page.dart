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
  Future<void> _switchPerson(String id) async {
    await StorageService.setActiveProfile(id);
    if (mounted) context.go('/dashboard');
  }

  Future<void> _deletePerson(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('delete')),
        content: Text(context.tr('deletePersonQ')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.tr('delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final wasActive = StorageService.activeProfileId == id;
    final ok = await StorageService.deleteProfile(id);
    if (!mounted || !ok) return;
    if (wasActive) {
      context.go('/dashboard');
    } else {
      setState(() {});
    }
  }

  String _personTitle(Map<String, dynamic> map) {
    final p = UserProfile.fromMap(map);
    if (p.name.trim().isNotEmpty) return p.name.trim();
    final g =
        p.gender == Gender.male ? context.tr('male') : context.tr('female');
    return '$g, ${p.age} ${context.tr('years')}';
  }

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
    final people = StorageService.getProfiles();
    final activeId = StorageService.activeProfileId;

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
          Text(
            context.tr('people'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...people.map((map) {
            final id = map['id']?.toString() ?? '';
            final isActive = id == activeId;
            final p = UserProfile.fromMap(map);
            return Card(
              child: ListTile(
                leading: Icon(
                  isActive ? Icons.person : Icons.person_outline,
                ),
                title: Text(_personTitle(map)),
                subtitle: Text(
                  '${units.fromKg(p.currentWeightKg, unit).toStringAsFixed(1)} ${units.label(unit)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      const Icon(Icons.check_circle, color: Colors.green),
                    if (people.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: context.tr('delete'),
                        onPressed: () => _deletePerson(id),
                      ),
                  ],
                ),
                onTap: isActive ? null : () => _switchPerson(id),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () async {
              await context.push('/profile/add');
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.person_add_outlined),
            label: Text(context.tr('addPerson')),
          ),
          const Divider(height: 32),
          if (profile.name.trim().isNotEmpty)
            _item(context.tr('name'), profile.name.trim()),
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
