import 'package:flutter/material.dart';
import './eventBus.dart';
import 'package:connectivity/connectivity.dart';
import '../pages/component/toast.dart';
import './translation.dart';


class ConnectionListener{
  static var subscription;

  static init(BuildContext context) {
    bus.on('disConnected', (state) {
      toast(Translations.of(context).text('error.network'));
    });
    _checkConnection();
    subscription = Connectivity().onConnectivityChanged.listen(_connectionChange);
  }

  static void _connectionChange(ConnectivityResult result) {
    _checkConnection();
  }

  static _checkConnection() async {
    var result = await (Connectivity().checkConnectivity());
    if (result != ConnectivityResult.mobile && result != ConnectivityResult.wifi) {
      bus.emit('disConnected');
    } else {
      bus.emit('connected');
    }
  }

  // 获取网络状态，true表示有连接， false表示连接断了
  static Future<bool> getConnectState() async{
    var result = await (Connectivity().checkConnectivity());
    if (result != ConnectivityResult.mobile && result != ConnectivityResult.wifi) {
      return Future.value(false);
    }
    return Future.value(true);
  }

  static dispose() {
    subscription.cancel();
    bus.off('disConnected');
  }
}