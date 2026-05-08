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
  ),
  rose(
    light: Color(0xFFE84393),
    dark: Color(0xFFFD79A8),
  ),
  lime(
    light: Color(0xFF6AB04C),
    dark: Color(0xFF8BC34A),
  ),
  indigo(
    light: Color(0xFF5C6BC0),
    dark: Color(0xFF7986CB),
  ),
  teal(
    light: Color(0xFF00897B),
    dark: Color(0xFF4DB6AC),
  ),
  crimson(
    light: Color(0xFFD32F2F),
    dark: Color(0xFFE57373),
  ),
  violet(
    light: Color(0xFF8E24AA),
    dark: Color(0xFFBA68C8),
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
