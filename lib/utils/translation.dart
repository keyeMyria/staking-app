import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show  rootBundle;

typedef void LocaleChangeCallback(Locale locale);
class APPLIC {
  // 支持的语言列表
  final List<String> supportedLanguages = ['en','zh', 'ko'];

  // 支持的Locales列表
  Iterable<Locale> supportedLocales() => supportedLanguages.map<Locale>((lang) => new Locale(lang, ''));

  // 当语言改变时调用的方法
  LocaleChangeCallback onLocaleChanged;

  ///
  /// Internals
  ///
  static final APPLIC _applic = new APPLIC._internal();

  factory APPLIC(){
    return _applic;
  }

  APPLIC._internal();
}
APPLIC applic = new APPLIC();


class Translations {
  Translations(Locale locale) {
    this.locale = locale;
//    _localizedValues = null;
  }

  Locale locale;
  static Map<dynamic, dynamic> _localizedValues;

  static Translations of(BuildContext context){
    return Localizations.of<Translations>(context, Translations);
  }

  String text(String key) {
    var result = _localizedValues;
    List keyList = key.split('.');
    for (int i = 0; i < keyList.length; i ++) {
      if (result[keyList[i]] != null) {
        if (result[keyList[i]] is String){
          return result[keyList[i]];
        } else {
          result = result[keyList[i]];
        }
      }
    }
    return key;
  }

  static Future<Translations> load(Locale locale) async {
    Translations translations = new Translations(locale);
    String jsonContent = await rootBundle.loadString("assets/flutter_i18n/${locale.languageCode}.json");
    _localizedValues = json.decode(jsonContent);
    return translations;
  }

  get currentLanguage => locale.languageCode;
}


class TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const TranslationsDelegate();

  /// 改这里是为了不硬编码支持的语言
  @override
  bool isSupported(Locale locale) => applic.supportedLanguages.contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) => Translations.load(locale);

  @override
  bool shouldReload(TranslationsDelegate old) => false;
}


/// Delegate类的实现，每次选择一种新的语言时，强制初始化一个新的Translations类
class SpecificLocalizationDelegate extends LocalizationsDelegate<Translations> {
  final Locale overriddenLocale;

  const SpecificLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<Translations> load(Locale locale) => Translations.load(overriddenLocale);

  @override
  bool shouldReload(LocalizationsDelegate<Translations> old) => true;
}