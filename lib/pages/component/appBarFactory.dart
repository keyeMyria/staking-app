import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

AppBar getAppBar(BuildContext context, String text, {Widget bottom}) {
  return AppBar(
    leading: GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(24)
        ),
        child: SvgPicture.asset(
          'assets/images/common/icon_return.svg',
          width: ScreenUtil().setWidth(32),
          height: ScreenUtil().setWidth(32),
        ),
      ),
      onTap: () {Navigator.pop(context);},
    ),
    title: Text(
      text,
      style: TextStyle(
        fontSize: ScreenUtil().setSp(18),
        fontWeight: FontWeight.normal
      ),
    ),
    centerTitle: true,
    backgroundColor: Color(0xff323346),
    elevation: 0,
    automaticallyImplyLeading: false,
    bottom: bottom,
  );
}

/// 使用此appbar时需要给后面的widget每个加 56 的高度偏移
Widget getTransparentAppBar(BuildContext context, String text) {
  double statusBarHeight = MediaQuery.of(context).padding.top;
  return Positioned(
    top: statusBarHeight,
    left: 0,
    right: 0,
    child: Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtil().setWidth(24)
      ),
      height: 56,
      child: Stack(
        alignment: AlignmentDirectional(0, 0),
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            alignment: Alignment(0, 0),
            child: Text(text, style: TextStyle(
              fontSize: ScreenUtil().setSp(18),
              color: Colors.white,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none,
            )),
          ),
          Positioned(
            left: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                child: SvgPicture.asset(
                  'assets/images/common/icon_return.svg',
                  width: ScreenUtil().setWidth(32),
                  height: ScreenUtil().setWidth(32),
                ),
              ),
              onTap: () {Navigator.pop(context);},
            ),
          )
        ],
      ),
    )
  );
}

