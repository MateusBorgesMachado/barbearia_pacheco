import 'package:flutter/material.dart';

class BarberDatePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.white10,
            highlightColor: Colors.white10,

            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              secondary: Colors.white24,
              onSecondary: Colors.white,
              surface: Color(0xFF141414),
              onSurface: Colors.white,
              tertiary: Colors.white24,
            ),

            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: Color(0xFF141414),
              headerForegroundColor: Colors.white,
              backgroundColor: Color(0xFF0D0D0D),
              dividerColor: Colors.white10,
            ),

            dialogBackgroundColor: const Color(0xFF0D0D0D),
          ),
          child: child!,
        );
      },
    );
  }
}
