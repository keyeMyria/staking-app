import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../component/dynamicListView.dart';
import '../../utils/translation.dart';
import '../../utils/helper.dart';
import 'package:decimal/decimal.dart';
import 'dart:math';


/* 已持有的购买历史 */
class FinancialList extends StatefulWidget {

  String state = 'investing';

  FinancialList({Key key, this.state}) : super(key: key);

  @override
  FinancialListState createState() =>  new FinancialListState();
}


class FinancialListState extends State<FinancialList> {
  @override
  initState() {
    super.initState();
  }

  getEndDate(Map item) {
    if (widget.state == 'investing') {
      if(item['StartedAt'] == null) { // 处理中
        return '';
      }
      DateTime localTime = DateTime.parse(item['StartedAt']).toLocal();
      localTime = localTime.add(new Duration(days: item['FinancialCycle']));
      return localTime.year.toString() + '-' + localTime.month.toString().padLeft(2,'0')
        + '-' + localTime.day.toString().padLeft(2,'0');
    } else {
      return formatDate(item['EndedAt']);
    }
  }

  String formatDate(String timeStr) {
    if (timeStr == null) return '';
    DateTime localTime = DateTime.parse(timeStr).toLocal();
    return localTime.year.toString() + '-' + localTime.month.toString().padLeft(2,'0')
      + '-' + localTime.day.toString();
  }

  String calcAmount(Map item) {
    if (item['Amount'] == null) return '0';
    return Helper.convertUnit(item['Amount'], item['AssetDecimal']);
  }
  String calcProfit(Map item) {
    if (item['FinancialProfitAmount'] == null) return '0';
    return Helper.convertUnit(item['FinancialProfitAmount'], item['AssetDecimal']);
  }
  // 获取年收化利率
  String getYearRate(Map item) {
    return (Decimal.parse(item['DailyInterestRate'].toString()) * Decimal.fromInt(365)).toString();
  }

  // 获取状态
  Widget getState(Map item) {
    String text;
    TextStyle specialStyle;
    if (item['DeletedAt'] == null) {
      if (item['StartedAt'] == null) { // 处理中
        text = Translations.of(context).text('financial_history.state_process');
        specialStyle = TextStyle(color: Color(0xffffd559));
      } else { // 持有中
        text = Translations.of(context).text('financial_history.state_holding');
        specialStyle = TextStyle(color: Color(0xff2aeac3));
      }
    } else {
      text = Translations.of(context).text('financial_history.state_fail');
      specialStyle = TextStyle(color: Color(0xff75768d));
    }
    return Text(text,style: TextStyle(
      fontSize: ScreenUtil().setSp(12)
    ).merge(specialStyle));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Color.fromRGBO(255, 255, 255, 0.5),
        fontSize: ScreenUtil().setSp(12)
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: new LinearGradient(
            begin: const Alignment(0.0, -1.0),
            end: const Alignment(0.0, 1.0),
            colors: <Color>[const Color(0xff323346), const Color(0xff212231)],
          ),
        ),
        child: DynamicListView(
          ajaxObj: {
            'url': '/financial/user',
            'data': {'invest_state': widget.state}
          },
          itemBuilder: (BuildContext context, Map item) {
            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: ScreenUtil().setWidth(24),
              ),
              padding: EdgeInsets.only(
                top: ScreenUtil().setWidth(16)
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xfff6f6f6).withOpacity(0.1),
                    width: 1
                  )
                )
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        Translations.of(context).text('financial_history.end_date') +
                          getEndDate(item)
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
//                            widget.state == 'investing' ? Container() :
//                            Row(children: <Widget>[
//                              Text(Translations.of(context).text('financial_history.trans_date')),
//                              Padding(
//                                padding: EdgeInsets.only(
//                                  right: ScreenUtil().setWidth(8)
//                                ),
//                                child: Text('2018-09-27'),
//                              ),
//                            ],),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xffffd559),
                                borderRadius: BorderRadius.circular(ScreenUtil().setWidth(2))
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenUtil().setWidth(3),
                                vertical: ScreenUtil().setWidth(2)
                              ),
                              child: Text(
                                item['FinancialCycle'].toString() + Translations.of(context).text('financial_tab.day'),
                                style: TextStyle(
                                  color: Color(0xff292a3b)
                                ),),
                            )
                          ]
                        )
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(12)
                    ),
                    child: Row(
                      children: <Widget>[
                        Text.rich(TextSpan(
                          children: [
                            TextSpan(text: Translations.of(context).text('financial_history.predict_rate')),
                            TextSpan(
                              text: '  ' + getYearRate(item) + '%',
                              style: TextStyle(
                                color: Color(0xfffd5658)
                              ))
                          ],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(14)
                          )
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(4)
                    ),
                    child: Row(
                      children: <Widget>[
                        Text.rich(TextSpan(
                          children: [
                            TextSpan(text: Translations.of(context).text('financial_history.invest_amount')),
                            TextSpan(
                              text: calcAmount(item) + item['AssetSymbol'],
                              style: TextStyle(
                                color: Colors.white
                              )
                            )
                          ],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(14)
                          )
                        )),
                      widget.state != 'investing' ? Container() :
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: getState(item),
                        ),
                      )
                    ]),
                  ),
                  widget.state == 'investing' ? Container() :
                  Padding(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(4)
                    ),
                    child: Row(children: <Widget>[
                      Text(
                        Translations.of(context).text('financial_history.had_profit'),
                        style: TextStyle(
                          fontSize: ScreenUtil().setSp(14)
                        ),),
                      Padding(
                        padding: EdgeInsets.only(
//                          left: ScreenUtil().setWidth(8)
                        ),
                        child: Text(
                          calcProfit(item) + item['AssetSymbol'],
                          style: TextStyle(
                            fontSize: ScreenUtil().setSp(14),
                            color: Colors.white
                          ),),
                      )
                    ]),
                  )
                ],
              ),
            );
          },
          itemExtent: ScreenUtil().setWidth(
            widget.state == 'investing' ? 106 : 130
          ),
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
                    Translations.of(context).text('financial_history.no_data'),
                    style: TextStyle(
                      fontSize: ScreenUtil().setSp(14)
                    )
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}