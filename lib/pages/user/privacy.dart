import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../component/appBarFactory.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import '../../utils/translation.dart';


class Privacy extends StatefulWidget {
  @override
  PrivacyState createState() =>  new PrivacyState();
}

class PrivacyState extends State<Privacy> {

  TextStyle _titleStyle = TextStyle(
    fontSize: 24,
    height: 1.7,
    color: Colors.white
  );
  TextStyle _contentStyle = TextStyle(
    fontSize: 14,
    height: 1.6,
    color: Colors.white.withOpacity(0.4)
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(context, Translations.of(context).text('privacy.title')),
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
                    Text('Who may use the services', style: _titleStyle,),
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(8)
                      ),
                      child: Text(
                        'You may use the services only if you agree to form a binding contract with Twitter and are not a person barred from receiving services under the laws of the applicable jurisdiction.In any case,you must be at least 13 years old to use the services.If you are accepting these terms and using the sercices on behalf of a company,organization,goverment,or other legal entity,you represent and warrant that you are authorized to do so.',
                        style: _contentStyle,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(24)
                      ),
                      child: Text('Who may use the services', style: _titleStyle,),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: ScreenUtil().setWidth(8)
                      ),
                      child: Text(
                        'You may use the services only if you agree to form a binding contract with Twitter and are not a person barred from receiving services under the laws of the applicable jurisdiction.In any case,you must be at least 13 years old to use the services.If you are accepting these terms and using the sercices on behalf of a company,organization,goverment,or other legal entity,you represent and warrant that you are authorized to do so.',
                        style: _contentStyle,
                      ),
                    )
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
            )

          ],

        ),
      )
    );
  }
}