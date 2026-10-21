import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_locale.dart';
import '../storage/storage_service.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((_) => LocaleNotifier());
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_read());
  static Locale _read() {
    final saved = StorageService.getLanguage();
    return saved == 'system' ? AppLocale.fromSystem() : Locale(saved);
  }
  Future<void> change(String value) async {
    state = value == 'system' ? AppLocale.fromSystem() : Locale(value);
    await StorageService.saveLanguage(value);
  }
}
