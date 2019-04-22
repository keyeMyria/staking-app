import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// 弹窗样式可优化
bool isShowToast = true;
const timer = 2;
toast(String desc)  async{
  if(isShowToast) {
    isShowToast = false;
    Fluttertoast.showToast(
        msg: desc,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: timer,
        backgroundColor: Color(0xffd0d0d2),
        textColor: Colors.black,
        fontSize: 14
    );
    await new Future.delayed(const Duration(milliseconds: timer*1000));
    isShowToast = true;
  }
}