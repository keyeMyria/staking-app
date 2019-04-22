import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SubmitButton extends StatefulWidget {
  int active; // 按钮状态 0 不可点击样式  1 可点击样式   2 按下不放样式
  bool isSubmit;  // 禁止连续点击  父级传入函数里面需要再次置为false
  String text;
  final  onSubmit;
  int width;
  TextStyle textStyle = TextStyle();
  bool disabledSubmit;

  SubmitButton({
    Key key,
    this.text: '确定',
    this.active: 0,
    this.isSubmit: false,
    @required this.onSubmit,
    this.width = 208,
    this.textStyle,
    this.disabledSubmit = false
  }) : super(key: key);

  _SubmitButtonState createState() => new _SubmitButtonState();

}

class _SubmitButtonState extends State<SubmitButton> {
  static const List<Color> _defaultColor = [Color(0xff5f3ce3), Color(0xff4551ff)];
  static const List<Color> _activeColor = [Color(0xff453488), Color(0xff383E96)];
  static const List<Color> _disableColor = [Color(0xff404155), Color(0xff404155)];

  _setBtnBg(){
    if(widget.active == 0) {
      return _disableColor;
    }else if(widget.active == 1){
      return _defaultColor;
    }else if(widget.active == 2) {
      return _activeColor;
    }
  }

  Widget build(BuildContext context) {
    return new Listener(
        onPointerDown: (event){
          if(widget.active != 0) {
            setState(() {
              widget.active = 2;
            });
            _setBtnBg();
          }
        },
        onPointerUp: (event) async{
          if(widget.active != 0) {
            setState(() {
              widget.active = 1;
            });
            _setBtnBg();
            if(!widget.isSubmit) {
              setState(() {
                widget.isSubmit = true;
              });
              await Future.sync(widget.onSubmit);
              setState(() {
                widget.isSubmit = false;
              });
            }
          }else if(widget.disabledSubmit) {
            widget.onSubmit();
          }
        },
        child: Container(
          constraints: BoxConstraints.tightFor(width: ScreenUtil().setWidth(widget.width), height: ScreenUtil().setWidth(48)),
          decoration: BoxDecoration( //背景装饰
            gradient: RadialGradient( //背景径向渐变
                colors: _setBtnBg(),
                center: Alignment.centerLeft,
                radius: 5
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(ScreenUtil().setWidth(22)),
            ),
          ),

          alignment: Alignment.center,
          child:
            widget.isSubmit ?
              Container(
                constraints: BoxConstraints.tightFor(width: ScreenUtil().setWidth(24), height: ScreenUtil().setWidth(24)),
                child: new CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                alignment: Alignment.center,
              ) : Row(
              children: <Widget>[
                Container(
                  width: ScreenUtil().setWidth(172),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ScreenUtil.getInstance().setSp(16),
                      decoration:TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ).merge(widget.textStyle),
                  ),
                  alignment: Alignment.centerRight,
                ),
                Padding(
                  padding: EdgeInsets.only(left: ScreenUtil().setWidth(90)),
                  child: SvgPicture.asset(
                      'assets/images/login/arrow_right.svg',
                      width: ScreenUtil().setWidth(24),
                      height: ScreenUtil().setHeight(24)),
                )
              ],


          )

        )
    );
  }
}
