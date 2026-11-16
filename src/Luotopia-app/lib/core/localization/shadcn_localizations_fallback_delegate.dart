// ignore_for_file: implementation_imports

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/src/components/locale/shadcn_localizations.dart';
import 'package:shadcn_flutter/src/components/locale/shadcn_localizations_en.dart';

class ShadcnFallbackLocalizationsDelegate
    extends LocalizationsDelegate<ShadcnLocalizations> {
  const ShadcnFallbackLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'en' || locale.languageCode == 'zh';
  }

  @override
  Future<ShadcnLocalizations> load(Locale locale) {
    final languageCode = locale.languageCode == 'zh' ? 'en' : locale.languageCode;
    return SynchronousFuture(ShadcnLocalizationsEn(languageCode));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<ShadcnLocalizations> old) {
    return false;
  }
}
