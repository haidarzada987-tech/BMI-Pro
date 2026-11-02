import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/localization/app_strings.dart';
import 'core/services/notification_service.dart';
import 'core/storage/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await NotificationService.init();
  // Keep the weekly reminder alive across restarts, in the current language.
  if (StorageService.getReminder()) {
    final saved = StorageService.getLanguage();
    final locale = saved == 'system'
        ? WidgetsBinding.instance.platformDispatcher.locale
        : Locale(saved);
    await NotificationService.setWeeklyReminder(
      true,
      title: AppStrings.tr('reminderTitle', locale),
      body: AppStrings.tr('reminderBody', locale),
    );
  }
  runApp(const ProviderScope(child: BMIProApp()));
}
