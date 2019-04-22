import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../component/appBarFactory.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/translation.dart';
import '../../utils/loading.dart';
import '../../utils/http.dart';


class TermsService extends StatefulWidget {
  @override
  TermsServiceState createState() =>  new TermsServiceState();
}

class TermsServiceState extends State<TermsService> {

  TextStyle _titleStyle = TextStyle(
    fontSize: 24,
    height: 1.7,
    color: Colors.white
  );
  TextStyle _contentStyle = TextStyle(
    fontSize: 14,
    height: 1.6,
    color: Colors.white.withOpacity(0.4),
  );
  Loading loading = new Loading(defaultState: true,);
  String initContent = '';


  @override
  void initState() {
    // TODO: implement initState
    _getContent();
    super.initState();
  }
  _getContent() async{
    var res = await Http.auth().get('app/terms-of-services');
    setState(() {
      initContent = res['terms_of_services'];
    });
    loading.state.dismiss();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, Translations.of(context).text('register.service_terms_title')),
      body: ConstrainedBox(
        constraints: BoxConstraints.expand(),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                bottom: ScreenUtil().setWidth(80)
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
              child: Scrollbar(child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  ScreenUtil().setWidth(24),
                  ScreenUtil().setWidth(24),
                  ScreenUtil().setWidth(24),
                  0
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(8)
                      ),
                      child: Text(
                        initContent,
                        textAlign: TextAlign.justify,
                        style: _contentStyle,
                      ),
                    ),
                  ],
                ),
              )),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/user/img_userservice.svg',
                width: ScreenUtil().setWidth(156),
                height: ScreenUtil().setWidth(82),
              ),
            ),
            loading,
          ],

        ),
      )
    );
  }
}