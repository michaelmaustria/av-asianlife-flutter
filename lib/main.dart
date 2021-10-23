/*
  Created by Warren Cedro 8/29/19
 */

import 'dart:async';

import 'package:av_asian_life/claims/view/claims_page.dart';
import 'package:av_asian_life/letter_of_guarantee/view/letter_of_guarantee_page.dart';
import 'package:av_asian_life/login/view/forgot_credentials_page.dart';
import 'package:av_asian_life/login/view/init_login.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/login/view/new_login_page.dart';
import 'package:av_asian_life/policy_details/policy_details_page.dart';
import 'package:av_asian_life/profile_page/profile_page.dart';
import 'package:av_asian_life/registration/forgot_password/view/forget_password_page.dart';
import 'package:av_asian_life/registration/forgot_username/forgot_username_page.dart';
import 'package:av_asian_life/registration/signup/view/card_number_signup.dart';
import 'package:av_asian_life/registration/signup/view/signup_page.dart';
import 'package:av_asian_life/registration/verification/view/verify_signup_page.dart';
import 'package:av_asian_life/reimbursement_form/view/reimbursement_form_page.dart';
import 'package:av_asian_life/splash_screen/intro_slider.dart';
import 'package:av_asian_life/splash_screen/splash_screen_page.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'FAQ/view/faq_page.dart';
import 'colors/decoration_pallete.dart';
import 'data_manager/user.dart';
import 'find_doctor/find_doctor_page.dart';
import 'find_provider/find_provider_page.dart';
import 'home_page/home_page.dart';
import 'inquiries/inquiries_page.dart';

void main() {

  //FirebaseAnalytics analytics = FirebaseAnalytics();

  //Disable orientation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) {

    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        LoginPage.tag: (context) => InitLogin(),
        HomePage.tag: (context) => HomePage(),
        LetterOfGuaranteePage.tag: (context) => LetterOfGuaranteePage(),
        FindProviderPage.tag: (context) => FindProviderPage(),
        FindDoctorPage.tag: (context) => FindDoctorPage(),
        ProfilePage.tag: (context) => ProfilePage(),
        PolicyDetailsPage.tag: (context) => PolicyDetailsPage(),
        InquiriesPage.tag: (context) => InquiriesPage(),
        ClaimsPage.tag: (context) => ClaimsPage(),
        SignUpPage.tag: (context) => SignUpPage(),
        ForgotPasswordPage.tag: (context) => ForgotPasswordPage(),
        ForgotUsernamePage.tag: (context) => ForgotUsernamePage(),
        CodeSignupPage.tag:(context) => CodeSignupPage(),
        ForgotUsernamePasswordPage.tag:(context) => ForgotUsernamePasswordPage()

      },
      theme: ThemeData(
        primaryColor: mPrimaryColor,
        accentColor: mAccentColor,
      ),
      //navigatorObservers: [ FirebaseAnalyticsObserver(analytics: analytics),
      //],
      home: SplashScreen(),));
  });


}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<bool> _mHasUserData;
  Future<bool> _isFresh;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isFresh = _initApp();
      _mHasUserData = initLogin();

    //  _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic>message) async {
    //     print("onMessage: $message");
    //   },
    //   onLaunch: (Map<String, dynamic>message) async {
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic>message) async {
    //     print("onResume: $message");
    //   }
    // );
    });

  }

  Future<bool> initLogin() async {
    print('initLogin: hasUserData');
    return myPreferenceHandler.hasUserData();
  }

  Future<bool> _initApp() async {
    print('_initApp: getInstallData');
    return myPreferenceHandler.getInstallData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: FutureBuilder<bool>(
          future: _isFresh,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot){
            if(snapshot.hasData) {
              if(!snapshot.data){
                return _getSplashScreenPage();
              }
              else {
                return IntroSliderPage();
              }
            }else {
              return IntroSliderPage();
            }
          }),
    );
  }

  Widget _getSplashScreenPage() {
    return Material(
      child: FutureBuilder<bool>(
        future: _mHasUserData,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return SplashScreenPage(hasData: -1,);
          }
          else {
            if (snapshot.data)
              return SplashScreenPage(hasData: 1,);
            else
              return SplashScreenPage(hasData: 0,);
          }
        },
      ),
    );
  }
}

