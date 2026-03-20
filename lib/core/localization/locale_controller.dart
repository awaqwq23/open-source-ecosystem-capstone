import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale {
  english(Locale('en')),
  chinese(Locale('zh'));

  const AppLocale(this.locale);

  final Locale locale;

  static List<Locale> get supportedLocales {
    return AppLocale.values.map((item) => item.locale).toList(growable: false);
  }
}

final appLocaleProvider = StateProvider<Locale>((ref) {
  return AppLocale.chinese.locale;
});
