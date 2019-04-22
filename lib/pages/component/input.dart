import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class Input extends StatefulWidget {
  final TextEditingController controller;
  final rightWidget;
  final String hintText;
  final TextInputType keyboardType;
  final Function rightTap;
  final Function focusCb;

  Input({
    Key key,
    this.controller,
    this.rightWidget = '',
    this.hintText = '',
    this.keyboardType = TextInputType.text,
    this.rightTap,
    this.focusCb
  }) : super(key: key);

  @override
  InputState createState() => new InputState();
}

class InputState extends State<Input> {

  FocusNode _focus = new FocusNode();

  TextStyle _hintStyle = TextStyle(
    color: Color.fromRGBO(255, 255, 255, 0.5),
    fontSize: 14
  );
  EdgeInsets _inputPadding = EdgeInsets.only(
    top: ScreenUtil().setWidth(6),
    bottom: ScreenUtil().setWidth(20)
  );

  @override
  initState() {
    super.initState();
    _focus.addListener(() {
      if (widget.focusCb != null)  {
        widget.focusCb();
        _focus.unfocus();
      }
    });
  }

  Widget getStringInput() {
    return TextFormField(
      keyboardType: widget.keyboardType,
      style: TextStyle(color: Colors.white),
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: _hintStyle,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffbdbdbd).withOpacity(0.3)),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        suffix: Text(widget.rightWidget),
        suffixStyle: _hintStyle,
        contentPadding: _inputPadding
      ),
      focusNode: _focus
    );
  }

  Widget getIconInput() {
    return Stack(
      children: <Widget>[
        Positioned(
          child: TextFormField(
            keyboardType: widget.keyboardType,
            style: TextStyle(color: Colors.white),
            controller: widget.controller,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.fromLTRB(
                0.0, 6.9, ScreenUtil().setWidth(24), 23.0
              ),
              hintText: widget.hintText,
              hintStyle: _hintStyle,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xffbdbdbd).withOpacity(0.3)),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
            focusNode: _focus
          ),
        ),
        Positioned(
          top: ScreenUtil().setWidth(3),
          right: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: ScreenUtil().setWidth(24),
              height: ScreenUtil().setWidth(24),
              child: widget.rightWidget,
            ),
            onTap: widget.rightTap ?? null,
          )
        )
      ],
    );
  }
  void hideKeyboard(){
    _focus.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rightWidget is String) {
      return getStringInput();
    } else {
      return getIconInput();
    }
  }
}