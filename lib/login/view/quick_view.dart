/*
  Created by Warren Cedro 8/29/19
 */

import 'dart:io';

import 'package:av_asian_life/FAQ/view/faq_page.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:av_asian_life/login/presenter/login_presenter.dart';
import 'package:av_asian_life/login/view/forgot_credentials_page.dart';
import 'package:av_asian_life/login/view/init_login.dart';
import 'package:av_asian_life/login/view/signup_login_page.dart';
import 'package:av_asian_life/registration/forgot_password/view/forget_password_page.dart';
import 'package:av_asian_life/registration/forgot_username/forgot_username_page.dart';
import 'package:av_asian_life/registration/signup/view/card_number_signup.dart';
import 'package:av_asian_life/registration/verification/view/verify_signup_page.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:trust_fall/trust_fall.dart';

import '../login_contract.dart';
import 'login_page.dart';


class SetQuickViewPage extends StatefulWidget {
  @override
  _SetQuickViewPageState createState() => _SetQuickViewPageState();
}

class _SetQuickViewPageState extends State<SetQuickViewPage> {
  

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _email = '';
  String _username = ''; //juan
  String _password = ''; //P@ssw0rd
  String _initPassword = ''; //password for fingerprint scanner
  String _cardNo;
  bool _cancelFingerprint = false;

  Member _member;

  bool _isInteractionDisabled = false;
  Widget _txtPassword;
  Widget _btnLogin;
  Widget _btnSignUp;
  Widget _btnForgotUsernamePassword;

  BuildContext mContext;

  String imageData;

  AlertDialog _loadingDialog;

  String useQuickView;

  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthorized;
  List<BiometricType> _availableBiometrics;

  @override
  void initState() {
    super.initState();
  }

  void setQuickView(String use) async {
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    await myPreferenceHandler.setQuickView(use);
  }
  

  @override
  Widget build(BuildContext context) {
    final _height = MediaQuery.of(context).size.height;
    return Container(
       decoration: myAppBackground(),
       height: _height,
       child: Stack(
         children: <Widget>[
           Scaffold(
             backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                elevation: 0.0,
              ),
              body: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: _height / 6,
                      child: Icon(Icons.fingerprint, size: _height / 6,),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("Would you like to use Quick View to access your account faster?", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 23.0), textAlign: TextAlign.center,)
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Material(
                          child: InkWell(
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: mPrimaryColor, width: 2)),
                              color: Colors.white,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(30, 12, 30, 12),
                                child: Text("No, Thanks", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0)),
                              ),
                              elevation: 0,
                            ),
                            onTap: (){
                              setQuickView('no');
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => LoginPage()));
                            },
                          ),
                        ),
                        RaisedButton(
                          elevation: 0,
                      child: Text("    Yes    ", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0)),
                      padding: EdgeInsets.fromLTRB(40, 12, 40, 12),
                      color: mPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      onPressed: (){
                        setQuickView('yes');
                        Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                    ),
                      ],
                    ),
                    SizedBox(
                      height: _height / 4,
                    )
                  ],
                ),
              ),
            )
          ]
        )
      );
  }
  
}


