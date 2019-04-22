import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../component/submitButton.dart';
import '../../pages/component/toast.dart';
import '../component/appBarFactory.dart';
import '../component/input.dart';
import '../component/checkbox.dart';
import '../../utils/translation.dart';
import 'package:decimal/decimal.dart';
import '../component/alertModule.dart';
import '../../utils/translation.dart';
import '../../utils/http.dart';
import 'dart:math';
import '../../utils/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/helper.dart';


class BuyFinancial extends StatefulWidget {
  Map detailObj = {};

  BuyFinancial({Key key, this.detailObj}) : super(key: key);
  @override
  _BuyFinancialState createState() {
    return new _BuyFinancialState();
  }
}

class _BuyFinancialState extends State<BuyFinancial> {
  TextEditingController _amountController = new TextEditingController();
  TextStyle _fieldStyle = TextStyle(fontSize: 14);
  TextStyle _titleStyle = TextStyle(fontSize: 14, color: Colors.white);
  bool _checkboxSelected = true;
  GlobalKey<InputState> inputKey = new GlobalKey();
  String payBack = "--";
  String payBackNum = '';
  List coinList;
  String selectedCoin = "0.00";
  Loading loading = new Loading();

  getEndDate() {
    DateTime localTime = DateTime.now().toLocal();
    localTime = localTime
        .add(new Duration(days: int.parse(widget.detailObj['invest_time'])));
    return localTime.year.toString() +
        '-' +
        localTime.month.toString().padLeft(2, '0') +
        '-' +
        localTime.day.toString().padLeft(2, '0');
  }

  _getPayBack(num) {
    String tmpPayBack = (Decimal.parse(num.toString()) *
            Decimal.parse(widget.detailObj['invest_time'].toString()) *
            Decimal.parse(widget.detailObj["interest_rate"].toString()) /
            Decimal.parse("100"))
        .toString();
    setState(() {
      payBackNum = tmpPayBack;
      payBack = tmpPayBack + widget.detailObj["asset_symbol"];
    });
  }

