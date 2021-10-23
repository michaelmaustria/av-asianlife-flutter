import 'dart:async';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/registration/forgot_password/view/forget_password_page.dart';
import 'package:av_asian_life/registration/forgot_username/forgot_username_page.dart';
import 'package:flutter/material.dart';


class ForgotUsernamePasswordPage extends StatefulWidget {
  static String tag = 'forgot-pass';
  @override
  _ForgotUsernamePasswordPageState createState() => _ForgotUsernamePasswordPageState();
}

class _ForgotUsernamePasswordPageState extends State<ForgotUsernamePasswordPage>{

  double _height, _width;
  
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height * .85;
    _width = MediaQuery.of(context).size.width;

    return Container(
      height: _height,
      width: _width,
      decoration: myAppBackground(),
      child: Stack(
        children: <Widget>[
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
              body: Container(
                height: _height,
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: _width * .25,
                      decoration: myAppLogo(),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: <Widget>[
                          Text('Forgot Username/Password', style: TextStyle(fontSize: 22, fontWeight: FontWeight.normal),),
                          SizedBox(height: 10,),
                          Text('Please Choose'),
                          SizedBox(height: 20,),
                          Container(
                            height: 80,
                            width: _width * .85,
                            child: RaisedButton(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(side: BorderSide(color: mPrimaryColor)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Forgot Username?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),),
                                  Icon(Icons.arrow_forward_ios, color: mPrimaryColor,)
                                ],
                              ),
                              onPressed: (){
                                Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ForgotUsernamePage()));
                              },
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            height: 80,
                            width: _width * .85,
                            child: RaisedButton(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(side: BorderSide(color: mPrimaryColor)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text('Forgot Password?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
                                  Icon(Icons.arrow_forward_ios, color: mPrimaryColor,)
                                ],
                              ),
                              onPressed: (){
                                Navigator.push(context,
                                MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: _height /20),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Powered by:', style: TextStyle(color: Colors.black87, fontSize: 12.0)),
                          SizedBox(
                            height: 55,
                            child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
                          ),
                          myMultimediaAccounts(),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: copyRightText()
                          ),
                        ]
                      ),
                    )
                  ]
                ),
              ),
          )
        ]
      )
    );
  }

}