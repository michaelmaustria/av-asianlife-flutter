import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/login/view/new_login_page.dart';
import 'package:av_asian_life/splash_screen/splash_screen_page.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';

class InitLogin extends StatefulWidget {

  final String displayPic;
  InitLogin({this.displayPic});

  @override
  _InitLoginState createState() => new _InitLoginState();
}

class _InitLoginState extends State<InitLogin> {

  BuildContext _mContext;
  
  @override
  void initState() {
    super.initState();
    print('init state');
    Future.delayed(const Duration(seconds: 2), () => _navigateToLogin(context));
  }

  void _navigateToLogin(context) async{
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    bool hasAuthData = await myPreferenceHandler.hasUserAuthData();
    print('has Auth Data: $hasAuthData');
    if(hasAuthData){
      User user = await myPreferenceHandler.getAuthData();
      print(user);
  
      String _displayPic = widget.displayPic;
      String _username = user.username;
      String _initPassword = user.password;
      
      Navigator.push(context,
         MaterialPageRoute(
         builder: (context) => NewLoginPage(sendUserData: new SendUserData(_username,_initPassword, _displayPic))));
    }else{
       Navigator.push(context,
         MaterialPageRoute(builder: (context) => LoginPage()));
    }

  }

  @override
  Widget build(BuildContext context) {
    _mContext = context;
    return _getSplashScreen();
  }

  Widget _getSplashScreen() {
    double height = MediaQuery.of(_mContext).size.height;
    double width = MediaQuery.of(_mContext).size.width;
    return Container(
      height: height,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 8.0,
              child: Container(color: mPrimaryColor,),
            ),
          ),
          SizedBox(height: width * .1),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 55.0),
              child: Image.asset('assets/images/smile_app_icon_sm.png',
                  fit: BoxFit.contain),
            ),
          ),
          Container(
            width: width * .35,
            child: Image.asset('assets/images/loading_Icon_v1.gif', fit: BoxFit.contain,),
          ),
          Hero(
            tag: 'copyright',
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('Powered by:', style: TextStyle(fontSize: 15.0, color: Colors.black87, fontWeight: FontWeight.normal)),
                      SizedBox(
                        height: 60,
                        child: Image.asset(
                            'assets/images/EtiqaLogoColored_SmileApp.png',
                            fit: BoxFit.contain),
                      ),
                      myMultimediaAccounts(),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 25.0),
                        child: copyRightText()
                      ),
                    ],
                  ),
                )
            ),
          ),
        ],
      ),
    );
  }

}

// class SendUserData{
//   final String username;
//   final String initPassword;
//   final String displayPic;

//   SendUserData(this.username, this.initPassword, this.displayPic);
// }