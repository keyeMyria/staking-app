import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../component/submitButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/helper.dart';
import '../component/alertModule.dart';
import '../../utils/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../pages/component/toast.dart';
import '../../utils/translation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/loading.dart';



class UserTab extends StatefulWidget {
  @override
  _UserTab createState() => new _UserTab();
}

class _UserTab extends State<UserTab> {
  String _userPhone = 'user';
  String _currentLanguage = '';
  List _userPicture = [
    'assets/images/user/icon_touxiang1.png',
    'assets/images/user/icon_touxiang2.png',
    'assets/images/user/icon_touxiang3.png',
    'assets/images/user/icon_touxiang4.png',
    'assets/images/user/icon_touxiang5.png',
  ];
  String _defaultUserPicture = 'assets/images/user/icon_touxiang1.png';
  bool isSubmit = false;
  String appVersion = ' ';
  BuildContext _context;
  Loading loading = new Loading();

  _refreshLanguage(BuildContext context) async{
    String languageCode = await Helper.getCurLanguage(context);
    setState(() {
      _currentLanguage = languageCode.toUpperCase();
    });
  }

  Widget build(BuildContext context) {
    setState(() {
      _context = context;
    });
    return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
              colors: [Color(0xff323346), Color(0xff212231)],
              center: Alignment.centerLeft,
              radius: 5),
        ),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(24),
                  top: ScreenUtil().setWidth(0),
                  right: ScreenUtil().setWidth(24),
                  bottom: ScreenUtil().setWidth(0)),
              child: Column(
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(
                            left: ScreenUtil().setWidth(0),
                            top: ScreenUtil().setWidth(50),
                            right: ScreenUtil().setWidth(0),
                            bottom: ScreenUtil().setWidth(29)),
                        child: Row(
                          children: <Widget>[
                            Text(Translations.of(context).text('user_table.my_text'),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil.getInstance().setSp(16)))
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(26)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: ScreenUtil().setWidth(248),
                            child: Text(_userPhone,
                                style:
                                TextStyle(fontSize: ScreenUtil().setSp(18), color: Colors.white)),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Image.asset(_defaultUserPicture,
                                height: ScreenUtil().setWidth(64),
                                width: ScreenUtil().setWidth(64)),
                          )
                        ],
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/changePassword');
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(60),
                          decoration: BoxDecoration(
                            border: new Border(
//                        top: BorderSide(color: Color(0xFFFFFFF), width: 1),
                                bottom:
                                BorderSide(color: Color(0xFFFFFFF), width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Image.asset("assets/images/user/icon_change_password.png",
                                      height: ScreenUtil().setWidth(16),
                                      width: ScreenUtil().setWidth(16)),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(24)),
                                    child: Text(Translations.of(context).text('user_table.change_password'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            ScreenUtil.getInstance().setSp(14))),
                                  ),
                                ],
                              ),
                              new SvgPicture.asset(
                                  'assets/images/user/icon_arrow.svg',
                                  width: ScreenUtil().setWidth(24),
                                  height: ScreenUtil().setWidth(24))
                            ],
                          ),
                        )),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/switch-language').then(
                                  (result) => _refreshLanguage(context)
                          );
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(60),
                          decoration: BoxDecoration(
                            border: new Border(
//                        top: BorderSide(color: Color(0xFFFFFFF), width: 1),
                                bottom:
                                BorderSide(color: Color(0xFFFFFFF), width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  new SvgPicture.asset(
                                      'assets/images/user/icon_language.svg',
                                      width: ScreenUtil().setWidth(15),
                                      height: ScreenUtil().setWidth(15)),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(24)),
                                    child: Text(Translations.of(context).text('user_table.switch_language'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            ScreenUtil.getInstance().setSp(14))),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Text(_currentLanguage,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white
                                      )
                                  ),
                                  new SvgPicture.asset(
                                      'assets/images/user/icon_arrow.svg',
                                      width: ScreenUtil().setWidth(24),
                                      height: ScreenUtil().setWidth(24)),
                                ],
                              )
                            ],
                          ),
                        )),
                    GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/terms-service');
                        },
                        child: Container(
                          height: ScreenUtil().setWidth(60),
                          decoration: BoxDecoration(
                            border: new Border(
//                        top: BorderSide(color: Color(0xFFFFFFF), width: 1),
                                bottom:
                                BorderSide(color: Color(0xFFFFFFF), width: 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  new SvgPicture.asset(
                                      'assets/images/user/icon_user_agreement.svg',
                                      width: ScreenUtil().setWidth(16),
                                      height: ScreenUtil().setWidth(16)),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: ScreenUtil().setWidth(24)),
                                    child: Text(Translations.of(context).text('user_table.user_privacy'),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                            ScreenUtil.getInstance().setSp(14))),
                                  ),
                                ],
                              ),
                              new SvgPicture.asset(
                                  'assets/images/user/icon_arrow.svg',
                                  width: ScreenUtil().setWidth(24),
                                  height: ScreenUtil().setWidth(24)),
                            ],
                          ),
                        )),
                    Container(
                      height: ScreenUtil().setWidth(60),
                      decoration: BoxDecoration(
                        border: new Border(
                            bottom: BorderSide(color: Color(0xFFFFFFF), width: 1)
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              new SvgPicture.asset(
                                  'assets/images/user/icon_version.svg',
                                  width: ScreenUtil().setWidth(16),
                                  height: ScreenUtil().setWidth(16)),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(24)),
                                child: Text(Translations.of(context).text('user_table.version_info'),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                        ScreenUtil.getInstance().setSp(14))),
                              ),
                            ],
                          ),
                          Text(
                              'v' + appVersion,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: SubmitButton(text: Translations.of(context).text('user_table.sign_out'), active: 0, width: 136, onSubmit: _signOut,disabledSubmit: true,),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(45)),
                    )
                  ],
                ),
            ),
            loading
          ],
        ));
  }
  @override
  void initState() {
    _initData();
    super.initState();
  }
  _initData () async{
    var prefs = await SharedPreferences.getInstance();
    _refreshLanguage(context);
    setState(() {
      if(prefs.getString('userPhone') != null){
        _userPhone = prefs.getString('userPhone');
        String tmpNumber = _userPhone.substring(_userPhone.length-1);
        int tmpIndex = int.parse(tmpNumber);
        _defaultUserPicture = _userPicture[tmpIndex~/2];
      }
    });
    appVersion = DotEnv().env['APP_CURRENT_VERSION'];
  }

  _signOut () {
      alert(_context, desc: Translations.of(context).text('user_table.sign_out_confirm'), showClose: true, callback: () async{
        loading.state.show();
        var res = await Http.auth().get('user/logout');
        if(res == null) {
          loading.state.dismiss();
          toast(Translations.of(context).text('user_table.sign_out_success'));
          var _prefs = await SharedPreferences.getInstance();
          _prefs.remove("token");
          _prefs.remove("account_address");
          _prefs.remove("userPhone");
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
  }


}
