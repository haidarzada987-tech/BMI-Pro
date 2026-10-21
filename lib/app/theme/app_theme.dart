import 'package:flutter/material.dart';
class AppTheme {
  static ThemeData get light => ThemeData(useMaterial3:true,brightness:Brightness.light,colorSchemeSeed:const Color(0xFF356859),scaffoldBackgroundColor:const Color(0xFFF7F7F4),inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder()));
  static ThemeData get dark => ThemeData(useMaterial3:true,brightness:Brightness.dark,colorSchemeSeed:const Color(0xFF6FAF9C),scaffoldBackgroundColor:const Color(0xFF151817),inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder()));
}
