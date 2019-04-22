import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'component/submitButton.dart';
import 'component/inputPassword.dart';
import '../utils/http.dart';
import '../pages/component/toast.dart';
import 'component/appBarFactory.dart';
import '../utils/translation.dart';


class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() {
    return new _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController _oldPasswordController = new TextEditingController();
  TextEditingController _newPasswordController = new TextEditingController();
  TextEditingController _againPasswordController = new TextEditingController();
  bool _isSubmit = false;
  String _oldPassword = '';
  String _newPassword = '';
  String _againPassword = '';
  GlobalKey<InputPasswordState> oldPasswordKey = new GlobalKey();
  GlobalKey<InputPasswordState> newPasswordKey = new GlobalKey();
  GlobalKey<InputPasswordState> againPasswordKey = new GlobalKey();


  void _oldPasswordChange(val){
    setState(() {
      _oldPassword = val;
    });
  }
  void _newPasswordChange(val){
    setState(() {
      _newPassword = val;
    });
  }
  void _againPasswordChange(val){
    setState(() {
      _againPassword = val;
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(context, Translations.of(context).text('change_password.title')),
        body: DefaultTextStyle(
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.3),
            fontSize: ScreenUtil().setSp(14),
          ),
          child:Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                  colors: [Color(0xff323346), Color(0xff212231)],
                  center: Alignment.centerLeft,
                  radius: 5),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 120,
                ),
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Container(
                        height: MediaQuery.of(context).size.height - 56,
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
                            oldPasswordKey.currentState.hideKeyboard();
                            newPasswordKey.currentState.hideKeyboard();
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
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setWidth(40),
                                    bottom: ScreenUtil().setWidth(8)),
                                child: Text(Translations.of(context).text('change_password.old_password')),
                              ),
                              InputPassword(
                                key: oldPasswordKey,
                                controller: _oldPasswordController,
                                hintText: Translations.of(context).text('change_password.old_password_placeholder'),
                                onchange: _oldPasswordChange,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setWidth(40),
                                    bottom: ScreenUtil().setWidth(8)),
                                child: Text(Translations.of(context).text('change_password.new_password')),
                              ),
                              InputPassword(
                                key: newPasswordKey,
                                controller: _newPasswordController,
                                hintText: Translations.of(context).text('change_password.new_password_placeholder'),
                                onchange: _newPasswordChange,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: ScreenUtil().setWidth(40),
                                    bottom: ScreenUtil().setWidth(8)),
                                child: Text(Translations.of(context).text('change_password.confirm_new_password')),
                              ),
                              InputPassword(
                                key: againPasswordKey,
                                controller: _againPasswordController,
                                hintText: Translations.of(context).text('change_password.confirm_new_password_place'),
                                onchange: _againPasswordChange,
                              ),
                              Container(
                                child: SubmitButton(text: Translations.of(context).text('set_password.confirm'), active: 1, onSubmit: _submit, width: 312),
                                margin: EdgeInsets.only(top: ScreenUtil().setWidth(100)),
                              )
                            ], crossAxisAlignment: CrossAxisAlignment.start),
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
          )
        ));
  }

  void _submit() async{
    if(_againPassword.length == 0 || _newPassword.length == 0 || _oldPassword.length == 0) {
        toast(Translations.of(context).text('set_password.password_format_error'));
        setState(() {
          _isSubmit = false;
        });
    }else {
      Map sendData = {
        "old_password": _oldPassword,
        "password": _newPassword,
        "password_confirmation": _againPassword,
      };
      var res = await Http.auth().post('user/change-password', sendData);
      if(res == null) {
        toast(Translations.of(context).text('change_password.change_password_success'));
        setState(() {
          _isSubmit = false;
        });
        Navigator.of(context).pop();
      }
    }
  }

}
