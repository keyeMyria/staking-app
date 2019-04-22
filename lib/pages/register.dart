import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'component/inputPhone.dart';
import 'component/submitButton.dart';
import 'package:rubber/rubber.dart';
import 'dart:convert';
import '../pages/component/toast.dart';
import '../pages/setPassword.dart';
import 'component/appBarFactory.dart';
import 'component/pinView.dart';
import 'component/checkbox.dart';
import '../utils/translation.dart';

class Register extends StatefulWidget {
  String type;

  /// 用于区分注册账号或者找回密码  type == 'retrievePassword' 找回密码 type == 'register'  注册账号
  Register({Key key, this.type = 'register'});
  @override
  _RegisterState createState() {
    return new _RegisterState();
  }
}

class _RegisterState extends State<Register>
    with SingleTickerProviderStateMixin {
  TextEditingController _phoneController = new TextEditingController();
  bool _checkboxSelected = true;
  int _submitBtnStatus = 1;
  String _phoneNumber = '';
  Map _smsJson = {'data': []};
  String _smsCode = '+86';
  String _verificationCode = '';
  String _sendSmsCodeUrl = 'sms/register-send';
  String _forgotSendSmsUrl = 'sms/forgot-password-send';
  String _title = '';
  bool _isSubmit = false;
  GlobalKey<InputPhoneState> inputPhoneKey = new GlobalKey();
  GlobalKey<PinViewState> pinViewKey = new GlobalKey();

  void _setPassword() {
    if (_phoneNumber == '' ||
        _checkboxSelected == false ||
        _verificationCode.length < 4) {
      if(_phoneNumber == ''){
        toast(Translations.of(context).text('register.phone_error'));
      }else if(_verificationCode.length < 4){
        toast(Translations.of(context).text('register.verification_error'));
      }else {
        toast(Translations.of(context).text('register.privacy_error'));
      }
      setState(() {
        _isSubmit = false;
      });
    } else {
      Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (BuildContext context) => SetPassword(
                type: widget.type,
                phone: _phoneNumber,
                verificationCode: _verificationCode,
                countryCode: _smsCode.substring(1)),
          ));
      setState(() {
        _isSubmit = false;
      });
    }
  }

  Widget build(BuildContext context) {
    _setPageInfo();
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
                  inputPhoneKey.currentState.hideKeyboard();
                  pinViewKey.currentState.hideKeyboard();
                },
                  child:  Padding(
                  padding: EdgeInsets.only(
                      left: ScreenUtil().setWidth(24),
                      top: ScreenUtil().setWidth(33),
                      right: ScreenUtil().setWidth(24),
                      bottom: ScreenUtil().setWidth(0)),
                  child: Column(children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
                      child: Text(Translations.of(context).text('login.phone_number')),
                    ),
                    InputPhone(
                        key: inputPhoneKey,
                        controller: _phoneController,
                        smsCodeUrl: _sendSmsCodeUrl,
                        hintText: Translations.of(context).text('login.phone_placeholder'),
                        onchange: _phoneChange,
                        smsCode: _smsCode,
                        selectedSms: _settingModalBottomSheet),
                    Padding(
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setWidth(40),
                          bottom: ScreenUtil().setWidth(8)),
                      child: Text(Translations.of(context).text('register.verification')),
                    ),
                    PinView(
                        key: pinViewKey,
                        count: 4, // describes the field number
                        dashPositions: [
                          0,
                          4
                        ], // positions of dashes, you can add multiple
                        autoFocusFirstField: false, // defaults to true
                        margin:
                            EdgeInsets.all(2.5), // margin between the fields
                        obscureText:
                            false, // describes whether the text fields should be obscure or not, defaults to false
                        style: TextStyle(
                          // style for the fields
                          fontSize: 14,
                        ),
                        splicingSymbol: '',
                        inputDecoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0x19ffffff)),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff4551ff)),
                          ),
                        ),
                        submit: (String pin) {
                          // when all the fields are filled
                          // submit function runs with the pin
                          setState(() {
                            _verificationCode = pin;
                          });
                        }),
                    Padding(
                      padding: EdgeInsets.only(top: ScreenUtil().setWidth(17)),
                      child: _checkboxWidget(),
                    ),
                    Container(
                      child: SubmitButton(
                          text: Translations.of(context).text('register.btn'),
                          active: _submitBtnStatus,
                          isSubmit: _isSubmit,
                          onSubmit: _setPassword,
                          width: 312),
                      margin: EdgeInsets.only(top: ScreenUtil().setWidth(51)),
                    )
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                ),
              ))),
    );
  }


  @override
  void initState() {

    Future<String> loadString =
        DefaultAssetBundle.of(context).loadString("assets/json/AreaCode.json");
    loadString.then((String value) {
        _smsJson = json.decode(value);
    });
    super.initState();
  }

  void _phoneChange(val) {
    setState(() {
      _phoneNumber = val;
    });
  }

  Widget _checkboxWidget() {
    Widget checkbox;
    if (widget.type == 'register') {
      checkbox = Row(
        children: <Widget>[
          CheckBox(changeCheckbox: _getCheckbox),
               Padding(
                 padding: EdgeInsets.only(left: ScreenUtil().setWidth(0), top: ScreenUtil().setWidth(10)),
                 child: Container(
                   width: ScreenUtil().setWidth(280),
                   child: Wrap(
                     alignment: WrapAlignment.start,
                     children: <Widget>[
                       Text(Translations.of(context).text('register.agree'),
                           style: TextStyle(
                               color: Color(0xffffffff),
                               fontSize: ScreenUtil().setSp(12))),
                       GestureDetector(
                         onTap: () => Navigator.pushNamed(context, '/terms-service'),
                         child: Text(Translations.of(context).text('register.service_terms'),
                             style: TextStyle(
                                 color: Color(0xff4551ff),
                                 fontSize: ScreenUtil().setSp(12))),
                       ),
                       GestureDetector(
                         onTap: () => Navigator.pushNamed(context, '/privacy-policy'),
                         child: Text(Translations.of(context).text('register.privacy_policy'),
                             style: TextStyle(
                                 color: Color(0xff4551ff),
                                 fontSize: ScreenUtil().setSp(12))),
                       ),
                     ],
                   ),
                 ),
               ),
        ],
      );
    } else {
      checkbox = Container(height: ScreenUtil().setWidth(160));
    }
    return checkbox;
  }

  _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ScreenUtil().setWidth(16)),
                  topRight: Radius.circular(ScreenUtil().setWidth(16))),
              color: Color(0xff404155),
            ),
            padding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setWidth(28),
                horizontal: ScreenUtil().setWidth(24)),
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
                        ),
                      ),
                      onTap: () => _selectCoin(context, index));
                }),
          );
        });
  }

  _selectCoin(BuildContext context, int index) {
    setState(() {
      _smsCode = "+" + _smsJson['data'][index]['phone_code'];
    });
    Navigator.pop(context);
  }

  _getCheckbox(val) {
    setState(() {
      _checkboxSelected = val;
    });
  }

  _setPageInfo(){
    if (widget.type != 'register') {
      _checkboxSelected = true;
      _title = Translations.of(context).text('register.get_password_title');
      _sendSmsCodeUrl = _forgotSendSmsUrl;
    }else{
      _title = Translations.of(context).text('register.title');
    }
  }
}
