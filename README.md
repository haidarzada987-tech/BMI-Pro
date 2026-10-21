# BMI Pro — Clean Foundation

A local-first Flutter/Dart BMI and wellness tracker prepared for continued development on a desktop.

## What is included

- Flutter + Dart application structure
- Local-only user profile and weight history using Hive
- BMI calculation and category
- BMR and TDEE estimation
- Weight goal progress
- Weight history with chart
- Profile editing
- Metric/imperial weight display and input (kg/lb; data remains stored in kg)
- Light, dark, and system themes
- English, فارسی/دری, العربية, Türkçe, Français, Español, Deutsch
- RTL support for فارسی/دری and العربية
- Character selection logic for sex, age group, and BMI range
- Character asset folders ready for project-owner PNGs
- Basic BMI unit test
- No backend, account system, cloud sync, or external image URLs

## Character assets

Add these PNG files:

assets/characters/male/young/{slim,normal,plus,heavy}.png
assets/characters/male/adult/{slim,normal,plus,heavy}.png
assets/characters/male/senior/{slim,normal,plus,heavy}.png
assets/characters/female/young/{slim,normal,plus,heavy}.png
assets/characters/female/adult/{slim,normal,plus,heavy}.png
assets/characters/female/senior/{slim,normal,plus,heavy}.png

The app has an `errorBuilder` fallback, so missing character PNGs do not crash the dashboard.

## Data model

All health values are stored locally on the device. Weight is stored internally in kilograms; lb is a presentation/input unit and is converted to kg before storage.

## Run on a computer

From the project root:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

For Android:

```bash
flutter run
```

or build an APK:

```bash
flutter build apk --release
```

## Important product boundary

This package is the clean application foundation, not a medical diagnostic system. BMI is a screening metric and should not be presented as a diagnosis. Any health guidance added later should be reviewed before production release.

## Current architecture

lib/
- app/ — app shell, router, theme
- core/ — local storage and localization
- features/ — onboarding, dashboard, calculator, progress, profile, settings
- models/ — persistent data models
- services/ — BMI, health, goals, units, character selection

No backend is required for this foundation.
