import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


class CupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const CupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh', 'ko'].contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture<_DefaultCupertinoLocalizations>(
      _DefaultCupertinoLocalizations(locale.languageCode)
    );
  }

  @override
  bool shouldReload(CupertinoLocalizationsDelegate old) => false;
}

class _DefaultCupertinoLocalizations extends CupertinoLocalizations {
  final _en = DefaultCupertinoLocalizations();
  final materialDelegate = GlobalMaterialLocalizations.delegate;
  String _languageCode;
  MaterialLocalizations ml;


  static Map<String, Map<String, String>> _dict = {
    'zh': {
      'hour': '时'
    },
    'ko': {

    }
  };

  _DefaultCupertinoLocalizations(String languageCode) {
    this._languageCode = languageCode;
    _setLocale(languageCode);
  }

  _setLocale(String languageCode) async{
    Locale locale = Locale(languageCode);
    ml = await materialDelegate.load(locale);
  }

  @override
  String get alertDialogLabel => ml.alertDialogLabel;

  @override
  String get anteMeridiemAbbreviation => ml.anteMeridiemAbbreviation;

  @override
  String get postMeridiemAbbreviation => ml.postMeridiemAbbreviation;

  @override
  String get copyButtonLabel => ml.copyButtonLabel;

  @override
  String get cutButtonLabel => ml.cutButtonLabel;

  @override
  String get pasteButtonLabel => ml.pasteButtonLabel;

  @override
  String get selectAllButtonLabel => ml.selectAllButtonLabel;

  @override
  DatePickerDateOrder get datePickerDateOrder => _en.datePickerDateOrder;

  @override
  DatePickerDateTimeOrder get datePickerDateTimeOrder => _en.datePickerDateTimeOrder;

  @override
  String datePickerDayOfMonth(int dayIndex) => _en.datePickerDayOfMonth(dayIndex);

  @override
  String datePickerHour(int hour) => _en.datePickerHour(hour);

  @override
  String datePickerHourSemanticsLabel(int hour) => _en.datePickerHourSemanticsLabel(hour);

  @override
  String datePickerMediumDate(DateTime date) => _en.datePickerMediumDate(date);

  @override
  String datePickerMinute(int minute) => _en.datePickerMinute(minute);

  @override
  String datePickerMinuteSemanticsLabel(int minute) => _en.datePickerMinuteSemanticsLabel(minute);

  @override
  String datePickerMonth(int monthIndex) => _en.datePickerMonth(monthIndex);

  @override
  String datePickerYear(int yearIndex) => _en.datePickerYear(yearIndex);

  @override
  String timerPickerHour(int hour) => _en.timerPickerHour(hour);

  @override
  String timerPickerHourLabel(int hour) => _en.timerPickerHourLabel(hour);

  @override
  String timerPickerMinute(int minute) => _en.timerPickerMinute(minute);

  @override
  String timerPickerMinuteLabel(int minute) => _en.timerPickerMinuteLabel(minute);

  @override
  String timerPickerSecond(int second) => _en.timerPickerSecond(second);

  @override
  String timerPickerSecondLabel(int second) => _en.timerPickerSecondLabel(second);

  String _get(String key) {
    return _dict[_languageCode][key];
  }
}