import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../component/dynamicListView.dart';
import '../component/submitButton.dart';
import 'package:decimal/decimal.dart';
import 'dart:math';
import '../../utils/translation.dart';
import '../component/alertModule.dart';
import '../../utils/http.dart';
import '../financial/buyFinancial.dart';
import 'dart:async';
import '../../utils/loading.dart';


class FinancialTab extends StatefulWidget {

  StreamController streamController;

  FinancialTab({this.streamController});

  @override
  FinancialTabState createState() =>  new FinancialTabState();
}

class FinancialTabState extends State<FinancialTab> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  StreamSubscription streamSubscription;
  Loading loading = new Loading();


  @override
  initState() {
    super.initState();
    streamSubscription = widget.streamController.stream.listen((value) {
      if (value == 'refresh_financial') {
        refreshList();
      }
    });
  }

  @override
  dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  GlobalKey<DynamicListViewState> listKey = new GlobalKey();

  // 刷新列表
  Future<Null> refreshList() async{
    listKey.currentState.onRefresh();
  }

  // 计算最少购买数量
  String calcInvestMin(Map item) {
    return (Decimal.parse(item['InvestMin']) /
      Decimal.parse(pow(10, item['AssetDecimal']).toString()))
      .toString();
  }
  // 计算可用数量
  String calcInvestCanUse(Map item) {
    String financialInvestingTotal = item['FinancialInvestingTotal'];
    if (item['FinancialInvestingTotal'] == null) financialInvestingTotal = '0';
    if (Decimal.parse(item['InvestTotal']) -
      Decimal.parse(financialInvestingTotal) < Decimal.fromInt(0)) {
      return '0';
    }
    return ((Decimal.parse(item['InvestTotal']) -
      Decimal.parse(financialInvestingTotal)) /
      Decimal.parse(pow(10, item['AssetDecimal']).toString()))
      .toString();
  }
  // 计算持有数量
  String calcHandleNum(Map item) {
    if (item['UserInvestingTotal'] == null || item['UserInvestingTotal'] == '') {
      return '0';
    }
    return (Decimal.parse(item['UserInvestingTotal']) /
      Decimal.parse(pow(10, item['AssetDecimal']).toString()))
      .toString();
  }
  // 获取年收化利率
  String getYearRate(Map item) {
    return (Decimal.parse(item['DailyInterestRate'].toString()) * Decimal.fromInt(365)).toString();
  }

  // 判断是否可以购买
  Future validAffordable(Map item) async{
    loading.state.show();
    var res = await Http.auth().get('/ethereum/balance/${item['AssetId']}');
    loading.state.dismiss();
    if (res == null || res.containsKey('error')) throw('request error, don\'t continue code below');
    if (Decimal.parse(res['Value']) - Decimal.parse(item['InvestMin']) >= Decimal.fromInt(0)) {
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTextStyle(
        style: TextStyle(
          color: Color.fromRGBO(255, 255, 255, 0.5),
          fontSize: ScreenUtil().setSp(12)
        ),
        child: Stack(
          children: <Widget>[
            new Container(
              padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(24),
                ScreenUtil().setWidth(50),
                ScreenUtil().setWidth(24),
                ScreenUtil().setWidth(8),
              ),
              decoration: BoxDecoration(
                gradient: new LinearGradient(
                  begin: const Alignment(0.0, -1.0),
                  end: const Alignment(0.0, 1.0),
                  colors: <Color>[const Color(0xff323346), const Color(0xff212231)],
                ),
              ),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: ScreenUtil().setWidth(24)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Translations.of(context).text('financial_tab.title'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ScreenUtil().setSp(20),
                          )),
                        GestureDetector(
                          child: SvgPicture.asset(
                            'assets/images/financial/icon_history.svg',
                            width: ScreenUtil().setWidth(24),
                            height: ScreenUtil().setHeight(24),
                          ),
                          onTap: () => Navigator.pushNamed(context, '/financial-history'),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: DynamicListView(
                      key: listKey,
                      ajaxObj: {
                        'url': '/financial/'
                      },
                      itemBuilder: (BuildContext context, Map item) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: ScreenUtil().setWidth(8)),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ScreenUtil().setWidth(2)),
                              color: Colors.white.withOpacity(0.06)
                            ),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  height: ScreenUtil().setWidth(136),
                                  padding: EdgeInsets.only(
                                    left: ScreenUtil().setWidth(16),
                                    top: ScreenUtil().setWidth(16),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: 1,
                                        color: Colors.white.withOpacity(0.06)
                                      )
                                    )
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(item['AssetName'], style: TextStyle(
                                            color: Colors.white,
                                            fontSize: ScreenUtil().setSp(16)
                                          ),),
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: ScreenUtil().setWidth(8)
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal:  ScreenUtil().setWidth(3),
//                                          vertical: ScreenUtil().setWidth(2)
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                ScreenUtil().setWidth(2)
                                              ),
                                              color: Colors.white.withOpacity(0.5),
                                            ),
