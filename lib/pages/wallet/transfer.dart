import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../component/input.dart';
import '../component/submitButton.dart';
import '../component/appBarFactory.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/http.dart';
import 'dart:math';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import '../component/toast.dart';
import 'package:decimal/decimal.dart';
import '../../utils/translation.dart';
import '../component/alertModule.dart';
import '../../utils/loading.dart';

class Transfer extends StatefulWidget {
  @override
  TransferState createState() => new TransferState();
}

class TransferState extends State<Transfer> {

  final Widget _moneyTypeIcon = new SvgPicture.asset(
    'assets/images/transfer/icon_arrow1.svg',
  );
  final Widget _scanIcon = new SvgPicture.asset(
    'assets/images/transfer/icon_scanning.svg',
  );
  final Widget ethIcon = new SvgPicture.asset(
    'assets/images/home/icon_eth.svg',
  );
  final Widget bnbIcon = Image.asset(
    'assets/images/home/icon_bizhong.png',
    width: ScreenUtil().setWidth(24),
    height: ScreenUtil().setWidth(24),
  );

  GlobalKey<InputState> _inputAddressKey = new GlobalKey();
  GlobalKey<InputState> _inputNumKey = new GlobalKey();
  TextEditingController _toController = new TextEditingController();
  TextEditingController _amountController = new TextEditingController();
  GlobalKey _formKey= new GlobalKey<FormState>();

  TextStyle _fieldStyle = TextStyle(
    fontSize: 14
  );
  TextStyle _hintStyle = TextStyle(
    color: Color.fromRGBO(255, 255, 255, 0.5),
    fontSize: 14
  );
  EdgeInsets _inputPadding = EdgeInsets.only(
    top: ScreenUtil().setWidth(6),
    bottom: ScreenUtil().setWidth(20)
  );

  List coinList = [];
  Map selectedCoin;
  String to;
  String amount;
  Map feeObj = {
    'asset': {},
    'gas': {}
  };
  int _buttonState = 0;
  bool _isSubmit = false;
  Loading loading = new Loading();

  @override
  void initState() {
    super.initState();
    _ajaxCoinList();
    _toController.addListener((){
      to = _toController.text;
      _judgeButtonState();
    });
    _amountController.addListener((){
      amount = _amountController.text;
      _judgeButtonState();
    });
  }

  Future<Null> _ajaxCoinList() async{
    Future.delayed(Duration(seconds: 0), () {
      loading.state.show();
    });
    var page = 1;
    var param = {'page': page};
    var res = await Http.auth().get('/ethereum/balance', param);
    setState(() {
      coinList = res['item'] ?? [];
    });
    loading.state.dismiss();
    return;
  }

  // 选择币种
  _selectCoin(BuildContext context, int index) {
    setState(() {
      selectedCoin = coinList[index];
      _ajaxGasPrice();
      _judgeButtonState();
    });
    Navigator.pop(context);
  }

  _ajaxGasPrice() async{
    var res = await Http().get('/ethereum/gas-limit/${selectedCoin['AssetId']}');
    setState(() {
      if (res != null) feeObj = res;
    });
  }

//  _amountFocus(BuildContext context) {
//    if (selectedCoin == null) {
//      print(Translations.of(context).text('transfer.sel_coin_tip'));
//      return true; // false
//    }
//    return false;
//  }

  /// 判断字符串是否为 null 或 空字符串
  /// 当有值时返回true
  bool _judgeEmpty(String str) {
    return str != null && str.isNotEmpty;
  }

  // 判断转账按钮是否可以点击
  _judgeButtonState() {
    if ((selectedCoin != null && _judgeEmpty(to) && _judgeEmpty(amount) && feeObj.isNotEmpty) == true) {
      setState(() => _buttonState = 1); // 可以点击
    } else {
      setState(() => _buttonState = 0);
    }
  }

  String _calcAmount() {
    if (selectedCoin == null) return '';
    var amount = (Decimal.parse(selectedCoin['Value']) /
      Decimal.parse(pow(10, selectedCoin['Decimal']).toString())).toString();
    if (amount.length - 1 < 9) {
      return amount + ' ' + selectedCoin['Symbol'];
    } else {
      String limitAmount = amount.substring(0, 9) + '...';
      return limitAmount + ' ' + selectedCoin['Symbol'];
    }
  }

  String _getFee() {
    if (feeObj['asset'].isEmpty || feeObj['gas'].isEmpty) return '';
    var value = Decimal.parse(feeObj['gas']['GasPrice'])
      * Decimal.parse(feeObj['gas']['GasLimit'].toString())
      / Decimal.parse(pow(10, feeObj['asset']['Decimal']).toString());
    return value.toString() + ' ' + feeObj['asset']['Symbol'];
  }

  // 获取币种icon
  Widget _getCoinIcon(Map item) {
    if (item['Name'] == 'BNB') {
      return bnbIcon;
    } else {
      return SizedBox(
        width: ScreenUtil().setWidth(24),
        height: ScreenUtil().setWidth(24),
        child: ethIcon,
      );
    }
  }

