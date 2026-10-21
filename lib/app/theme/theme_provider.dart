import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/storage_service.dart';
final themeProvider=StateNotifierProvider<ThemeNotifier,ThemeMode>((_)=>ThemeNotifier());
class ThemeNotifier extends StateNotifier<ThemeMode>{ThemeNotifier():super(_read());static ThemeMode _read(){switch(StorageService.getTheme()){case 'light':return ThemeMode.light;case 'dark':return ThemeMode.dark;default:return ThemeMode.system;}}Future<void> change(ThemeMode v)async{state=v;await StorageService.saveTheme(v.name);}}
