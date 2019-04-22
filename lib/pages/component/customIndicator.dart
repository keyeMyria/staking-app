/// 漏斗旋转loading
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';


class CustomIndicator extends StatefulWidget {

  Widget child;
  bool isLoading = true;

  CustomIndicator({
    Key key,
    this.child,
    this.isLoading
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new CustomIndicatorState();
}

class CustomIndicatorState extends State<CustomIndicator> with SingleTickerProviderStateMixin {

  Widget child = new SvgPicture.asset(
    'assets/images/common/img_loading.svg',
    width: ScreenUtil().setWidth(40),
    height: ScreenUtil().setHeight(47),
  );

  Animation<double> _angleAnimation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = new AnimationController(
      duration: const Duration(milliseconds: 1000), vsync: this);
    _angleAnimation = new Tween(begin: 0.0, end: 360.0).animate(_controller)
      ..addListener(() {
        setState(() {
          // the state that has changed here is the animation object’s value
        });
      });

    _angleAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.isLoading == true) {
          _controller.repeat();
        }
      } else if (status == AnimationStatus.dismissed) {
        if (widget.isLoading == true) {
          _controller.forward();
        }
      }
    });

    _controller.forward();
  }

  Widget _buildAnimation() {
    double angleInDegrees = _angleAnimation.value;
    return new Transform.rotate(
      angle: angleInDegrees / 360 * 2 * pi,
      child: new Container(
        child: widget.child ?? child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading == true) {
      return new Center(
        child: _buildAnimation(),
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

}