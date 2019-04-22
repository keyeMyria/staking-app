import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/http.dart';
import 'dart:math';
import '../wallet/transferList.dart';
import 'package:decimal/decimal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../component/dynamicListView.dart';
import '../../utils/translation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../component/alertModule.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class WalletTab extends StatefulWidget {

  StreamController streamController;

  WalletTab({this.streamController});

  @override
  WalletTabState createState() => new WalletTabState();
}

class WalletTabState extends State<WalletTab> with AutomaticKeepAliveClientMixin{

  @override
  bool get wantKeepAlive => true;

  final Widget transferIcon = new SvgPicture.asset(
    'assets/images/home/icon_transfer.svg',
  );
  final Widget receiveIcon = new SvgPicture.asset(
    'assets/images/home/icon_receipt.svg',
  );
  final Widget ethIcon = new SvgPicture.asset(
    'assets/images/home/icon_eth.svg',
  );
  final Widget bnbIcon = Image.asset(
    'assets/images/home/icon_bizhong.png',
    width: ScreenUtil().setWidth(24),
    height: ScreenUtil().setWidth(24),
  );

  GlobalKey<DynamicListViewState> listKey = new GlobalKey();
  String address = '';
  StreamSubscription streamSubscription;

  @override
  initState() {
    super.initState();
    _getAddress();
    streamSubscription = widget.streamController.stream.listen((value) {
      if (value == 'refresh_wallet') {
        refreshList();
      }
    });
  }

  @override
  dispose() {
    streamSubscription.cancel();
    super.dispose();
  }

  _getAddress() async{
    var prefs = await SharedPreferences.getInstance();
    var res = prefs.getString('account_address');
    setState(() {
      if (res != null) address = res;
    });
  }

  // 刷新列表
  Future<Null> refreshList() async{
    listKey.currentState.onRefresh();
  }

  String _getAmount(item) {
    var res = Decimal.parse(item['Value']) /
      Decimal.parse(pow(10, item['Decimal']).toString());
    return res.toString();
  }

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

  Map _getCoinObj(Map item) {
    return {
      'assetId': item['AssetId'],
      'amount': _getAmount(item),
      'symbol': item['Symbol']
    };
  }

  Widget getSummaryItem([String flag = '']) {
    String itemTitle = Translations.of(context).text('wallet_tab.button1');
    Widget itemIcon = transferIcon;
    String toName = '/transfer';
    if (flag == 'receive') {
      itemTitle = Translations.of(context).text('wallet_tab.button2');
      itemIcon = receiveIcon;
      toName = '/receipt';
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
      onTap: () => Navigator.pushNamed(context, toName)
        .then((result) => refreshList()),
    );
  }

  Widget getListView() {
    return DynamicListView(
      key: listKey,
      ajaxObj: {
        'url': '/ethereum/balance'
      },
      itemBuilder: (BuildContext context, Map item) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1, color: Color.fromRGBO(255, 255, 255, 0.1)),
              )),
            child: Row(
              children: <Widget>[
                _getCoinIcon(item),
                Expanded(
                  child: Padding(
                    padding:
                    EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: ScreenUtil().setWidth(2),
                              ),
                              child: Text(
                                item['Symbol'],
                                style: TextStyle(fontSize: 14, height: 1.14),
                              ),
                            ),
                            Text(
                              item['Name'],
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.16,
                                color: Color.fromRGBO(255, 255, 255, 0.4)),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: ScreenUtil().setWidth(2),
                              ),
                              child: Text(
                                _getAmount(item),
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, height: 1.14),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ))
              ],
            ),
          ),
          onTap: () => Navigator.push(context, new MaterialPageRoute(
            builder: (BuildContext context) => TransferList(coinObj: _getCoinObj(item)),
          )).then((result) => refreshList())
        );
      },
      itemExtent: ScreenUtil().setWidth(56),
      refreshCb: (res){
        if(res['count'] != null) {
          getAppVersion();
        }
      },
    );
  }
  void getAppVersion ()async{
    var tmpUploadUrl = DotEnv().env['APP_UPLOAD_URL'];
    var res = await Http.auth().get('app/current-version');
    var tmpAppVersion = DotEnv().env['APP_CURRENT_VERSION'];
    if(res["app_current_version"] != tmpAppVersion) {
      alert(context, desc: Translations.of(context).text('version.new_version') +'v'+res["app_current_version"],btn: Translations.of(context).text('version.go_update'),callback: ()async{
        if (await canLaunch(tmpUploadUrl)) {
          await launch(tmpUploadUrl,forceSafariVC: true);
        }
      },disableBtnCb: true);
    }
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: DefaultTextStyle(
      style: TextStyle(color: Colors.white),
      child: new Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            begin: const Alignment(0.0, -1.0),
            end: const Alignment(0.0, 1.0),
            colors: <Color>[const Color(0xff323346), const Color(0xff212231)],
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(ScreenUtil().setWidth(24),
                    ScreenUtil().setWidth(50), 0, ScreenUtil().setWidth(22)),
                child: Text(
                  Translations.of(context).text('wallet_tab.title'),
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(16)),
                  child: Container(
                    height: ScreenUtil().setWidth(128),
                    decoration: BoxDecoration(
                        gradient: new LinearGradient(
                          begin: const Alignment(-1.0, 1.0),
                          end: const Alignment(1.0, -1.0),
                          colors: <Color>[
                            const Color(0xff4c1eb8),
                            const Color(0xff3a94ff)
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(ScreenUtil().setWidth(6))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                  ScreenUtil().setWidth(16),
                                  ScreenUtil().setWidth(24),
                                  0,
                                  ScreenUtil().setWidth(4)),
                              child: Text(
                                Translations.of(context).text('wallet_tab.address'),
                                style: TextStyle(
                                  fontSize: ScreenUtil().setSp(14),
                                )
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(16)),
                              child: Text(
                                address,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color.fromRGBO(255, 255, 255, 0.7)
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          color: Color.fromRGBO(255, 255, 255, 0.09),
                          height: ScreenUtil().setWidth(44),
                          padding: EdgeInsets.symmetric(
                              vertical: ScreenUtil().setWidth(11)),
                          child: Row(
                            children: <Widget>[
                              Flexible(child: getSummaryItem()),
                              Flexible(
                                flex: 0,
                                child: Container(
                                  width: 1,
                                  color: Color(0xfffffff).withOpacity(0.1),
                                ),
                              ),
                              Flexible(
                                child: getSummaryItem('receive'),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(24),
                  ScreenUtil().setWidth(17),
                  0,
                  ScreenUtil().setWidth(16),
                ),
                child: Text(
                  Translations.of(context).text('wallet_tab.coin_type'),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(24),
                  ),
                  child: getListView()
                ),
              )
            ],
          )),
    ));
  }
}
