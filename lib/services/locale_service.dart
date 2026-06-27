import 'package:flutter/material.dart';

class LocaleService {
  static Future<void> Function(Locale)? _callback;

  static void register(Future<void> Function(Locale) callback) {
    _callback = callback;
  }

  static Future<void> setLocale(Locale locale) async {
    await _callback?.call(locale);
  }
}
