import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'component/submitButton.dart';
import 'component/appBarFactory.dart';
import 'package:flutter/services.dart';
import 'component/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/translation.dart';


class Receipt extends StatefulWidget {
  @override
  _Receipt createState() => new _Receipt();
}

class _Receipt extends State<Receipt> {
  int _btnStatus = 1;
  bool _isSubmit = false;
  String _accountAddress = "";
  Widget build(BuildContext context) {
    return new Container(
        width: ScreenUtil().setWidth(460),
        decoration: BoxDecoration(
          gradient: RadialGradient(
              colors: [Color(0xff323346), Color(0xff212231)],
              center: Alignment.bottomCenter,
              radius: 110),
        ),
        child: Stack(
          children: <Widget>[
            Container(
              height: ScreenUtil().setWidth(200),
              decoration: new BoxDecoration(
                image: new DecorationImage(
                    image:
                        new AssetImage('assets/images/receipt/bg_receipt.jpg'),
                    fit: BoxFit.fill),
              ),
              alignment: Alignment.center,
            ),
            Positioned(
              top: 135.0,
              child: Container(
                  height: ScreenUtil().setWidth(505),
                  width: ScreenUtil().setWidth(360),
                  decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new AssetImage(
                            'assets/images/receipt/bg_transfer.png'),
                        fit: BoxFit.fill),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: ScreenUtil().setWidth(11)),
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          "assets/images/receipt/receipt_logo.png",
                          width: ScreenUtil().setWidth(70),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: ScreenUtil().setWidth(29),
                              bottom: ScreenUtil().setWidth(24)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new SvgPicture.asset(
                                  'assets/images/receipt/icon_receipt_qr.svg',
                                  width: ScreenUtil().setWidth(16),
                                  height: ScreenUtil().setWidth(16)),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(12)),
                                child: Text(
                                  Translations.of(context).text('receipt.title'),
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(14),
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: ScreenUtil().setWidth(148),
                          child: Container(
                            width: ScreenUtil().setWidth(148),
                            height: ScreenUtil().setWidth(148),
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                              child: new QrImage(
                                data:
                                _accountAddress,
                                size: ScreenUtil().setWidth(116),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setWidth(24)),
                          alignment: Alignment.center,
                          child: Text(
                            _accountAddress,
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: ScreenUtil().setSp(10),
                              color: Color(0xFF83838d),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(top: ScreenUtil().setWidth(59)),
                          child: new SubmitButton(
                              text: Translations.of(context).text('receipt.copy_wallet_address'),
                              active: _btnStatus,
                              isSubmit: _isSubmit,
                              onSubmit: () async {
                                await Clipboard.setData(new ClipboardData(
                                    text:_accountAddress ));
                                setState(() {
                                  _isSubmit = false;
                                });
                                toast(Translations.of(context).text('receipt.copy_success_tip'));
                              }),
                        )
                      ],
                    ),
                  )),
            ),
            getTransparentAppBar(context, Translations.of(context).text('receipt.title'))
          ],
        ));
  }
  @override
  void initState() {
  _getAccountAddress();
    super.initState();
  }
  _getAccountAddress() async{
    var _prefs = await SharedPreferences.getInstance();
    if(_prefs.getString('account_address') != null) {
      setState(() {
      _accountAddress = _prefs.getString('account_address');
    });
    }

  }
}
