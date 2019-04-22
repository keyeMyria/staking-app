import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'component/inputPhone.dart';
import 'component/inputPassword.dart';
import 'component/loginButton.dart';
import 'package:rubber/rubber.dart';
import 'dart:convert';
import '../utils/http.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/component/toast.dart';
import '../utils/translation.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'component/alertModule.dart';
import '../utils/loading.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() {
    return new _LoginState();
  }
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  int _submitBtnStatus = 1;
  ScrollController _scrollController = ScrollController();
  Map _smsJson = {'data': []};
  String _smsCode = '+86';
  bool _isSubmit = false;
  SharedPreferences _prefs;
  GlobalKey<InputPhoneState> inputPhoneKey = new GlobalKey();
  GlobalKey<InputPasswordState> inputPasswordKey = new GlobalKey();
  Loading loading = new Loading(type: false,);


  Widget build(BuildContext context) {
    return Scaffold(
//      resizeToAvoidBottomPadding: false,
        body: DefaultTextStyle(
      style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 0.3),
          fontSize: ScreenUtil().setSp(14),
          ),

      child: Stack(
        children: <Widget>[
          Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
                colors: [Color(0xff323346), Color(0xff212231)],
                center: Alignment.centerLeft,
                radius: 5),
          ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints.tight(MediaQuery.of(context).size),
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    inputPhoneKey.currentState.hideKeyboard();
                    inputPasswordKey.currentState.hideKeyboard();
                  },
                  child: new Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                            colors: [Color(0xff323346), Color(0xff212231)],
                            center: Alignment.centerLeft,
                            radius: 5),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                              colors: [Color(0xff323346), Color(0xff212231)],
                              center: Alignment.centerLeft,
                              radius: 5),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(24),
                              top: ScreenUtil().setWidth(33),
                              right: ScreenUtil().setWidth(24),
                              bottom: ScreenUtil().setWidth(0)),
                          child: Column(children: <Widget>[
                            Padding(
                          padding: EdgeInsets.only(top: ScreenUtil().setWidth(40)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Image.asset("assets/images/login/logo.png",
                                    height: ScreenUtil().setWidth(48),
                                    width: ScreenUtil().setWidth(48)),
                                GestureDetector(
                                    child: Text(
                                        Translations.of(context).text('login.new_user'),
                                        style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16),
                                          color: Color(0xff4551ff),
                                          decoration: TextDecoration.none,
                                          height: 1
                                        )
                                        ),
                                    onTap: () => Navigator.pushNamed(context, '/register')
                                ),
                              ],
                            ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(24),
                                  bottom: ScreenUtil().setWidth(76)),
                              child: Image.asset("assets/images/login/img_wallet_name.png",
                                  height: ScreenUtil().setWidth(29),
                                  width: ScreenUtil().setWidth(119))
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
                              child: Text(Translations.of(context).text('login.phone_number')),
                            ),
                            InputPhone(key: inputPhoneKey, controller: _phoneController, hintText: Translations.of(context).text('login.phone_placeholder'), smsBtn: false, smsCode: _smsCode,selectedSms: _settingModalBottomSheet),
                            Padding(
                              padding: EdgeInsets.only(top: ScreenUtil().setWidth(40) ,bottom: ScreenUtil().setWidth(8)),
                              child: Text(Translations.of(context).text('login.password')),
                            ),
                            InputPassword(
                              key: inputPasswordKey,
                              controller: _passwordController,
                              hintText: Translations.of(context).text('login.password_placeholder'),

                            ),
                            GestureDetector(
                                child: Container(
                                  child: Text(
                                      Translations.of(context).text('login.forget_password'),
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16),
                                          color: Color(0xff4551ff),
                                          decoration: TextDecoration.none)
                                  ),
                                  margin: EdgeInsets.only(top: ScreenUtil().setWidth(21)),
                                  alignment: Alignment.centerRight,
                                ),
                                onTap: (){
                                  Navigator.push(context, new MaterialPageRoute(
                                    builder: (BuildContext context) => Register(type: 'retrievePassword',),
                                  ));
                                }
                            ),
                            Container(
                              child: SubmitButton(text: Translations.of(context).text('login.login'),active: _submitBtnStatus, isSubmit: _isSubmit,onSubmit: _loginIn, width: 312),
                              margin: EdgeInsets.only(top: ScreenUtil().setWidth(51)),
                            )
                          ],
                              crossAxisAlignment: CrossAxisAlignment.start),
                        ),
                      )
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      loading
        ],
      )
    ));
  }

  @override
  void initState() {
    getAppVersion();
    Future<String> loadString =
    DefaultAssetBundle.of(context).loadString("assets/json/AreaCode.json");
    loadString.then((String value) {
      setState(() {
        _smsJson = json.decode(value);
      });
    });
    super.initState();
  }
  void _loginIn() async{
    loading.state.show();
    _prefs = await SharedPreferences.getInstance();
    Map sendData = {
      "country_code": _smsCode.substring(1),
      "password": _passwordController.text,
      "telephone": _phoneController.text
    };
    if(sendData["password"] == null || sendData["password"] == "" || sendData["telephone"] == "") {
      setState(() {
        _isSubmit = false;
      });
      loading.state.dismiss();
      toast(Translations.of(context).text('login.login_error'));
    }else {
      var res = await Http().post('login', sendData);
      loading.state.dismiss();
      setState(() {
        _isSubmit = false;
      });
    if(res['token'] !='' && res['token'] != null) {
      _prefs.setString('token', res['token']);
      _prefs.setString('account_address', res['account_address']);
      _prefs.setString('userPhone', _phoneController.text);
      await Http.setHeader();
      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
    }
    }
  }

  _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil().setWidth(16)),
                  topRight: Radius.circular(ScreenUtil().setWidth(16))
              ),
              color: Color(0xff404155),
            ),
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(28),
                horizontal: ScreenUtil().setWidth(24)
            ),
            child: ListView.separated(
                shrinkWrap: true,
                itemCount: _smsJson['data'].length,
                separatorBuilder: (BuildContext sepBc, int index) {
                  return Container(
                    height: 1,
                    color: Color(0xffbdbdbd).withOpacity(0.1),
                  );
                },
                itemBuilder: (BuildContext itemBc, int index) {
                  return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: ScreenUtil().setWidth(48),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                            _smsJson['data'][index]['en_name'],
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 14,
                              color:"+" + _smsJson['data'][index]['phone_code'] == _smsCode ? Color(0xffffffff) : Color(0xffffffff).withOpacity(0.5),
                            ),
                           ),
                            Text(
                              " +"+_smsJson['data'][index]['phone_code'],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 14,
                                  color:"+" +_smsJson['data'][index]['phone_code'] == _smsCode ? Color(0xffffffff) : Color(0xffffffff).withOpacity(0.5),
                              ),
                            ),
                          ],
                        )
                      ),
                      onTap: () => _selectCoin(context, index)
                  );
                }),
          );
        }
    );
  }
  _selectCoin(BuildContext context, int index) {
    setState(() {
      _smsCode = "+" + _smsJson['data'][index]['phone_code'];
    });
    Navigator.pop(context);
  }
  void getAppVersion ()async{
    var tmpUploadUrl = DotEnv().env['APP_UPLOAD_URL'];
    var res = await Http.auth().get('app/current-version');
    var tmpAppVersion = DotEnv().env['APP_CURRENT_VERSION'];
    if(res["app_current_version"] != tmpAppVersion) {
      alert(context, desc: Translations.of(context).text('version.new_version') +'v'+res["app_current_version"],btn: Translations.of(context).text('version.go_update'),callback: ()async{
        if (await canLaunch(tmpUploadUrl)) {
          await launch(tmpUploadUrl,forceSafariVC: true);
        }
      },disableBtnCb: true);
    }
  }
}