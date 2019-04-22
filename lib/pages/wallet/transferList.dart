import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../component/appBarFactory.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'transferDetail.dart';
import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/dynamicListView.dart';
import '../../utils/translation.dart';

class TransferList extends StatefulWidget {

  Map coinObj = {};

  TransferList({Key key, this.coinObj}) : super(key: key);

  @override
  TransferListState createState() =>  new TransferListState();
}

class TransferListState extends State<TransferList> {

  final Widget transferIcon = new SvgPicture.asset(
    'assets/images/home/icon_transfer.svg',
  );
  final Widget receiveIcon = new SvgPicture.asset(
    'assets/images/home/icon_receipt.svg',
  );

  String address = '';
  GlobalKey<DynamicListViewState> listKey = new GlobalKey();
  String amount;


  @override
  initState() {
    super.initState();
    _getAddress();
    amount = widget.coinObj['amount'];
  }

  _getAddress() async{
    var prefs = await SharedPreferences.getInstance();
    var res = prefs.getString('account_address');
    setState(() {
      address = res.toLowerCase();
    });
  }

  // 刷新列表
  Future<Null> _refreshList() async {
    listKey.currentState.onRefresh();
  }

  // dynamic list 下拉刷新后的回调
  _refreshCb (Map res) {
    var asset = res['asset_balance'];
    setState(() {
      amount = (Decimal.parse(asset['Value'].toString()) /
        Decimal.parse(pow(10, asset['Decimal']).toString())).toString();
    });
  }

  String formatTime(int timestamp){
    if (timestamp == null) return '';
    String localTimeStr = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
      .toLocal().toString();
    int lastDotIndex = localTimeStr.lastIndexOf('.');
    return localTimeStr.substring(0, lastDotIndex);
  }
  String ellipsis(String hash) {
    return hash.substring(0, 9) + '...' + hash.substring(hash.length - 8);
  }

  Widget getSummaryItem([String flag = '']) {
    String itemTitle = Translations.of(context).text('wallet_tab.button1');
    Widget itemIcon = transferIcon;
    if (flag == 'receive') {
      itemTitle = Translations.of(context).text('wallet_tab.button2');
      itemIcon = receiveIcon;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox.fromSize(
            size: Size(ScreenUtil().setWidth(16), ScreenUtil().setWidth(16)),
            child: itemIcon,
          ),
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(11)),
            child: Text(
              itemTitle,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
      onTap: () {
        if (flag != 'receive') {
          Navigator.pushNamed(context, '/transfer').then((result) => _refreshList());
        } else {
          Navigator.pushNamed(context, '/receipt').then((result) => _refreshList());
        }
      },
    );
  }
  Widget getListItemIcon(Map item) {
    // 自己给自己转账
    if (item['From'].toLowerCase() == address && item['To'].toLowerCase() == address) {
      return SvgPicture.asset(
        'assets/images/transfer/icon_zhuanziji.svg',
      );
    } else if (item['From'].toLowerCase() == address) {
      return SvgPicture.asset(
        'assets/images/transfer/icon_zhuanchu.svg',
      );
    } else {
      return SvgPicture.asset(
        'assets/images/transfer/icon_zhuanru.svg',
      );
    }
  }

