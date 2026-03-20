import 'package:flutter/material.dart';

enum ItemColorOption {
  sky(
    light: Color(0xFF4DA3FF),
    dark: Color(0xFF7AB8FF),
  ),
  jade(
    light: Color(0xFF2FA572),
    dark: Color(0xFF59C98F),
  ),
  amber(
    light: Color(0xFFF4B400),
    dark: Color(0xFFF8C84B),
  ),
  coral(
    light: Color(0xFFEF6C57),
    dark: Color(0xFFF38C7C),
  ),
  orchid(
    light: Color(0xFFB26AF3),
    dark: Color(0xFFCA98FF),
  ),
  slate(
    light: Color(0xFF607D8B),
    dark: Color(0xFF90A4AE),
  );

  const ItemColorOption({
    required this.light,
    required this.dark,
  });

  final Color light;
  final Color dark;

  Color resolve(Brightness brightness) {
    return brightness == Brightness.dark ? dark : light;
  }
}