  _settingModalBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(ScreenUtil().setWidth(16)),
              topRight: Radius.circular(ScreenUtil().setWidth(16))
            ),
            color: Color(0xff404155),
          ),
          padding: EdgeInsets.symmetric(
            vertical: ScreenUtil().setWidth(28),
            horizontal: ScreenUtil().setWidth(24)
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: coinList.length,
            separatorBuilder: (BuildContext sepBc, int index) {
              return Container(
                height: 1,
                color: Color(0xffbdbdbd).withOpacity(0.1),
              );
            },
            itemBuilder: (BuildContext itemBc, int index) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: ScreenUtil().setWidth(56),
                  child: Row(
                    children: <Widget>[
                      _getCoinIcon(coinList[index]),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: ScreenUtil().setWidth(2),
                                ),
                                child: Text(
                                  coinList[index]['Symbol'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(14),
                                    height: 1.14
                                  ),
                                ),
                              ),
                              Text(
                                coinList[index]['Name'],
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(12),
                                  height: 1.16,
                                  color: Color.fromRGBO(255, 255, 255, 0.5)),
                              )
                            ],
                          ),
                        ))
                    ],
                  ),
                ),
                onTap: () => _selectCoin(context, index)
              );
            }),
        );
      }
    );
  }

  Future _scan(BuildContext context) async{
    try {
      String barcode = await BarcodeScanner.scan();
      _toController.text = barcode;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        toast(Translations.of(context).text('transfer.permit_refused'));
      } else {
        toast('${Translations.of(context).text('transfer.unknown_error')} $e');
      }
    } on FormatException{
      toast(Translations.of(context).text('transfer.return_error'));
    } catch (e) {
      toast('${Translations.of(context).text('transfer.unknown_error')} $e');
    }
  }

  // 验证输入的代币数量格式a
  bool _validAmount(BuildContext context, String amount) {
    RegExp regExp = new RegExp(r"[0-9]+\.[0-9]+|\d*");
    var result = regExp.stringMatch(amount);
    if (amount != result) {
      toast(Translations.of(context).text('transfer.coin_num_error'));
    }
    return amount == result;
  }

  _submit(BuildContext context) async{
    alert(
      context,
      desc: Translations.of(context).text('transfer.confirm_trans') + '\n$amount ${selectedCoin['Symbol']}',
      showClose: true,
      callback: () async{
        if (!_validAmount(context, amount)) return;
        loading.state.show();
        var param = {
          "asset_id": selectedCoin['AssetId'],
          "amount": (Decimal.parse(amount) * Decimal.parse(pow(10, selectedCoin['Decimal']).toString())).toString(),
          "gas": feeObj['gas']['GasLimit'].toString(),
          "to": to
        };
        var res = await Http.auth().post('/ethereum/transfer', param);
        loading.state.dismiss();
        if (res['hash'] != null) {
          toast(Translations.of(context).text('transfer.transfer_success'));
          setState(() => _isSubmit = false);
          Navigator.pop(context);
        } else {
          setState(() => _isSubmit = false);
        }
      },
      closeCb: () {
        setState(() {
          _isSubmit = false;
        });
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, Translations.of(context).text('transfer.title')),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white
        ),
        child: new Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: GestureDetector(
                onTap: () {
                  _inputAddressKey.currentState.hideKeyboard();
                  _inputNumKey.currentState.hideKeyboard();
                },
                child: new Container(
                  height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top - 56,
                  decoration: BoxDecoration(
                    gradient: new LinearGradient(
                      begin: const Alignment(0.0, -1.0),
                      end: const Alignment(0.0, 1.0),
                      colors: <Color>[
                        const Color(0xff323346),
                        const Color(0xff212231)
                      ],
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    ScreenUtil().setWidth(24),
                    ScreenUtil().setWidth(26),
                    ScreenUtil().setWidth(24),
                    0
                  ),
                  child: Form(
                    key: _formKey, //设置globalKey，用于后面获取FormState
//            autovalidate: true,
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(Translations.of(context).text('transfer.field1'), style: _fieldStyle),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xffbdbdbd).withOpacity(0.3),
                                        width: 1
                                      )
                                    )
                                  ),
                                  padding: _inputPadding,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      selectedCoin == null ?
                                      Text(Translations.of(context).text('transfer.placeholder1'), style: _hintStyle) :
                                      Text(selectedCoin['Name']),
                                      SizedBox(
                                        width: ScreenUtil().setWidth(24),
                                        height: ScreenUtil().setWidth(24),
                                        child: _moneyTypeIcon,
                                      )
                                    ],
                                  ),
                                ),
                                onTap: () => _settingModalBottomSheet(context)
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(24)
                                ),
                                child: Text(Translations.of(context).text('transfer.field2'), style: _fieldStyle),
                              ),
                              Input(
                                key: _inputAddressKey,
                                controller: _toController,
                                rightWidget: _scanIcon,
                                hintText: Translations.of(context).text('transfer.placeholder2'),
                                rightTap: () => _scan(context),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(24)
                                ),
                                child: Text(Translations.of(context).text('transfer.field3'), style: _fieldStyle),
                              ),
                              Input(
                                key: _inputNumKey,
                                keyboardType: TextInputType.number,
                                controller: _amountController,
                                rightWidget: Translations.of(context).text('transfer.field3_supply') + ' ${_calcAmount()}',
                                hintText: Translations.of(context).text('transfer.placeholder3'),
//                        focusCb: () => _amountFocus(context),
                              ),
                              selectedCoin == null ? Container() :
                              Wrap(
                                direction: Axis.vertical,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(24)
                                    ),
                                    child: Text(Translations.of(context).text('transfer.field4'), style: _fieldStyle),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(4)
                                    ),
                                    child: Text(Translations.of(context).text('transfer.field4_supply') + ' ${_getFee()}', style: _fieldStyle,),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment(0, 1),
                                  padding: EdgeInsets.only(
                                    bottom: ScreenUtil().setHeight(80)
                                  ),
                                  child: SubmitButton(
                                    active: _buttonState,
                                    isSubmit: _isSubmit,
                                    text: Translations.of(context).text('transfer.button'),
                                    onSubmit: () => _submit(context),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  )

                ),
              ),
            ),
            loading
          ],
        ),
      )
    );
  }
}