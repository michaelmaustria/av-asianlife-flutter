import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/login/view/new_login_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SplashScreenPage extends StatefulWidget {
  // 1 = has data proceed to HomePage
  // 0 = no data proceed to Login
  // -1 = no data initial call..
  final int hasData;

  SplashScreenPage({this.hasData});

  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  MyPreferenceHandler _myPreferenceHandler = MyPreferenceHandler();

  BuildContext _mContext;

  @override
  void initState() {
    super.initState();
    _testAppVersion().then((_){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if(widget.hasData == 2) {
          Future.delayed(const Duration(seconds: 2), () => _navigateToLogin(_mContext));
        }
      });
    });
  }


  @override
  void dispose() {
    super.dispose();
    _mContext = null;
  }

  Future _testAppVersion() async {
    print('_testAppVersion');
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //String appName = packageInfo.appName;
    //String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    String oldVersion = await _myPreferenceHandler.getAppVersion();
    String oldBuild = await _myPreferenceHandler.getBuildNumber();

    print('saved version: $oldVersion, saved build: $oldBuild');
    print('version: $version, build: $buildNumber');

    if(oldVersion != version || oldBuild != buildNumber){
      print('_testAppVersion: new version found. destroying data.');
      _myPreferenceHandler.destroyUserData();
    }

    _myPreferenceHandler.setAppVersionData(version, buildNumber);

  }

  @override
  void didUpdateWidget(SplashScreenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('hasData: ${widget.hasData}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(widget.hasData == 0) {
          Future.delayed(const Duration(seconds: 2), () => _navigateToLogin(_mContext));
      }
      else if(widget.hasData == 1) {
        _testDestroyData();
      }
    });
  }

  void _testDestroyData() async {
    bool toDestroy = await _myPreferenceHandler.getDestroyFlag();
    print('getDestroyFlag: $toDestroy');
    if(toDestroy != null) {
      if (toDestroy) {
        _myPreferenceHandler.releaseUserData();
        _navigateToLogin(_mContext);
      } else {
        _navigateToHomePage();
      }
    }else {
      _navigateToHomePage();
    }
  }

  void _navigateToHomePage() async {
    User user = await _myPreferenceHandler.getUserData();
    _getMemberInfo(user.cardNo);
  }

  void _navigateToLogin(context) async{
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    bool hasAuthData = await myPreferenceHandler.hasUserAuthData();
    print('has Auth Data: $hasAuthData');
    if(hasAuthData){
      User user = await myPreferenceHandler.getAuthData();
      print(user);
  
      String _displayPic = "";
      String _username = user.username;
      String _initPassword = user.password;
      
      Navigator.push(context,
         MaterialPageRoute(
         builder: (context) => NewLoginPage(sendUserData: new SendUserData(_username, _initPassword, _displayPic))));
    }else{
       Navigator.push(context,
         MaterialPageRoute(builder: (context) => LoginPage()));
    }

  }

  void _getMemberInfo(String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    await ApiToken.requestInitApiToken();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}MemberInfo?userid=$_api_user&password=$_api_pass&cardno=$cardNo&frommain=0';

    try {
      var res = await http.post(
          url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email
        },
        body : {
          "userid" : _base_url,
          "password" : _api_user,
          "cardno" : cardNo,
          "frommain" : "0"
        }
      );
      var json = jsonDecode(jsonDecode(res.body));

      List<Member> data = [];
      json.forEach((entity) {
        data.add(Member.fromJson(entity));
      });
      if(json[0]['msgCode'] != '038'){
        print('Navigate to HomePage: ${data[0].cardno}');
        Navigator.of(_mContext).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => HomePage(member: data[0],)),
          ModalRoute.withName(HomePage.tag)
        );
      } else {
        Navigator.of(context)
            .pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => NewLoginPage()
            ),
                (Route<dynamic> route) => false
        );
      }
    } catch (e) {
      print('_getMemberInfo on SplashScreenPage');
      print(e);
      if(_mContext != null)
        _messageDialog('Network Error', e.toString() + '.\n\nPlease check your internet connection.');
    }

  }

  void _messageDialog(String title, String body){
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(body),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Close App", textAlign: TextAlign.justify, style: TextStyle(color: Colors.black87),),
          onPressed: () {
            exit(0);
          },
        )
      ],
    );

    try {
      // show the dialog
      if(_mContext != null) {
        showDialog(
          context: _mContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return alert;
          },
        );
      }
    }catch(e){
      print('_messageDialog');
      print(e);
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

class SendUserData{
  final String username;
  final String initPassword;
  final String displayPic;

  SendUserData(this.username, this.initPassword, this.displayPic);
}






