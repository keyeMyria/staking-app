import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CheckBox extends StatefulWidget {
  final  changeCheckbox;

  CheckBox(
      {Key key,
        @required this.changeCheckbox,
      })
      : super(key: key);

  @override
  _CheckBoxState createState() {
    return new _CheckBoxState();
  }
}

class _CheckBoxState extends State<CheckBox>{
  bool _checkboxSelected = true;
  BoxDecoration _checkboxBg;

  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Padding(
          padding: EdgeInsets.only(top:ScreenUtil().setWidth(8), right: ScreenUtil().setWidth(8), bottom: ScreenUtil().setWidth(8)),
        child:Container(
          width: ScreenUtil().setWidth(20),
          height: ScreenUtil().setWidth(20),
          decoration: _checkboxBg,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LimitedBox(
                maxWidth: 14,
                maxHeight: 14,
                child: Checkbox(
                  value: _checkboxSelected,
                  activeColor: Color(0xff4551ff), //选中时的颜色
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                  onChanged: (value) {
                    setState(() {
                      _checkboxSelected = value;
                    });
                    _setCheckboxColor();
                    widget.changeCheckbox(value);
                  },
                )),
          ),
          alignment: Alignment.center,
        ),
      ),
      onTap: (){
        print('content');
        setState(() {
          _checkboxSelected = !_checkboxSelected;
          _setCheckboxColor();
          widget.changeCheckbox(_checkboxSelected);
        });
      },
    );
  }

  @override
  void initState() {
    _setCheckboxColor();
    super.initState();
  }
  _setCheckboxColor() async{
    if(_checkboxSelected) {
      await new Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _checkboxBg =BoxDecoration( //背景装饰
            gradient: RadialGradient(
              colors: [Color(0xff4551ff), Color(0xff4551ff)],
              center: Alignment.centerLeft,),
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil().setWidth(22)),
            ),
//            border: Border(top: BorderSide(color: Color(0xff4551ff), width: 2), right: BorderSide(color: Color(0xff4551ff), width: 2), bottom: BorderSide(color: Color(0xff4551ff), width: 2), left: BorderSide(color: Color(0xff4551ff), width: 2))
            border: Border.all(color: Color(0xff4551ff), width: 2)
        );
      });

    } else {
      setState(() {
        _checkboxBg =BoxDecoration( //背景装饰
            gradient: RadialGradient(
              colors: [Colors.transparent, Colors.transparent],
              center: Alignment.centerLeft,) ,
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil().setWidth(22)),
            ),
//            border: Border(top: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.2), width: 2), right: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.2), width: 2), bottom: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.2), width: 2), left: BorderSide(color: Color.fromRGBO(255, 255, 255, 0.2), width: 2))
            border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.2), width: 2)

        );
      });
    }
  }
}