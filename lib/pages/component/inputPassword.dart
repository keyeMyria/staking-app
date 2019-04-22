import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InputPassword extends StatefulWidget {
  int inputIconSize = 16;
  final TextEditingController controller;
  final String hintText;
  Widget cleanIcon;
  bool smsBtn;
  Function onchange;
  InputPassword(
      {Key key,
      this.controller,
      this.hintText = '',
      this.cleanIcon,
        this.onchange,
      this.smsBtn = true})
      : super(key: key);

  @override
  InputPasswordState createState() => new InputPasswordState();
}

class InputPasswordState extends State<InputPassword> {
  bool inputType = true;
  bool _passwordIconStatus = false;
  Widget _defaultCleanIcon = Image.asset("assets/images/login/icon_cancel.png",
      height: ScreenUtil().setWidth(16),
      width: ScreenUtil().setWidth(16));
  Widget _showPasswordIcon = SvgPicture.asset(
    'assets/images/login/icon_eyes_close.svg',
    width: ScreenUtil().setWidth(16),
    height: ScreenUtil().setWidth(16),
  );
  Widget _hidePasswordIcon = SvgPicture.asset(
    'assets/images/login/icon_eye.svg',
    width: ScreenUtil().setWidth(16),
    height: ScreenUtil().setWidth(16),
  );
  String _password = '';
  TextStyle _hintStyle =
      TextStyle(color: Color.fromRGBO(255, 255, 255, 0.3), fontSize: 14);
  EdgeInsets _inputPadding = EdgeInsets.only(
      top: ScreenUtil().setWidth(10),
      left: ScreenUtil().setWidth(0),
      bottom: ScreenUtil().setWidth(20));
  FocusNode _focusNode = new FocusNode();
  Widget getIconInput() {
    return Stack(
      children: <Widget>[
        Positioned(
          child: TextField(
            obscureText: inputType,
            style: TextStyle(color: Colors.white),
            focusNode: _focusNode,
            controller: widget.controller,
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
            onChanged: (val){
              setState(() {
                _password = val;
              });
              if(widget.onchange != null)widget.onchange(val);
            },
          ),
        ),
        this.inputIcon()
      ],
    );
  }

  // icon

  Widget inputIcon() {
    Widget cleanIcon;
    if (widget.cleanIcon == null) {
      cleanIcon = _defaultCleanIcon;
    } else {
      cleanIcon = widget.cleanIcon;
    }
    Widget passwordIcon;

    if (_passwordIconStatus) {
      passwordIcon = _showPasswordIcon;
    } else {
      passwordIcon = _hidePasswordIcon;
    }
    return Positioned(
        top: ScreenUtil().setWidth(10),
        right: 0,
        child: Row(
          children: <Widget>[
            Opacity(
                opacity: _password.length == 0 ? 0 : 1,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: cleanIcon,
                  onTap: () {
                    setState(() {
                      if(widget.controller != null)widget.controller.text = '';
                      setState(() {
                        _password = '';
                        widget.controller.text = '';
                      });
                      if(widget.onchange != null)widget.onchange(_password);
                    });
                  })),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: new Container(
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(8)),
                  child: inputType ? _showPasswordIcon : _hidePasswordIcon
              ),
              onTap: () {
                setState(() {
                  inputType = !inputType;
                });
              }),
          ],
        ));
  }


  void hideKeyboard(){
    _focusNode.unfocus();
  }
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return getIconInput();
  }
}
