import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import '../core/localization/app_locale.dart';
import '../core/localization/locale_provider.dart';

class BMIProApp extends ConsumerWidget {
  const BMIProApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeProvider);
    return MaterialApp.router(
      title: 'BMI Pro', debugShowCheckedModeBanner: false,
      theme: AppTheme.light, darkTheme: AppTheme.dark, themeMode: themeMode,
      locale: locale, supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: AppLocale.delegates, routerConfig: appRouter,
    );
  }
}
