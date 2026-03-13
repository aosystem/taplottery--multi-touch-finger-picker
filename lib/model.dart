import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:taplottery/l10n/app_localizations.dart';

class Model {
  Model._();

  static const String _prefCountdownTime = 'countdownTime';
  static const String _prefResultDisplayDuration = 'resultDisplayDuration';
  static const String _prefSoundVolume = 'soundVolume';
  static const String _prefBackgroundImageNumber = 'backgroundImageNumber';
  static const String _prefBackgroundRotate = 'backgroundRotate';
  static const String _prefThemeNumber = 'themeNumber';
  static const String _prefLanguageCode = 'languageCode';

  static bool _ready = false;
  static int _countdownTime = 5;
  static int _resultDisplayDuration = 5;
  static double _soundVolume = 1.0;
  static int _backgroundImageNumber = 0;
  static bool _backgroundRotate = true;
  static int _themeNumber = 0;
  static String _languageCode = '';

  static int get countdownTime => _countdownTime;
  static int get resultDisplayDuration => _resultDisplayDuration;
  static double get soundVolume => _soundVolume;
  static int get backgroundImageNumber => _backgroundImageNumber;
  static bool get backgroundRotate => _backgroundRotate;
  static int get themeNumber => _themeNumber;
  static String get languageCode => _languageCode;

  static Future<void> ensureReady() async {
    if (_ready) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    _countdownTime = (prefs.getInt(_prefCountdownTime) ?? 5).clamp(1,9);
    _resultDisplayDuration = (prefs.getInt(_prefResultDisplayDuration) ?? 5).clamp(1,9);
    _soundVolume = (prefs.getDouble(_prefSoundVolume) ?? 1.0).clamp(0.0,1.0);
    _backgroundImageNumber = (prefs.getInt(_prefBackgroundImageNumber) ?? 0).clamp(0, 17);
    _backgroundRotate = prefs.getBool(_prefBackgroundRotate) ?? true;
    _themeNumber = (prefs.getInt(_prefThemeNumber) ?? 0).clamp(0, 2);
    _languageCode = prefs.getString(_prefLanguageCode) ?? ui.PlatformDispatcher.instance.locale.languageCode;
    _languageCode = _resolveLanguageCode(_languageCode);
    _ready = true;
  }

  static String _resolveLanguageCode(String code) {
    final supported = AppLocalizations.supportedLocales;
    if (supported.any((l) => l.languageCode == code)) {
      return code;
    } else {
      return '';
    }
  }

  static Future<void> setCountdownTime(int value) async {
    _countdownTime = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefCountdownTime, value);
  }

  static Future<void> setResultDisplayDuration(int value) async {
    _resultDisplayDuration = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefResultDisplayDuration, value);
  }

  static Future<void> setSoundVolume(double value) async {
    _soundVolume = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefSoundVolume, value);
  }

  static Future<void> setBackgroundImageNumber(int value) async {
    _backgroundImageNumber = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefBackgroundImageNumber, value);
  }

  static Future<void> setBackgroundRotate(bool value) async {
    _backgroundRotate = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefBackgroundRotate, value);
  }

  static Future<void> setThemeNumber(int value) async {
    _themeNumber = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefThemeNumber, value);
  }

  static Future<void> setLanguageCode(String value) async {
    _languageCode = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageCode, value);
  }

}
