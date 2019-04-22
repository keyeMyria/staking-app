import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

Widget animalIcon = SvgPicture.asset(
  'assets/images/common/icon_loading.svg',
  width: 20,
  height: 20,
);

/// 金色校园Header
class ListRefreshHeader extends RefreshHeader {
  ListRefreshHeader({
    @required GlobalKey<RefreshHeaderState> key,
  }) : super(key: key, refreshHeight: 50.0);

  @override
  ListRefreshHeaderState createState() => ListRefreshHeaderState();
}

class ListRefreshHeaderState extends RefreshHeaderState<ListRefreshHeader> {
  // 太阳旋转值
  double _sunRotateValue;
  // 旋转计时器
  Timer _sunRotateTimer;
  // 是否旋转太阳
  bool _isRotateSun;

  // 初始化
  @override
  void initState() {
    super.initState();
    _sunRotateValue = widget.refreshHeight;
    _isRotateSun = false;
  }

  // 正在刷新
  @override
  void onRefreshing() {
    super.onRefreshing();
    _isRotateSun = true;
    _sunRotateValue = widget.refreshHeight;
    rotateSun();
  }

  // 旋转太阳
  void rotateSun() {
    _sunRotateTimer = Timer(Duration(milliseconds: 10), () {
      setState(() {
        _sunRotateValue += 2;
        rotateSun();
      });
    });
  }

  // 刷新结束
  @override
  void onRefreshEnd() {
    super.onRefreshEnd();
    _isRotateSun = false;
    if (_sunRotateTimer != null) {
      _sunRotateTimer.cancel();
    }
  }

  // 高度更新
  @override
  void updateHeight(double newHeight) {
    super.updateHeight(newHeight);
  }

  @override
  void dispose() {
    super.dispose();
    if (_sunRotateTimer != null) {
      _sunRotateTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: this.height,
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          new SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              margin: EdgeInsets.only(
                top: this.height < widget.refreshHeight - 20.0
                  ? widget.refreshHeight / 2 - this.height / 2
                  : 10.0),
              child: Center(
                child: Container(
                  child: Align(
                    alignment: Alignment(0, -1),
                    child: Transform.rotate(
                      child: animalIcon,
                      angle: (_isRotateSun ? _sunRotateValue : this.height) /
                        8 / pi,
                    ),
                  )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// 金色校园Footer
class ListLoadFooter extends RefreshFooter {
  ListLoadFooter({
    @required GlobalKey<RefreshFooterState> key,
  }) : super(key: key, loadHeight: 50.0);

  @override
  ListLoadFooterState createState() => ListLoadFooterState();
}

class ListLoadFooterState extends RefreshFooterState<ListLoadFooter> {

  // 太阳旋转值
  double _sunRotateValue;
  // 旋转计时器
  Timer _sunRotateTimer;
  // 是否旋转太阳
  bool _isRotateSun;

  // 初始化
  @override
  void initState() {
    super.initState();
    _sunRotateValue = widget.loadHeight;
    _isRotateSun = false;
  }

  // 正在刷新
  @override
  void onLoading() {
    super.onLoading();
    _isRotateSun = true;
    _sunRotateValue = widget.loadHeight;
    rotateSun();
  }

  // 旋转太阳
  void rotateSun() {
    _sunRotateTimer = Timer(Duration(milliseconds: 10), () {
      setState(() {
        _sunRotateValue += 2;
        rotateSun();
      });
    });
  }

  // 刷新结束
  @override
  void onLoadEnd() {
    super.onLoadEnd();
    _isRotateSun = false;
    if (_sunRotateTimer != null) {
      _sunRotateTimer.cancel();
    }
  }

  // 高度更新
  @override
  void updateHeight(double newHeight) {
    super.updateHeight(newHeight);
  }

  @override
  void dispose() {
    super.dispose();
    if (_sunRotateTimer != null) {
      _sunRotateTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: this.height,
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          new SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              margin: EdgeInsets.only(
                top: this.height < widget.loadHeight - 20.0
                  ? widget.loadHeight / 2 - this.height / 2
                  : 10.0),
              child: Center(
                child: Container(
                  child: Align(
                    alignment: Alignment(0, 0),
                    child: Transform.rotate(
                      child: animalIcon,
                      angle: (_isRotateSun ? _sunRotateValue : this.height) /
                        8 / pi,
                    ),
                  )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
