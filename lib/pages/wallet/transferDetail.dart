import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../component/submitButton.dart';
import '../component/appBarFactory.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../component/toast.dart';
import 'package:decimal/decimal.dart';
import '../../utils/http.dart';
import '../../utils/translation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/translation.dart';


class TransferDetail extends StatefulWidget {

  Map detailObj = {};

  TransferDetail({
    Key key,
    this.detailObj
  }) : super(key: key);

  @override
  TransferDetailState createState() =>  new TransferDetailState();
}

class TransferDetailState extends State<TransferDetail> {
  bool _buttonState = false;
  String gas = '';
  String blockChainUrl = DotEnv().env['BLOCK_CHAIN_URL'];

  @override
  initState() {
    super.initState();
    _getGas();
  }

  Widget _getStateIcon(BuildContext context) {
    String stateStr = widget.detailObj['stateStr'];
    if (stateStr == Translations.of(context).text('transfer_list.trans_in_success')) {
      return SvgPicture.asset(
        'assets/images/transfer/icon_zhuanruchenggong.svg',
      );
    } else if (stateStr == Translations.of(context).text('transfer_list.trans_out_success')) {
      return SvgPicture.asset(
        'assets/images/transfer/icon_zhuanchuchenggong.svg',
      );
    } else if (stateStr == Translations.of(context).text('transfer_list.trans_success')) {
      return Image.asset(
        'assets/images/transfer/icon_zhuanzhangchenggong.png'
      );
    } else if (stateStr == Translations.of(context).text('transfer_list.trans_process')) {
      return SvgPicture.asset(
        'assets/images/transfer/icon_processing.svg',
      );
    } else {
      return SvgPicture.asset(
        'assets/images/transfer/icon_zhuanzhangshibai.svg',
      );
    }
  }

  Color getStateColor() {
    if (widget.detailObj['amount'].indexOf('-') != -1) {
      return Color(0xff2aeac3);
    } else if (widget.detailObj['amount'].indexOf('+') != -1) {
      return Color(0xfffd5658);
    } else {
      return Colors.white;
    }
  }

   _getGas() async{
    // 获取预估手续费数据
    var res = await Http().get('/ethereum/gas-limit/${widget.detailObj['TokenId']}');
    if (res['asset'] == null) return '';
    var value = Decimal.parse(widget.detailObj['GasPrice']) *
      Decimal.parse(widget.detailObj['GasUsed'].toString()) /
      Decimal.parse(pow(10, res['asset']['Decimal']).toString());
    setState(() {
      gas = value.toString() + ' ' + res['asset']['Symbol'];
    });
  }

