
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

var mPrimaryColor = Color(0xffFFBF00);
var mAccentColor = Color(0xffFEE81E);

Widget myMultimediaAccounts() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      InkWell(
        child: _getSocialMediaIcon('assets/images/FB_SMILE_APP.png'),
        onTap: () {
          launch('https://www.facebook.com/etiqaphilippines');
        },
      ),
      InkWell(
        child: _getSocialMediaIcon('assets/images/IG_SMILE_APP.png'),
        onTap: () {
          launch('https://www.instagram.com/etiqaphilippines');
        },
      ),
      InkWell(
        child: _getSocialMediaIcon('assets/images/LinkedIN_SMILE_APP.png'),
        onTap: () {
          launch('https://www.linkedin.com/company/etiqaphilippines');
        },
      ),
      InkWell(
        child: _getSocialMediaIcon('assets/images/Website_SMILE_APP.png'),
        onTap: () {
          launch('https://www.etiqa.com.ph');
        },
      ),
    ],
  );
}

Widget _getSocialMediaIcon(String image) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5.0),
    child: SizedBox(
      height: 30,
      width: 30,
      child: Image.asset(image, fit: BoxFit.fill),
    ),
  );
}

Widget myLoadingIcon({double height, double width}) {
  return Container(
    height: height,
    width: width,
    child: Image.asset('assets/images/loading_Icon_v1.gif', fit: BoxFit.contain,),
  );
}

Widget copyRightText() {
  return Text('Copyright ${DateTime.now().year}. Etiqa Life & General Assurance Philippines, Inc.',
      style: TextStyle(fontSize: 10.0,));
}

BoxDecoration myAppLogo() {
  return BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/images/smile_app_icon_sm.png',),
          fit: BoxFit.contain,
          alignment: Alignment.topCenter
      )
  );
}

BoxDecoration myAppBarBackground() {
  return BoxDecoration(
    color: Colors.white,
      image: DecorationImage(
          image: AssetImage('assets/images/appBar_background.png'),
          alignment: Alignment.topCenter
      )
  );
}

BoxDecoration myAppBackground() {
  return BoxDecoration(
    color: Colors.white,
    image: DecorationImage(
        image: AssetImage('assets/images/background_opacity.png'),
        alignment: Alignment.topCenter),

  );
}