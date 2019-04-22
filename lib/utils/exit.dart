import './connectionListener.dart';

int _lastClickTime = 0;

Future<bool> exit() {
  int nowTime = new DateTime.now().microsecondsSinceEpoch; // 微秒
  if (_lastClickTime != 0 && nowTime - _lastClickTime > 2000) {
    ConnectionListener.dispose();
    return new Future.value(true);
  } else {
    _lastClickTime = nowTime;
    new Future.delayed(const Duration(milliseconds: 2000), () {
      _lastClickTime = 0;
    });
    return new Future.value(false);
  }
}