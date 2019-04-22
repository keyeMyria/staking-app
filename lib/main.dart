import 'package:flutter/material.dart';
import 'pages/tabs/home.dart';
import 'pages/wallet/transfer.dart';
import 'pages/wallet/transferList.dart';
import 'pages/wallet/transferDetail.dart';
import 'pages/receipt.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/setPassword.dart';
import 'pages/changePassword.dart';
import 'pages/user/privacy.dart';
import 'pages/user/termsService.dart';
import 'pages/user/privacyPolicy.dart';
import 'pages/user/managementAgreement.dart';
import 'pages/user/switchLanguage.dart';
import 'pages/financial/buyFinancial.dart';
import 'pages/financial/financialHistory.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './utils/helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './utils/translation.dart';
import 'package:flutter/services.dart';
import './utils/cupertinoLocalizationsDelegate.dart';


void main() async{
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  loadEnv();
  runApp(MyApp());
}

loadEnv() async{
  await DotEnv().load('.env');
}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}


class _MyAppState extends State<MyApp> {
  SpecificLocalizationDelegate _localeOverrideDelegate;

  @override
  void initState() {
    super.initState();
    // 初始化一个新的Localization Delegate，有了它，当用户选择一种新的工作语言时，可以强制初始化一个新的Translations
    _localeOverrideDelegate = new SpecificLocalizationDelegate(null);
    applic.onLocaleChanged = onLocaleChange;
    switchLanguage();
  }

  switchLanguage () async{
    String setLan = await Helper.getSetLanguage();
    String sysLan = await Helper.getSysLanguage();
    if (setLan != sysLan && setLan != '') {
      applic.onLocaleChanged(new Locale(setLan,''));
    }
  }

  onLocaleChange(Locale locale){
    setState((){
      _localeOverrideDelegate = new SpecificLocalizationDelegate(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ohwallet',
      localizationsDelegates: [
        const CupertinoLocalizationsDelegate(),
        _localeOverrideDelegate,   // 注册一个新的delegate
        const TranslationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // 美国英语
        const Locale('zh'), // 中文简体
        const Locale('ko')
        //其它Locales
      ],
      theme: ThemeData(
        canvasColor: Colors.transparent
      ),
      initialRoute: '/',
      routes: {
        '/': (BuildContext context) => Home(context: context,),
        '/transfer': (BuildContext context) => Transfer(),
        '/transfer-list': (BuildContext context) => TransferList(),
        '/transfer-detail': (BuildContext context) => TransferDetail(),
        '/receipt': (BuildContext context) => Receipt(),
        '/login': (BuildContext context) => Login(),
        '/register': (BuildContext context) => Register(),
        '/setPassword': (BuildContext context) => SetPassword(),
        '/changePassword': (BuildContext context) => ChangePassword(),
        '/privacy': (BuildContext context) => Privacy(),
        '/switch-language': (BuildContext context) => SwitchLanguage(),
        '/buyFinancial': (BuildContext context) => BuyFinancial(),
        '/financial-history': (BuildContext context) => FinancialHistory(),
        '/terms-service': (BuildContext context) => TermsService(),
        '/management-agreement': (BuildContext context) => managementAgreement(),
        '/privacy-policy': (BuildContext context) => privacyPolicy(),
      },
//            home: new MyHome()
    );
  }
}

