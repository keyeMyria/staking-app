import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import '../pages/component/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './translation.dart';

class Http {
  static BuildContext context;

  static final Dio _dio = new Dio(new BaseOptions(
    baseUrl: DotEnv().env['BASE_URL'],
    // 连接服务器超时时间，单位是毫秒.
    connectTimeout: 30000,
    // 接收数据的最长时限.
    receiveTimeout: 30000,
    headers: {
      "user-agent": "dio",
    },
    contentType: ContentType.json,
    // Transform the response data to a String encoded with UTF8.
    // The default value is [ResponseType.JSON].
    responseType: ResponseType.json,
  ));

  static String userToken;

  Http() {
    Http._dio.options.headers.remove('Authorization');
  }
  Http.auth() {
    if (Http.userToken != null) {
      Http._dio.options.headers["Authorization"] = 'bearer ' + Http.userToken;
    }
  }

  _handleError(e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    /// e.response: 响应信息, 如果错误发生在在服务器返回数据之前，它为 `null`
    if (e.response != null) {
      print('错误代码：' + e.response.statusCode.toString() + '错误信息：' + e.response.data.toString());
      updateHeaderToken(e.response);
      if (e.response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login',
          (Route<dynamic> route) => false
        );
      } else if (e.response.statusCode == 500) {
        toast(Translations.of(context).text('error.http500'));
      } else if (e.response.statusCode == 429) { // 请求过于频繁
        toast(Translations.of(context).text('error.http429'));
      } else {
        toast(e.response.data['error'].toString());
      }
    } else { // Something happened in setting up or sending the request that triggered an Error
      if (e.type == DioErrorType.DEFAULT) {
        if (e.error.message == "Connection failed") {
          toast(Translations.of(context).text('error.network'));
        }
      } else if (e.type == DioErrorType.CONNECT_TIMEOUT || e.type == DioErrorType.RECEIVE_TIMEOUT) {
        toast(Translations.of(context).text('error.timeout'));
      } else {
        toast(e.message.toString());
      }
    }
  }

  Future get(url, [Map data, Options options]) async {
    Response response;
    try {
      response = await Http._dio.get(url, queryParameters: data, options: options);
      updateHeaderToken(response);
    } on DioError catch (e) {
      this._handleError(e);
    }

    if(response != null && response.data == ""){
      return null;
    }else {
      return response != null ? response.data['data'] : Future.value({"error": null});
    }
  }

  Future post(url, [Map data, Options options]) async {
    Response response;
    try {
      response = await Http._dio.post(url, data: data, options: options);
      updateHeaderToken(response);
    } on DioError catch (e) {
      this._handleError(e);
    }
    return response != null ? response.data['data'] : Future.value({"error": null});
  }

  static setHeader({token}) async{
    var _prefs;
    if( token == null){
     _prefs = await SharedPreferences.getInstance();
     userToken = _prefs.getString('token');
    }else {
      userToken = token;
    }
  }

  static setContext(context) {
    Http.context = context;
  }
  // 设置header locale
  static setHeaderLocale(String localeStr) {
    _dio.options.headers['locale'] = localeStr;
  }

  // 等登录时间过期后服务器返回 新token , 用来刷新 旧token ,保持长期登录状态
  updateHeaderToken(response) async{
    if(response != null){
      if(response.headers["Authorization"] != null) {
        var _tmpToken =  response.headers["Authorization"][0].toString().substring(5);
        userToken = _tmpToken;
        var _prefs = await SharedPreferences.getInstance();
        _prefs.setString("token", _tmpToken);
      }
    }
  }
}