  String getYearRate() {
    return (Decimal.parse(widget.detailObj['interest_rate'].toString()) *
                Decimal.fromInt(365))
            .toString() +
        "%";
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(
            context, Translations.of(context).text('buy_financial.title')),
        resizeToAvoidBottomPadding: false,
        body: DefaultTextStyle(
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.3),
              fontSize: ScreenUtil().setSp(14),
            ),
            child: Stack(
              children: <Widget>[
                new Container(
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                        begin: const Alignment(0.0, -1.0),
                        end: const Alignment(0.0, 1.0),
                        colors: [Color(0xff323346), Color(0xff212231)],
                      ),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        inputKey.currentState.hideKeyboard();
                      },
                      child: Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(24),
                              top: ScreenUtil().setWidth(25),
                              right: ScreenUtil().setWidth(24),
                              bottom: ScreenUtil().setWidth(0)),
                          child: Column(children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(0)),
                              child: Text(
                                  Translations.of(context)
                                      .text('buy_financial.buy_price'),
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white)),
                            ),
                            Input(
                              key: inputKey,
                              keyboardType: TextInputType.number,
                              controller: _amountController,
                              rightWidget: Translations.of(context)
                                      .text('buy_financial.balance') +
                                  selectedCoin,
                              hintText: Translations.of(context)
                                  .text('buy_financial.buy_price_placeholder'),
//                        focusCb: () => _amountFocus(context),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(40)),
                              child: Text(
                                  Translations.of(context)
                                      .text('buy_financial.investment_time'),
                                  style: _fieldStyle),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4)),
                              child: Text(
                                  widget.detailObj['invest_time'].toString() +
                                      Translations.of(context)
                                          .text('buy_financial.time_unit') +
                                      '（' +
                                      Translations.of(context)
                                          .text('buy_financial.end_time') +
                                      getEndDate() +
                                      '）',
                                  style: _titleStyle),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(24)),
                              child: Text(
                                  Translations.of(context)
                                      .text('buy_financial.income_text'),
                                  style: _fieldStyle),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4)),
                              child: Text(getYearRate(), style: _titleStyle),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(24)),
                              child: Text(
                                  Translations.of(context)
                                      .text('buy_financial.pay_back'),
                                  style: _fieldStyle),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4),
                                  bottom: ScreenUtil().setWidth(24)),
                              child: Text(payBack, style: _titleStyle),
                            ),
                            Row(
//                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                CheckBox(changeCheckbox: _getCheckbox),
                                Container(
                                    width: ScreenUtil().setWidth(280),
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 0),
                                      child: Wrap(
                                        children: <Widget>[
                                          Text(
                                              Translations.of(context)
                                                  .text('register.agree'),
                                              style: TextStyle(
                                                  color: Color(0xffffffff),
                                                  fontSize:
                                                      ScreenUtil().setSp(12))),
                                          GestureDetector(
                                              onTap: () => Navigator.pushNamed(
                                                  context,
                                                  '/management-agreement'),
                                              child: Text(
                                                  Translations.of(context).text(
                                                      'buy_financial.wallet_protocol'),
                                                  style: TextStyle(
                                                      color: Color(0xff4551ff),
                                                      fontSize: ScreenUtil()
                                                          .setSp(12))))
                                        ],
                                      ),
                                    ))
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(64)),
                              child: SubmitButton(
                                text: Translations.of(context)
                                    .text('buy_financial.confirm_buy'),
                                active: 1,
                                onSubmit: _buyFinancial,
                              ),
                              alignment: Alignment.center,
                            ),
                          ], crossAxisAlignment: CrossAxisAlignment.start),
                        ),
                      ),
                    )),
                loading
              ],
            )));
  }

  @override
  void initState() {
    _getUserBalance();
    _amountController.addListener(() {
      try {
        if (_amountController.text != "") {
          if(Decimal.parse(_amountController.text) -
              Decimal.parse(widget.detailObj["max_invest"]) >
              Decimal.parse("0")){
            setState(() {
              payBack = "--";
            });
          }else if(Decimal.parse(_amountController.text) -
              Decimal.parse(widget.detailObj["min_invest"]) <
              Decimal.parse('0') || _amountController.text.indexOf('.') == _amountController.text.length-1){
            setState(() {
              payBack = "--";
            });
          }else if (Decimal.parse(_amountController.text) -
                      Decimal.parse(widget.detailObj["min_invest"]) >=
                  Decimal.parse('0') &&
              Decimal.parse(_amountController.text) <=
                  Decimal.parse(widget.detailObj["max_invest"])) {
            _getPayBack(_amountController.text);
          }
        } else {
          setState(() {
            payBack = "--";
          });
        }
      } catch (val) {}
    });
    super.initState();
  }

  _getCheckbox(val) {
    setState(() {
      _checkboxSelected = val;
    });
  }

  _getUserBalance() async {
    var res = await Http.auth().get('/ethereum/balance');
    setState(() {
      coinList = res['item'] ?? [];
      for (Map val in coinList) {
        if (val['AssetId'] == widget.detailObj['asset_id']) {
          selectedCoin = (Decimal.parse(val['Value'].toString()) /
                  Decimal.parse(pow(10, val['Decimal']).toString()))
              .toString();
          if (selectedCoin.length - 1 < 9) {
            selectedCoin = selectedCoin + widget.detailObj['asset_symbol'];
          } else {
            String limitAmount = selectedCoin.substring(0, 9) + '...';
            selectedCoin = limitAmount + ' ' + widget.detailObj['asset_symbol'];
          }
        }
      }
    });
  }

  _buyFinancial() async{
    if(_amountController.text.indexOf('.') == _amountController.text.length-1) {
      toast(Translations.of(context).text('buy_financial.format_error'));
    }else {
      try {
        var curLanguage = await Helper.getCurLanguage(context);
        if (_amountController.text == "") {
          toast(Translations.of(context)
              .text('buy_financial.buy_price_placeholder'));
        } else if (Decimal.parse(_amountController.text) <
            Decimal.parse(widget.detailObj["min_invest"])) {
          toast(Translations.of(context).text('buy_financial.more_the_min') +
              widget.detailObj["min_invest"] +
              widget.detailObj["asset_symbol"]);
        } else if (Decimal.parse(_amountController.text) >
            Decimal.parse(widget.detailObj["max_invest"])) {
          var tmpToastText = Translations.of(context).text('buy_financial.more_then_max') +
              widget.detailObj["max_invest"] +
              widget.detailObj["asset_symbol"];
          if(curLanguage == 'ko') {
            tmpToastText = Translations.of(context).text('buy_financial.more_then_max_1') +
                widget.detailObj["max_invest"] +
                widget.detailObj["asset_symbol"] + Translations.of(context).text('buy_financial.more_then_max_2');
          }
          toast(tmpToastText);
        } else if (_checkboxSelected != true) {
          toast(Translations.of(context).text('buy_financial.agree_privacy'));
        } else {
          String confirmText =Translations.of(context).text('buy_financial.confirm_buy') + " " +
              _amountController.text +
              widget.detailObj['asset_symbol'] +
              " " + Translations.of(context).text('buy_financial.confirm_info');
          if(curLanguage == 'zh') {
            confirmText =Translations.of(context).text('buy_financial.confirm_buy') +
                _amountController.text +
                widget.detailObj['asset_symbol'] +
                Translations.of(context).text('buy_financial.confirm_info');
          }
          alert(context,
              desc: confirmText,
              btn: Translations.of(context).text('buy_financial.confirm_buy'),
              title: Translations.of(context).text('buy_financial.confirm_buy'),
              showClose: true, callback: () async {
                loading.state.show();
                Map sendData = {
                  "financial_id": widget.detailObj['financial_id'],
                  "amount": (Decimal.parse(_amountController.text) *
                      Decimal.parse(
                          pow(10, widget.detailObj['Asset_decimal']).toString()))
                      .toString()
                };
                var res = await Http.auth().post(
                    'financial/invest/' + widget.detailObj['financial_id'].toString(),
                    sendData);
                loading.state.dismiss();
                if (res != null) {
                  if (res['invest_transaction_hash'] != null) {
                    toast(Translations.of(context).text('buy_financial.success'));
                    Navigator.of(context).pop();
                  }
                }
              });
        }
      } catch (e) {
        toast(Translations.of(context).text('buy_financial.format_error'));
      }
    }

  }
}
