import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl_standalone.dart' as intl;
import 'package:decimal/decimal.dart';
import 'dart:math';
import './translation.dart';
import 'package:flutter/material.dart';


class Helper{
  // 获取本地存储语言 || 系统语言设定默认语言 || 系统中用户的语言列表
  //  （如果是日文，不支持，但是会选择曾经选择过的语言列表中的第一项作为locale）
  static getCurLanguage(BuildContext context) async{
    String languageCode = await Helper.getSetLanguage();
    if (languageCode == '') {
      languageCode = await Helper.getSysLanguage();
    }
    List supportList = applic.supportedLanguages;
    if (supportList.contains(languageCode.toLowerCase())) {
      return languageCode;
    } else { // 系统中用户的语言列表中的被支持的语言中的第一项
      Locale curLocale = Localizations.localeOf(context);
      return curLocale.toString() ?? 'en';
    }
  }

  // 获取系统语言
  static getSysLanguage() async{
    String locale= await intl.findSystemLocale();
    String languageCode = locale.split('_')[0];
    return languageCode.toLowerCase();
  }

  // 获取设置过的语言
  static getSetLanguage() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('language');
    return languageCode == null ? '' : languageCode.toLowerCase();
  }

  // 换算币种的单位，如eth ,接口返回的是最小单位wei，需要换算成eth
  static String convertUnit(String value, int digit) {
    var res = Decimal.parse(value) /
      Decimal.parse(pow(10, digit).toString());
    return res.toString();
  }
}