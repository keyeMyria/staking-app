import 'package:flutter/material.dart';
import '../../utils/translation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 弹窗样式可优化

Future<void> alert(BuildContext context, {
  String desc,
  String btn="",
  String close="",
  String title="",  // 需要title 传入title
  bool showClose = false,
  Function callback,
  Function closeCb,
  disableBtnCb: false // 禁用确定按钮的pop
})  {
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      Widget _alertWidget;
      if(showClose == false && title == ''){
        _alertWidget = CupertinoAlertDialog(
          content: Text(desc),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(btn == '' ? Translations.of(context).text('alert_module_confirm') : btn,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(16)
                ),
              ),
              onPressed: (){
                if(disableBtnCb == false){
                  Navigator.of(context).pop();
                }
                if (callback != null) callback();
              },
            )
          ],
        );
      }else if( showClose == true){
        _alertWidget = CupertinoAlertDialog(
          content: Text(desc),
          actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(close == '' ? Translations.of(context).text('alert_module_cancel') : '',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(16)
                  ),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                  if (closeCb != null) closeCb();
                },
              ),
            CupertinoDialogAction(
              child: Text(btn == '' ? Translations.of(context).text('alert_module_confirm') : btn,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(16)
                ),
              ),
              onPressed: (){
                Navigator.of(context).pop();
                if (callback != null) callback();
              },
            )
          ],
        );
      }
      if(title != ''){
        _alertWidget = CupertinoAlertDialog(
          title: new Text(title),
          content: Text(desc),
          actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text(close == '' ? Translations.of(context).text('alert_module_cancel') : '',
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(16)
                  ),),
                onPressed: (){
                  Navigator.of(context).pop();
                  if (closeCb != null) closeCb();
                },
              ),
            CupertinoDialogAction(
              child: Text(btn == '' ? Translations.of(context).text('alert_module_confirm') : btn,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(16)
                ),
              ),
              onPressed: (){
                Navigator.of(context).pop();
                if (callback != null) callback();
              },
            )
          ],
        );
      }
      return _alertWidget;
    },
  );
}