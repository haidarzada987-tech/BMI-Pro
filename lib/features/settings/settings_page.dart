import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/services/notification_service.dart';
import '../../core/storage/storage_service.dart';
import '../../core/storage/unit_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final selectedLanguage = StorageService.getLanguage();
    final unit = ref.watch(unitProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            context.tr('language'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ...['system', 'en', 'fa', 'ar', 'tr', 'fr', 'es', 'de'].map(
            (value) => RadioListTile<String>(
              value: value,
              groupValue: selectedLanguage,
              title: Text(_languageName(value, context)),
              onChanged: (next) {
                if (next != null) {
                  ref.read(localeProvider.notifier).change(next);
                }
              },
            ),
          ),
          const Divider(height: 30),
          Text(
            context.tr('unit'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          RadioListTile<String>(
            value: 'kg',
            groupValue: unit,
            title: Text(context.tr('kilograms')),
            onChanged: (value) async {
              if (value != null) await ref.read(unitProvider.notifier).change(value);
            },
          ),
          RadioListTile<String>(
            value: 'lb',
            groupValue: unit,
            title: Text(context.tr('pounds')),
            onChanged: (value) async {
              if (value != null) await ref.read(unitProvider.notifier).change(value);
            },
          ),
          const Divider(height: 30),
          const _ReminderTile(),
          const Divider(height: 30),
          Text(
            context.tr('dataSection'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(context.tr('exportBackup')),
            onTap: () async {
              final json = jsonEncode(StorageService.exportData());
              await Share.shareXFiles(
                [
                  XFile.fromData(
                    utf8.encode(json),
                    name: 'bmi_pro_backup.json',
                    mimeType: 'application/json',
                  ),
                ],
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: Text(context.tr('importBackup')),
            onTap: () => _importBackup(context),
          ),
          const SizedBox(height: 8),
          Text(
            '${context.tr('appName')} • v1.2.2 • ${locale.languageCode.toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _importBackup(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      final bytes = result?.files.single.bytes;
      if (bytes == null) return;
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is! Map) throw const FormatException('not a backup');
      await StorageService.importData(
        decoded.map((k, v) => MapEntry(k.toString(), v)),
      );
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(context.tr('importDone')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.tr('save')),
            ),
          ],
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('importFailed'))),
      );
    }
  }

  String _languageName(String value, BuildContext context) => switch (value) {
        'system' => context.tr('system'),
        'en' => 'English',
        'fa' => 'فارسی / دری',
        'ar' => 'العربية',
        'tr' => 'Türkçe',
        'fr' => 'Français',
        'es' => 'Español',
        'de' => 'Deutsch',
        _ => value,
      };
}

/// Weekly weigh-in reminder switch (Fridays, 09:00).
class _ReminderTile extends StatefulWidget {
  const _ReminderTile();

  @override
  State<_ReminderTile> createState() => _ReminderTileState();
}

class _ReminderTileState extends State<_ReminderTile> {
  bool _on = StorageService.getReminder();

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: const Icon(Icons.notifications_outlined),
      title: Text(context.tr('weeklyReminder')),
      subtitle: Text(context.tr('weeklyReminderSub')),
      value: _on,
      onChanged: (value) async {
        setState(() => _on = value);
        await StorageService.saveReminder(value);
        await NotificationService.setWeeklyReminder(
          value,
          title: context.tr('reminderTitle'),
          body: context.tr('reminderBody'),
        );
      },
    );
  }
}