//                                            height: ScreenUtil().setWidth(16),
                                            alignment: Alignment.center,
                                            child: Text(
                                              item['Cycle'].toString() + Translations.of(context).text('financial_tab.day'),
                                              style: TextStyle(
                                                color: Color(0xff292a3b),
                                                height: 1,
                                                fontSize: ScreenUtil().setSp(12)
                                              ),),
                                          ),
                                          calcHandleNum(item) == '0' ? Container() :
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Container(
                                                  margin: EdgeInsets.only(
                                                    top: ScreenUtil().setWidth(4)
                                                  ),
                                                  alignment: Alignment(0, 0),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xffffd559),
                                                    borderRadius: BorderRadius.only(
                                                      bottomLeft: Radius.circular(ScreenUtil().setWidth(10)),
                                                      topLeft: Radius.circular(ScreenUtil().setWidth(10))
                                                    )
                                                  ),
                                                  width: ScreenUtil().setWidth(52),
                                                  height: ScreenUtil().setWidth(20),
                                                  child: Text(
                                                    Translations.of(context).text('financial_tab.hold'),
                                                    style: TextStyle(
                                                      height: 1,
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: ScreenUtil().setSp(12),
                                                      color: Color(0xff292a3b)
                                                    ),),
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: ScreenUtil().setWidth(8)
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Text(Translations.of(context).text('financial_tab.day_rate')),
                                            Text(getYearRate(item) + '%', style: TextStyle(
                                              color: Color(0xfffd5658),
                                              fontSize: ScreenUtil().setSp(24),
                                              fontWeight: FontWeight.bold
                                            ),)
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: ScreenUtil().setWidth(6)
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              Translations.of(context).text('financial_tab.min_invest') +
                                                calcInvestMin(item)  + item['AssetSymbol']
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: ScreenUtil().setWidth(6)
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              Translations.of(context).text('financial_tab.available_invest') +
                                                calcInvestCanUse(item) + item['AssetSymbol']
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  height: ScreenUtil().setWidth(44),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenUtil().setWidth(16),
                                    vertical: ScreenUtil().setWidth(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      calcHandleNum(item) == '0' ? Container() :
                                      Container(
                                        width: MediaQuery.of(context).size.width -
                                          2 * ScreenUtil().setWidth(40) - 100,
                                        child: Text(Translations.of(context).text('financial_tab.hold_num') + calcHandleNum(item) + item['AssetSymbol']),
                                      ),
                                      SubmitButton(
                                        active: 1,
                                        text: Translations.of(context).text('financial_tab.buy_button'),
                                        width: 80,
                                        textStyle: TextStyle(fontSize: ScreenUtil().setSp(14)),
                                        onSubmit: () async{
                                          if (await validAffordable(item)) {
                                            Navigator.push(context,
                                              new MaterialPageRoute(
                                                builder: (BuildContext context) => BuyFinancial(detailObj: {
                                                  "interest_rate": item['DailyInterestRate'].toString(),
                                                  "max_invest": calcInvestCanUse(item),
                                                  "min_invest": calcInvestMin(item),
                                                  "hold_num":calcHandleNum(item) + item['AssetSymbol'],
                                                  "asset_id": item['AssetId'],
                                                  "financial_id":item['ID'],
                                                  "invest_time": item['Cycle'],
                                                  "asset_symbol": item['AssetSymbol'],
                                                  "Asset_decimal": item['AssetDecimal']
                                                },)
                                              ),
                                            ).then((result) => refreshList());
                                          } else {
                                            alert(
                                              context,
                                              title: Translations.of(context).text('financial_tab.alert_title'),
                                              desc: Translations.of(context).text('financial_tab.alert_desc'),
                                              btn: Translations.of(context).text('financial_tab.alert_btn'),
                                              showClose: true,
                                              callback: () => Navigator.pushNamed(context, '/receipt')
                                            );
                                          }
                                        },
                                      )

                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemExtent: ScreenUtil().setWidth(188)
                    ),
                  )
                ],
              ),
            ),
            loading
          ],
        ),
      )
    );
  }
}