import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import '../../utils/http.dart';
import './customIndicator.dart';
import './freshHeaderFooter.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../../utils/eventBus.dart';
import '../../utils/translation.dart';
import './submitButton.dart';
import '../../utils/connectionListener.dart';


class DynamicListView extends StatefulWidget {

  DynamicListView({
    Key key,
    @required this.ajaxObj,
    @required this.itemBuilder,
    this.itemExtent,
    this.noDataView,
    this.refreshCb
  }) : super(key: key);

  Map ajaxObj = {
    'url': '',
    'data': null,
    'method': 'get', // 下面两个属性暂时留存
    'resKey': '',
  };
  Function itemBuilder;
  double itemExtent = ScreenUtil().setWidth(56);
  Widget noDataView;
  Function refreshCb;

  @override
  DynamicListViewState createState() =>  new DynamicListViewState();
}


class DynamicListViewState extends State<DynamicListView> {

  GlobalKey<EasyRefreshState> _easyRefreshKey = new GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = new GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = new GlobalKey<RefreshFooterState>();

  List list = [];
  int page = 1;
  bool isRefreshing = true;
  bool isConnected = true;


  @override
  initState() {
    super.initState();
    bus.on('disConnected', (state) {
      setState(() {
        isConnected = false;
      });
    });
    bus.on('connected', (state) {
      setState(() {
        isConnected = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 主动刷新： 供外部调用
  onRefresh() {
    if (_easyRefreshKey.currentState != null) {
      _easyRefreshKey.currentState.callRefresh();
    }
  }

  // 检测网络，没网时显示没网页面
  checkConnection() async{
    bool result = await ConnectionListener.getConnectState();
    setState(() {
      isConnected = result;
    });
  }

  // 下拉刷新
  Future _onRefresh() async{
    checkConnection();
    setState(() {
      isRefreshing = true;
    });
    page = 1;
    Map<String, String> param = {'page': page.toString()};
    if (widget.ajaxObj['data'] != null) {
      widget.ajaxObj['data'].forEach((key, value) {
        param[key] = value.toString();
      });
    }
    Map res = await Http.auth().get(widget.ajaxObj['url'], param);
    print(res);
    setState(() {
      if (!res.containsKey('error') || res['error'] != null) {
        list = res['item'];
        if (widget.refreshCb != null) widget.refreshCb(res);
      }
      isRefreshing = false;
    });
  }

  // 上拉加载更多
  Future _loadingMore() async{
    Map<String, String> param = {'page': (++ page).toString()};
    if (widget.ajaxObj['data'] != null) {
      widget.ajaxObj['data'].forEach((key, value) {
        param[key] = value.toString();
      });
    }
    Map res = await Http.auth().get(widget.ajaxObj['url'], param);
    print(res);
    if (res.containsKey('error') && res['error'] == null) {
      page --;
      return;
    }
    setState(() {
      list.addAll(res['item'] ?? []);
    });
  }

  // 无网络视图
  Widget getDisConnectedView() {
    return Center(
      child:  Padding(
        padding: EdgeInsets.only(
          top: ScreenUtil().setWidth(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/common/img_no_wifi.png',
              width: ScreenUtil().setWidth(168),
              height: ScreenUtil().setWidth(116),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: ScreenUtil().setWidth(40)
              ),
              child: Text(
                Translations.of(context).text('error.no_connect'),
                style: TextStyle(
                  fontSize: 14
                )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: ScreenUtil().setWidth(24)
              ),
              child: SubmitButton(
                active: 1,
                text: Translations.of(context).text('error.re_connect_btn'),
                width: 120,
                textStyle: TextStyle(fontSize: ScreenUtil().setSp(14)),
                onSubmit: onRefresh,
              ),
            )
          ],
        ),
      ),
    );
  }


  Widget getNoDataView() {
    if (!isRefreshing) {
      Widget child = new Container();
      if (!isConnected) {
        child = getDisConnectedView();
      } else if (widget.noDataView != null) {
        child = widget.noDataView;
      }
      State easyRefreshState = _easyRefreshKey.currentState;
      RenderBox easyRefreshBox = easyRefreshState.context.findRenderObject();
      return Container(
        height: easyRefreshBox.size.height,
        child: child,
      );
    }
    return Container();
  }

  Widget getListView() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(0),
      itemCount: list.length,
      itemExtent: widget.itemExtent, // 高度
      itemBuilder: (BuildContext itemBc, int index) {
        return widget.itemBuilder(context, list[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh(
      key: _easyRefreshKey,
      refreshHeader: ListRefreshHeader(
        key: _headerKey,
      ),
      refreshFooter: ListLoadFooter(
        key: _footerKey,
      ),
      child: getListView(),
      onRefresh: _onRefresh,
      loadMore: _loadingMore,
      firstRefresh: true,
      autoLoad: true,
      emptyWidget: getNoDataView()
    );
  }
}