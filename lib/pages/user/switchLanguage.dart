import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/appBarFactory.dart';
import '../../utils/http.dart';
import '../../utils/helper.dart';
import '../../utils/translation.dart';


class SwitchLanguage extends StatefulWidget {

  @override
  SwitchLanguageState createState() =>  new SwitchLanguageState();
}

class SwitchLanguageState extends State<SwitchLanguage> {
  int _selectedIndex;
  SharedPreferences prefs;

  @override
  initState(){
    super.initState();
    // Add listeners to this class
    _selectedIndex = 0;
    setDefaultLanguage(context);
  }

  TextStyle _selectedStyle = TextStyle(
    color: Colors.white,
    fontSize: ScreenUtil().setSp(14),
    letterSpacing: -0.34
  );
  TextStyle _normalStyle = TextStyle(
    color: Colors.white.withOpacity(0.5),
    fontSize: ScreenUtil().setSp(14),
    letterSpacing: -0.34
  );

  // 根据本地存储语言 || 系统语言设定默认语言
  setDefaultLanguage(BuildContext context) async{
    prefs = await SharedPreferences.getInstance();
    var languageCode = await Helper.getCurLanguage(context);
    list.asMap().forEach((index, item) {
      if (item['value'] == languageCode) {
        changeLanguage(index);
      }
    });
  }

  changeLanguage(int index){
    setState(() {
      _selectedIndex = index;
    });
    prefs.setString('language', list[index]['value']);
    applic.onLocaleChanged(new Locale(list[index]['value'],''));
//    FlutterI18n.refresh(context, list[index]['value']);
    Http.setHeaderLocale(list[index]['value']);
  }

  List<Map> list = [
    {'name': '简体中文', 'value': 'zh'},
    {'name': 'English', 'value': 'en'},
    {'name': '한국어', 'value': 'ko'},
  ];

  Widget getListView() {
     return Column(
      children: <Widget>[
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: list.length,
            itemExtent: ScreenUtil().setWidth(62), // 高度
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1, color: Color(0xffbdbdbd).withOpacity(0.1)),
                    )),
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(list[index]['name'],
                            style: _selectedIndex == index ? _selectedStyle : _normalStyle
                          )
                        ],
                      ),
                      Positioned(
                        right: 0,
                        child: _selectedIndex == index ?
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[Icon(Icons.done, color: Colors.white,)],
                          ) :
                          Container(),
                      )
                    ],
                  ),
                ),
                onTap: () => changeLanguage(index),
              );
            }),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, Translations.of(context).text('language_title')),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(10),
                ScreenUtil().setWidth(24),
                ScreenUtil().setWidth(24),
                ScreenUtil().setWidth(80)
              ),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: const Alignment(0.0, -1.0),
                  end: const Alignment(0.0, 1.0),
                  colors: <Color>[
                    const Color(0xff323346),
                    const Color(0xff212231)
                  ],
                ),
              ),
              child: getListView(),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/user/img_userservice.svg',
                width: ScreenUtil().setWidth(156),
                height: ScreenUtil().setWidth(82),
              ),
            ),
          ],

        ),
      )
    );
  }
}