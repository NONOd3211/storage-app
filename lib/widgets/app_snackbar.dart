import 'package:flutter/material.dart';

class AppSnackBar {
  static const Duration defaultDuration = Duration(seconds: 2);

  static void show(
    BuildContext context,
    String message, {
    Duration duration = defaultDuration,
    Color? backgroundColor,
    Color? textColor,
    SnackBarBehavior? behavior,
  }) {
    final resolvedTextColor = textColor ?? _autoTextColorFor(backgroundColor);
    final contentStyle = resolvedTextColor == null
        ? null
        : TextStyle(color: resolvedTextColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: contentStyle),
        duration: duration,
        backgroundColor: backgroundColor,
        behavior: behavior,
      ),
    );
  }

  static Color? _autoTextColorFor(Color? backgroundColor) {
    if (backgroundColor == null) return null;
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }
}
