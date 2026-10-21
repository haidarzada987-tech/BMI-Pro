import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocale {
  static const supportedLocales = [
    Locale('en'), Locale('fa'), Locale('ar'), Locale('tr'), Locale('fr'), Locale('es'), Locale('de'),
  ];
  static const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  static bool rtl(Locale locale) => {'fa', 'ar'}.contains(locale.languageCode);
  static Locale fromSystem() {
    final l = WidgetsBinding.instance.platformDispatcher.locale;
    return supportedLocales.firstWhere((x) => x.languageCode == l.languageCode, orElse: () => const Locale('en'));
  }
}
