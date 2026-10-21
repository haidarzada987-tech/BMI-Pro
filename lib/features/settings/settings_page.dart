import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/theme_provider.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/storage/storage_service.dart';
import '../../core/storage/unit_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final selectedLanguage = StorageService.getLanguage();
    final theme = ref.watch(themeProvider);
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
            context.tr('appearance'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.system,
            groupValue: theme,
            title: Text(context.tr('system')),
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).change(value);
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.light,
            groupValue: theme,
            title: Text(context.tr('light')),
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).change(value);
            },
          ),
          RadioListTile<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: theme,
            title: Text(context.tr('dark')),
            onChanged: (value) {
              if (value != null) ref.read(themeProvider.notifier).change(value);
            },
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
          const SizedBox(height: 8),
          Text(
            '${context.tr('appName')} • ${locale.languageCode.toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
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