  // 根据状态返回 文本 和 样式
  Map calcListItemState(Map item) {
    String stateStr;
    TextStyle specStyle;
    if (item['BlockTimestamp'] != null) {
      if(item['IsError'] == 0) {
        // 自己给自己转账
        if (item['From'].toLowerCase() == address && item['To'].toLowerCase() == address) {
          stateStr = Translations.of(context).text('transfer_list.trans_success');
          specStyle = TextStyle(color: Colors.white.withOpacity(0.5));
        } else if (item['From'].toLowerCase() == address) {
          stateStr = Translations.of(context).text('transfer_list.trans_out_success');
          specStyle = TextStyle(color: Color(0xff2aeac3));
        } else {
          stateStr = Translations.of(context).text('transfer_list.trans_in_success');
          specStyle = TextStyle(color: Color(0xfffd5658));
        }
      } else {
        if (item['From'].toLowerCase() == address && item['To'].toLowerCase() == address) {
          stateStr = Translations.of(context).text('transfer_list.trans_fail');
        } else if (item['From'].toLowerCase() == address) {
          stateStr = Translations.of(context).text('transfer_list.trans_out_fail');
        } else {
          stateStr = Translations.of(context).text('transfer_list.trans_in_fail');
        }
        specStyle = TextStyle(color: Colors.white.withOpacity(0.5));
      }
    } else {
      stateStr = Translations.of(context).text('transfer_list.trans_process');
      specStyle = TextStyle(color: Color(0xffffd559));
    }
    return {
      'stateStr': stateStr,
      'stateStyle': specStyle
    };
  }
  Widget getListItemState(Map item) {
    Map itemState = calcListItemState(item);
    return Text(itemState['stateStr'], style: itemState['stateStyle'].merge(TextStyle(
      fontSize: 12,
//      height: 1.5
    )));
  }
  // 计算金额
  String calcListItemAmount(Map item) {
    String valueKey = 'SendValue';
    if (item['TokenContractAddress'] != null && item['TokenContractAddress'] != '') {
      valueKey = 'TokenSendValue';
    }
    if (item[valueKey] == null) return '';
    var sendValue = Decimal.parse(item[valueKey]) /
      Decimal.parse(pow(10, item['TokenDecimal']).toString());
    return sendValue.toString();
  }
  // 根据状态返回 amount 的符号
  String calcListItemSign(Map item) {
    String sign;
    // 自己给自己转账
    if (item['From'].toLowerCase() == address && item['To'].toLowerCase() == address) {
      sign = '';
    } else if (item['From'].toLowerCase() == address) {
      sign = '- ';
    } else {
      sign = '+ ';
    }
    return sign;
  }
  Widget getListItemAmount(Map item) {
    TextStyle specStyle = calcListItemState(item)['stateStyle'];
    String sign = calcListItemSign(item);
    String symbol = ' ' + item['TokenSymbol'];
    TextStyle finalStyle = specStyle.merge(TextStyle(
      fontSize: ScreenUtil().setSp(14),
//      height: 1.6
    ));
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(sign, style: finalStyle),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ScreenUtil().setWidth(70)
          ),
          child: Text(calcListItemAmount(item),
            overflow: TextOverflow.ellipsis,
            style: finalStyle
          ),
        ),
        Text(symbol, style: finalStyle)
      ],
    );
  }

  Widget getListView() {
    return DynamicListView(
      key: listKey,
      ajaxObj: {
        'url': 'ethereum/transaction',
        'data': {'asset_id': widget.coinObj['assetId']}
      },
      itemBuilder: (BuildContext context, Map item) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1, color: Color(0xffbdbdbd).withOpacity(0.1)),
              )),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: ScreenUtil().setWidth(16),
                  height: ScreenUtil().setWidth(16),
                  child: getListItemIcon(item),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(formatTime(item['BlockTimestamp']), style: TextStyle(
                              fontSize: ScreenUtil().setSp(12),
                              color: Color(0xffd9d9d9)
                            )),
                            Padding(
                              padding: EdgeInsets.only(
                                top: ScreenUtil().setWidth(10),
                              ),
                              child: Text( ellipsis(item['Hash']), style: TextStyle(
                                fontSize: ScreenUtil().setSp(12),
                                color: Color.fromRGBO(255, 255, 255, 0.5)
                              )),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: ScreenUtil().setWidth(9),
                              ),
                              child: getListItemState(item),
                            ),
                            getListItemAmount(item)
                          ],
                        )
                      ],
                    ),
                  ))
              ],
            ),
          ),
          onTap: () => Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => TransferDetail(detailObj: getDetailObj(item)),
          )),
        );
      },
      itemExtent: ScreenUtil().setWidth(68),
      noDataView: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/common/img_nodata.png',
              width: ScreenUtil().setWidth(206),
              height: ScreenUtil().setWidth(148),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: ScreenUtil().setWidth(28)
              ),
              child: Text(
                Translations.of(context).text('transfer_list.no_data'),
                style: TextStyle(
                  fontSize: 14
                )
              ),
            )
          ],
        ),
      ),
      refreshCb: _refreshCb,
    );
  }

  Map getDetailObj(Map item) {
    String sign = calcListItemSign(item);
    String symbol = ' ' + item['TokenSymbol'];
    String stateStr = calcListItemState(item)['stateStr'];
    Map calcObj = {
      "amount": sign + calcListItemAmount(item) + symbol,
      "time": formatTime(item['BlockTimestamp']),
      "stateStr": stateStr,
    };
    calcObj.addAll(item);
    return calcObj;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints.expand(),
          child: Stack(
            alignment: Alignment(0, 0),
            fit: StackFit.expand,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(
                  top: 56 + MediaQuery.of(context).padding.top,
                ),
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
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenUtil().setWidth(24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        amount + ' ' + widget.coinObj['symbol'],
                                        style: TextStyle(
                                          fontSize: 24,
//                                          height: 1.25
                                        ),
                                      ),
                                    ),
                                    Container(
//                                      width: ScreenUtil().setWidth(30),
                                      height: ScreenUtil().setWidth(16),
                                      color: Color.fromRGBO(255, 255, 255, 0.28),
                                      padding: EdgeInsets.symmetric(
                                        vertical: ScreenUtil().setWidth(1),
                                        horizontal: ScreenUtil().setWidth(5)
                                      ),
                                      alignment: Alignment(0, 0),
                                      child: Text(widget.coinObj['symbol'], style: TextStyle(
                                        fontSize: ScreenUtil().setWidth(10),
                                      ),),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                top: 56 + MediaQuery.of(context).padding.top - ScreenUtil().setWidth(43),
                right: 0,
                child: Image.asset('assets/images/transfer/img_eth.png',
                  width: ScreenUtil().setWidth(176),
                  height: ScreenUtil().setWidth(164),
                  fit: BoxFit.fitHeight,
                ),
              ),
              Positioned(
                top: 56 + ScreenUtil().setWidth(77) + MediaQuery.of(context).padding.top,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  child: Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setWidth(11)
                      ),
                      height: ScreenUtil().setWidth(44),
                      color: Color.fromRGBO(255, 255, 255, 0.09),
                      child: Row(
                        children: <Widget>[
                          Flexible(child: getSummaryItem()),
                          Flexible(
                            flex: 0,
                            child: Container(
                              width: 1,
                              color: Color.fromRGBO(255, 255, 255, 0.3),
                            ),
                          ),
                          Flexible(
                            child: getSummaryItem('receive'),
                          ),
                        ],
                      )
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: ScreenUtil().setWidth(4),
                          left: ScreenUtil().setWidth(24),
                          right: ScreenUtil().setWidth(24),
                        ),
                        child: getListView()),
                    )
                  ]),
                )
              ),
              getTransparentAppBar(context, Translations.of(context).text('transfer_list.title'))
            ],
          ),
        )
      )
    );
  }
}