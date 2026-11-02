import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => _base(
        brightness: Brightness.light,
        seed: const Color(0xFF356859),
        scaffold: const Color(0xFFF7F7F4),
      );

  static ThemeData get dark => _base(
        brightness: Brightness.dark,
        seed: const Color(0xFF6FAF9C),
        scaffold: const Color(0xFF151817),
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color seed,
    required Color scaffold,
  }) {
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorSchemeSeed: seed,
      scaffoldBackgroundColor: scaffold,
      cardTheme: CardThemeData(
        shape: cardShape,
        clipBehavior: Clip.antiAlias,
        elevation: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: buttonShape),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: buttonShape),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: buttonShape),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      listTileTheme: ListTileThemeData(shape: cardShape),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
