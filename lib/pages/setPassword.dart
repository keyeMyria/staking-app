import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'component/submitButton.dart';
import 'component/inputPassword.dart';
import '../pages/component/toast.dart';
import '../utils/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'component/appBarFactory.dart';
import '../utils/translation.dart';


class SetPassword extends StatefulWidget {
  String type;
  String phone;
  String verificationCode;
  String countryCode;
  SetPassword({Key key, this.type = 'register', this.phone, this.verificationCode, this.countryCode});
  @override
  _SetPasswordState createState() {
    return new _SetPasswordState();
  }
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController againPasswordController = new TextEditingController();
  String _password = '';
  String _againPassword = '';
  bool _isSubmit = false;
  String _registerSetUrl = 'register';
  String _title = '';
  String _successTip = '';
  String _btnText = '';
  SharedPreferences _prefs;
  GlobalKey<InputPasswordState> passwordKey = new GlobalKey();
  GlobalKey<InputPasswordState> againPasswordKey = new GlobalKey();

  // 密码框change
  _passwordChange(val){
     setState(() {
       _password = val;
     });
  }
  _againPasswordChange(val){
     setState(() {
       _againPassword = val;
     });
  }
  _submit() async{
    _prefs = await SharedPreferences.getInstance();
    if(_password.length == 0 || _againPassword.length == 0) {
      toast(Translations.of(context).text('set_password.password_format_error'));
      setState(() {
        _isSubmit = false;
      });
    }else if(_password != _againPassword){
      toast(Translations.of(context).text('set_password.password_content_error'));
      setState(() {
        _isSubmit = false;
      });
    }else {
      Map sendData = {
        "country_code": widget.countryCode,
        "telephone": widget.phone,
        "password": _password,
        "password_confirmation": _againPassword,
        "verify_code": widget.verificationCode
      };
      var res = await Http().post(_registerSetUrl, sendData);
      if(widget.type != 'register') {
        if(res == null){
          toast(_successTip);
          Navigator.pushReplacementNamed(context, '/login');
        }
      }else {
        if(res != null && res['token'] !='' && res['token'] != null) {
          _prefs.setString('token', res['token']);
          _prefs.setString('account_address', res['account_address']);
          _prefs.setString('userPhone', widget.phone);
          await Http.setHeader();
          toast(_successTip);
          Navigator.pushNamed(context, '/');
        }
      }

      setState(() {
        _isSubmit = false;
      });
    }

  }

  Widget build(BuildContext context) {
    _initPageInfo(context);
    return Scaffold(
        appBar: getAppBar(context, _title),
        resizeToAvoidBottomPadding: false,
        body: DefaultTextStyle(
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.3),
            fontSize: ScreenUtil().setSp(14),
          ),
          child: new Container(
            decoration: BoxDecoration(
              gradient: new LinearGradient(
                begin: const Alignment(0.0, -1.0),
                end: const Alignment(0.0, 1.0),
                colors: [Color(0xff323346), Color(0xff212231)],
              ),
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: (){
                passwordKey.currentState.hideKeyboard();
                againPasswordKey.currentState.hideKeyboard();
              },
              child: Padding(
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(24),
                  top: ScreenUtil().setWidth(0),
                  right: ScreenUtil().setWidth(24),
                  bottom: ScreenUtil().setWidth(0)),
              child: Column(children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setWidth(40) ,bottom: ScreenUtil().setWidth(8)),
                  child: Text(Translations.of(context).text('login.password')),
                ),
                InputPassword(
                  key: passwordKey,
                  controller: passwordController,
                  hintText: Translations.of(context).text('login.password_placeholder'),
                  onchange: _passwordChange,
                ),
                Padding(
                  padding: EdgeInsets.only(top: ScreenUtil().setWidth(40) ,bottom: ScreenUtil().setWidth(8)),
                  child: Text(Translations.of(context).text('set_password.confirm_password')),
                ),
                InputPassword(
                  key: againPasswordKey,
                  controller: againPasswordController,
                  hintText: Translations.of(context).text('set_password.again_password'),
                  onchange: _againPasswordChange,
                ),
                Container(
                  child: SubmitButton(text: _btnText,active: 1, width: 312,onSubmit: _submit, isSubmit: _isSubmit,),
                  margin: EdgeInsets.only(top: ScreenUtil().setWidth(200)),
                )
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
            )
          ),
        ));
  }
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }
  _initPageInfo(context){
    if(widget.type != 'register') {
      setState(() {
        _title = Translations.of(context).text('register.get_password_title');
        _registerSetUrl = 'forgot-password';
        _successTip = Translations.of(context).text('set_password.get_password_success');
        _btnText = Translations.of(context).text('set_password.confirm');
      });
    } else {
      setState(() {
        _title = Translations.of(context).text('register.title');
        _successTip = Translations.of(context).text('set_password.register_success');
        _btnText = Translations.of(context).text('register.title');
      });
    }
  }
}
