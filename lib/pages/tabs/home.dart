import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './walletTab.dart';
import './financialTab.dart';
import './userTab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/exit.dart';
import '../../utils/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/translation.dart';
import '../../utils/connectionListener.dart';
import '../../utils/helper.dart';
import 'dart:async';


class Home extends StatefulWidget {

  final BuildContext context;

  Home({Key, key, this.context}) : super(key: key);

  @override
  HomeState createState() {
    if (context != null) Http.setContext(context);
    return new HomeState();
  }
}

class HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  TabController controller;
  static StreamController streamController;

  final Map tabIcons = {
    'icon1Normal': new SvgPicture.asset('assets/images/home/icon_wallet_normal.svg'),
    'icon1Selected': new SvgPicture.asset('assets/images/home/icon_wallet_selected.svg'),
    'icon2Normal': new SvgPicture.asset('assets/images/home/icon_financial_management_normal.svg'),
    'icon2Selected': new SvgPicture.asset('assets/images/home/icon_financial_management_selected.svg'),
    'icon3Normal': new SvgPicture.asset('assets/images/home/icon_user_profile_normal.svg'),
    'icon3Selected': new SvgPicture.asset('assets/images/home/icon_user_profile_selected.svg'),
  };

  @override
  void initState() {
    super.initState();
//    checkIsLogin();
    streamController = StreamController.broadcast();
    setHeader(context);
    ConnectionListener.init(context);
    controller = new TabController(length: 3, vsync: this)
      ..addListener(() {
        setState(() {
          this._tabIndex = controller.index;
        });
        if (controller.indexIsChanging && controller.index < 2) {
          if (controller.index == 0) {
            streamController.sink.add('refresh_wallet');
          } else if (controller.index == 1) {
            streamController.sink.add('refresh_financial');
          }
        }
      });
  }

  void setHeader(BuildContext context) async {
    await Http.setHeader();
    var languageStr = await Helper.getCurLanguage(context);
    Http.setHeaderLocale(languageStr);
  }

  Future<Null> checkIsLogin() async {
    String _token = "";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString("token");
    if (_token == "" || _token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
      controller.dispose();
      streamController.close();
      super.dispose();
  }

  Widget getTabItem(BuildContext context, int tabIndex) {

    String tabTitle = Translations.of(context).text('tabs.tab1');
    Widget tabIcon = (this._tabIndex == tabIndex
        ? tabIcons['icon${tabIndex + 1}Selected']
        : tabIcons['icon${tabIndex + 1}Normal']);
    switch (tabIndex) {
      case 0:
        tabTitle = Translations.of(context).text('tabs.tab1');
        break;
      case 1:
        tabTitle = Translations.of(context).text('tabs.tab2');
        break;
      case 2:
        tabTitle = Translations.of(context).text('tabs.tab3');
        break;
    }
    double tabTopOffset = 0;
    if (MediaQuery.of(context).size.height > 800) { // iphoneX... 大屏幕适配
      tabTopOffset = ScreenUtil().setHeight(8);
    }
    return Container(
      height: ScreenUtil().setHeight(58),
      child: new Tab(
        child: Center(
          child: Container(
            margin: EdgeInsets.only(
              bottom: tabTopOffset
            ),
            child: Row(children: <Widget>[
              new SizedBox(
                width: 20.0,
                height: 20.0,
                child: tabIcon,
              ),
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(6)),
                child: Text(tabTitle),
              ),
            ], mainAxisAlignment: MainAxisAlignment.center),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance = ScreenUtil(width: 360, height: 640)..init(context);
    return WillPopScope(
      onWillPop: exit,
      child: new Scaffold(
        body: new TabBarView(
          children: <Widget>[
            WalletTab(streamController: streamController),
            FinancialTab(streamController: streamController),
            UserTab()
          ],
          controller: controller,
        ),
        bottomNavigationBar: new Material(
          color: Color(0xff2b2c3e),
          child: new TabBar(
            tabs: [
              getTabItem(context, 0),
              getTabItem(context, 1),
              getTabItem(context, 2),
            ],
            controller: controller,
            indicator: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: ScreenUtil().setWidth(2), color: Color(0xff4551ff)),
              )),
            labelColor: Color(0xffffffff),
            unselectedLabelColor: Color(0xff5e6180),
            labelStyle: TextStyle(
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }


}
