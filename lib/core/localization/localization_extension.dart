import 'package:flutter/material.dart';
import 'app_strings.dart';
extension AppText on BuildContext { String tr(String key) => AppStrings.tr(key, Localizations.localeOf(this)); }
