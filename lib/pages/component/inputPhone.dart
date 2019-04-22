import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:common_utils/common_utils.dart';
import '../../utils/http.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../utils/translation.dart';
import '../../utils/helper.dart';
import '../../pages/component/toast.dart';

class InputPhone extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  Widget defaultCleanIcon = Image.asset("assets/images/login/icon_cancel.png",
  height: ScreenUtil().setWidth(16),
  width: ScreenUtil().setWidth(16));
  Widget cleanIcon;
  Function onchange;
  Function selectedSms;
  bool smsBtn;
  String smsCode;
  String smsCodeUrl;
  InputPhone(
      {Key key,
      this.controller,
        this.smsCodeUrl,
      this.hintText = '',
      this.onchange,
      this.cleanIcon,
      this.smsBtn = true,
        this.smsCode = '+86',
      this.selectedSms})
      : super(key: key);

  @override
  InputPhoneState createState() => new InputPhoneState();
}

class InputPhoneState extends State<InputPhone> {
  TextStyle _hintStyle =
      TextStyle(color: Color.fromRGBO(255, 255, 255, 0.3), fontSize: ScreenUtil().setWidth(14),height: 1);
  EdgeInsets _inputPadding = EdgeInsets.only(
      top: ScreenUtil().setWidth(10),
      left: ScreenUtil().setWidth(60),
      bottom: ScreenUtil().setWidth(20));
  TimerUtil mTimerUtil;
  String _sendSmsCodeText = "";
  bool _isInitBtnText = true;
  bool _isSendSmsCode = false;
  String _inputValue = '';
  FocusNode _focusNode = FocusNode();
  String _userLanguage = 'ZH';
  void _cleanState() {
    setState(() {
      _sendSmsCodeText = Translations.of(context).text('input_phone');
      _isSendSmsCode = false;
    });
    if (mTimerUtil != null) {
      mTimerUtil.cancel();
    }
  }
  void hideKeyboard(){
    _focusNode.unfocus();
  }
  void _sendSmsCode() async {
    if (!_isSendSmsCode) {
      // 请求
      if(_inputValue.length == 0) {
        toast(widget.hintText);
        return;
      }
      setState(() {
        _isSendSmsCode = true;
        _sendSmsCodeText = "120s";
      });
      mTimerUtil = new TimerUtil(mInterval: 1000);
      mTimerUtil.setOnTimerTickCallback((int tick) {
        setState(() {
          _sendSmsCodeText = (int.parse(_sendSmsCodeText.substring(0, _sendSmsCodeText.length - 1)) - 1).toString() + 's';
          if (int.parse(_sendSmsCodeText.substring(0, _sendSmsCodeText.length - 1)) <= 0) {
            _cleanTimeDown();
          }
        });
      });
      mTimerUtil.startTimer();
      Map sendData = {
        'country_code': widget.smsCode.substring(1),
        'telephone': _inputValue
      };
      var res = await Http().post(widget.smsCodeUrl, sendData);
      if(res != null && res["error"] == null) {
        _cleanTimeDown();
      }
    }
  }
  void _cleanTimeDown(){
    setState(() {
      _isSendSmsCode = false;
    });
    mTimerUtil.cancel();
    _sendSmsCodeText = Translations.of(context).text('input_phone');
  }

  Widget getIconInput() {
    return Stack(
      children: <Widget>[
        Positioned(
          child: TextField(
              style: TextStyle(color: Colors.white),
              controller: widget.controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: _hintStyle,
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xffbdbdbd).withOpacity(0.3)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff4551ff)),
                  ),
                  contentPadding: _inputPadding),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  _inputValue = val;
                });
                widget.onchange(val);
              }),
        ),
        Positioned(
            top: _userLanguage == 'ZH' ? 5 : 3.5,
            left: 0,
            child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if(widget.selectedSms !=null )widget.selectedSms(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  width: ScreenUtil().setWidth(48),
                  height: ScreenUtil().setWidth(28),
                  color: Color.fromRGBO(229, 229, 229, .1),
                  child: Text(widget.smsCode,
                      style: TextStyle(
                          color: Color(0xff4551ff),
                          fontSize: ScreenUtil().setSp(14))),
                ))),
        this.inputIcon(),
      ],
    );
  }

  // icon

  Widget inputIcon() {
    Widget cleanIcon;
    if (widget.cleanIcon == null) {
      cleanIcon = widget.defaultCleanIcon;
    } else {
      cleanIcon = widget.cleanIcon;
    }

    Widget smsCodeBtn = new Container(
        margin: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
        alignment: Alignment.center,
        width: ScreenUtil().setWidth(48),
        height: ScreenUtil().setWidth(28),
        constraints: BoxConstraints.tightFor(
            width: ScreenUtil().setWidth(48),
            height: ScreenUtil().setWidth(28)),
        decoration: BoxDecoration(
          //背景装饰
          gradient: RadialGradient(
              //背景径向渐变
              colors: !_isSendSmsCode
                  ? [
                      Color.fromRGBO(69, 81, 255, 1),
                      Color.fromRGBO(69, 81, 255, 1)
                    ]
                  : [
                      Color.fromRGBO(229, 229, 229, .1),
                      Color.fromRGBO(229, 229, 229, .1)
                    ],
              center: Alignment.centerLeft,
              radius: 5),
          borderRadius: BorderRadius.all(
            Radius.circular(ScreenUtil().setWidth(2)),
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: (){
            _sendSmsCode();
          },
          child: Text(_sendSmsCodeText,
              style: TextStyle(
                  color: !_isSendSmsCode ? Colors.white : Color(0xff4551ff),
                  fontSize: ScreenUtil().setSp(14))),
        ));
    if (widget.smsBtn) {
      return Positioned(
          top: ScreenUtil().setWidth(3),
          right: 0,
          child: Row(
            children: <Widget>[
              Opacity(
                opacity: _inputValue.length == 0 ? 0 : 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      widget.controller.text = '';
                      setState(() {
                        _inputValue = '';
                      });
                    });
                  },
                  child: cleanIcon),
              ),
              smsCodeBtn,
            ],
          ));
    } else {
      return Positioned(
          top: ScreenUtil().setWidth(12),
          right: 0,
          child: Row(
            children: <Widget>[
              Opacity(
                opacity: _inputValue.length == 0 ? 0 : 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      widget.controller.text = '';
                      setState(() {
                        _inputValue = '';
                      });
                    });
                  },
                  child: cleanIcon),
              )
            ],
          ));
    }
  }
  _refreshLanguage(BuildContext context) async{
    String languageCode = await Helper.getCurLanguage(context);
    setState(() {
      _userLanguage = languageCode.toUpperCase();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    _refreshLanguage(context);
    super.initState();
  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    if(_isInitBtnText) {
      _sendSmsCodeText = Translations.of(context).text('input_phone');
      _isInitBtnText = false;
    }
    return getIconInput();
  }
}
