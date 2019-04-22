import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../component/appBarFactory.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import './financialList.dart';
import '../../utils/translation.dart';


class FinancialHistory extends StatefulWidget {
  @override
  FinancialHistoryState createState() =>  new FinancialHistoryState();
}

class FinancialHistoryState extends State<FinancialHistory> with SingleTickerProviderStateMixin{

  TabController _tabController;
  List tabs = [];

  @override
  initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    tabs = [
      Translations.of(context).text('financial_history.tab1'),
      Translations.of(context).text('financial_history.tab2')
    ];
    return Scaffold(
      appBar: getAppBar(context,
        Translations.of(context).text('financial_history.title'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((e) => Tab(text: e)).toList(),
          indicatorColor: Color(0xff4551ff),
          isScrollable: true,
          labelStyle: TextStyle(
            fontSize: ScreenUtil().setWidth(16)
          ),
        )
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FinancialList(state: 'investing'),
          FinancialList(state: 'invested')
        ],
      ),
    );
  }
}