  TextStyle _fieldStyle = TextStyle(
    fontSize: ScreenUtil().setSp(14),
    height: 1.6,
    color: Color.fromRGBO(255, 255, 255, 0.5)
  );
  TextStyle _fieldSmallStyle = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    height: 1.8,
    color: Color.fromRGBO(255, 255, 255, 0.5)
  );
  TextStyle _valueStyle = TextStyle(
    fontSize: ScreenUtil().setSp(12),
    height: 1.3,
    color: Color(0xffd9d9d9)
  );

  _openBlockLink() async{
    if (await canLaunch(blockChainUrl + widget.detailObj['Hash'])) {
      await launch(blockChainUrl + widget.detailObj['Hash']);
    } else {
      throw 'Could not launch ${blockChainUrl + widget.detailObj['Hash']}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, Translations.of(context).text('transfer_detail.title')),
      body: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                ScreenUtil().setWidth(24),
                ScreenUtil().setWidth(24),
                ScreenUtil().setWidth(24), 0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(widget.detailObj['amount'], style: TextStyle(
                    fontSize: ScreenUtil().setSp(24),
                    height: 1.4,
                    color: getStateColor()
                  )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(widget.detailObj['time'], style: TextStyle(
                        fontSize: ScreenUtil().setSp(12),
                        letterSpacing: 1.2,
                        height: 1.4
                      )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              top: ScreenUtil().setWidth(12) - ScreenUtil().setSp(12) / 2
                            ),
                            width: ScreenUtil().setWidth(12),
                            height: ScreenUtil().setWidth(12),
                            child: _getStateIcon(context),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: ScreenUtil().setWidth(7)
                            ),
                            child: Text(widget.detailObj['stateStr'], style: TextStyle(
                              fontSize: ScreenUtil().setSp(12),
                              height: 1.4
                            )),
                          ),
                        ],
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0xffbdbdbd).withOpacity(0.1)
                              )
                            )
                          ),
                          padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(23),
                            bottom: ScreenUtil().setWidth(16)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                Translations.of(context).text('transfer_detail.field1'),
                                style: _fieldStyle
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4)
                                ),
                                child: Text(
                                  widget.detailObj['From'],
                                  style: _valueStyle),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(16),
                            bottom: ScreenUtil().setWidth(16),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0xffbdbdbd).withOpacity(0.1)
                              )
                            )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(Translations.of(context).text('transfer_detail.field2'), style: _fieldStyle),
                              widget.detailObj['TokenContractAddress'] == '' ? Container() :
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(8)
                                    ),
                                    child: Text(Translations.of(context).text('transfer_detail.field3'), style: _fieldSmallStyle),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(4)
                                    ),
                                    child: Text(widget.detailObj['TokenContractAddress'] ?? '',
                                      style: _valueStyle),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: ScreenUtil().setWidth(8)
                                    ),
                                    child: Text(Translations.of(context).text('transfer_detail.field4'), style: _fieldSmallStyle),
                                  ),
                                ]
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4)
                                ),
                                child: Text(widget.detailObj['To'],
                                  style: _valueStyle),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(16),
                            bottom: ScreenUtil().setWidth(16),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0xffbdbdbd).withOpacity(0.1)
                              )
                            )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(Translations.of(context).text('transfer_detail.field5'), style: _fieldStyle),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4)
                                ),
                                child: GestureDetector(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(widget.detailObj['Hash'],style: _valueStyle),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          left: ScreenUtil().setWidth(10)
                                        ),
                                        width: ScreenUtil().setWidth(24),
                                        height: ScreenUtil().setWidth(24),
                                        child: SvgPicture.asset(
                                          'assets/images/common/icon_arrow.svg',
                                        )
                                      )
                                    ],
                                  ),
                                  onTap: _openBlockLink,
                                ),
                              )
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(16),
                            bottom: ScreenUtil().setWidth(16),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 1,
                                color: Color(0xffbdbdbd).withOpacity(0.1)
                              )
                            )
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(Translations.of(context).text('transfer_detail.field6'), style: _fieldStyle),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4)
                                ),
                                child: Text(gas,
                                  style: _valueStyle),
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: ScreenUtil().setWidth(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(Translations.of(context).text('transfer_detail.field7'), style: _fieldStyle),
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ScreenUtil().setWidth(4)
                                ),
                                child: Text(
                                  (widget.detailObj['BlockNumber'] ?? '').toString(),
                                  style: _valueStyle),
                              ),
                            ]
                          )
                        )
                      )
                    ]
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: ScreenUtil().setWidth(32),
                      bottom: ScreenUtil().setWidth(24)
                    ),
                    alignment: Alignment(0, 0),
                    child: Container(
                      color: Colors.white,
                      child: QrImage(
                        version: 6,
                        data: blockChainUrl + widget.detailObj['Hash'],
                        size: ScreenUtil().setWidth(80),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment(0, 0),
                    padding: EdgeInsets.only(
                      bottom: ScreenUtil().setWidth(55)
                    ),
                    child: SubmitButton(
                      isSubmit: _buttonState,
                      active: 1,
                      text: Translations.of(context).text('transfer_detail.copy_button'),
                      onSubmit: () async{
                        await Clipboard.setData(new ClipboardData(
                          text: blockChainUrl + widget.detailObj['Hash']
                        ));
                        setState(() {
                          _buttonState = false;
                        });
                        toast(Translations.of(context).text('transfer_detail.copy_result'));
                      }
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      )
    );
  }
}