import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Loading extends StatefulWidget {
  _LoadingState state;
  bool defaultState;
  bool type; /// 作为loading 或者 蒙层，  true为loading  false为蒙层
  Loading({
    Key key,
    this.defaultState: false,
    this.type: true
  }) : super(key: key);

  @override
  _LoadingState createState() {
    state = new _LoadingState();
    return state;
  }
}

class _LoadingState extends State<Loading> {

  @override
  void initState() {
    super.initState();
  }

  void dismiss() {
    setState(() {
      widget.defaultState = false;
    });
  }

  void show() {
    setState(() {
      widget.defaultState = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.defaultState) {
      return new Scaffold(
        body: new Stack(
          children: <Widget>[
            widget.type == true ?
            new Center(
              child: Container(
                width: ScreenUtil().setWidth(60),
                height: ScreenUtil().setWidth(60),
                decoration: new BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  borderRadius: new BorderRadius.all(new Radius.circular(10))
                ),
                child: CupertinoActivityIndicator(),
              ),
            )
           : Container()
          ],
        ));
    } else {
      return new Container();
    }
  }
}
