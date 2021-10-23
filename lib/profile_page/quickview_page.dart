import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/signup_request.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class QuickViewPage extends StatefulWidget {
  @override
  _QuickViewPageState createState() => _QuickViewPageState();
}

class _QuickViewPageState extends State<QuickViewPage> {
  TextEditingController controller = TextEditingController();
  VerificationRequest _request;
  var _passwordcontroller = TextEditingController();
  Widget _txtPassword;

  double _height, _width;

  bool _codeVis = false, _btnVis = true, _isHidden  = true, passwordIconVis = false;

  double iconSize = .25;

  String useQuickView;

  String username;
  String password;

  String _password;
  AlertDialog _loadingDialog;

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  // void _getUsername() async{
  //   MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
  //   bool hasAuthData = await myPreferenceHandler.hasUserAuthData();
  //
  //   if(hasAuthData){
  //     User user = await myPreferenceHandler.getAuthData();
  //     print("User: ${user.username}");
  //     username = user.username;
  //   }
  // }
  void _getUsername() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.username = prefs.getString('_username');
    });
  }

  void _setQuickView(bool quik) async{
    print("setting quickview");
    String setter;
    if(quik == true){ setter = 'yes'; }
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    await myPreferenceHandler.setQuickView(setter);
  }

  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height * .85;
    _width = MediaQuery.of(context).size.width;

    _txtPassword = Focus(
      child: TextFormField(
        controller: _passwordcontroller,
        keyboardType: TextInputType.text,
        obscureText: _isHidden,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@#$%&*!-_.]'))],
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: 'Password',
          suffix: Visibility(
            visible: passwordIconVis,
            child: InkWell(
              onTap: _togglePasswordView,
              child: Icon(
                _isHidden
                    ? Icons.visibility_off
                    : Icons.visibility,
              ),
            ),
          ),
        ),
        onSaved: (String val) {
          password = val;
        },
        onChanged: (val){
          password = val;
        },
      ),
      onFocusChange: (hasFocus){
        if(hasFocus){
          setState((){
            passwordIconVis = true;
          });
        } else {
          setState((){
            passwordIconVis = false;
          });
        }
      },
    );
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
                elevation: 0,
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: _width * iconSize,
                          decoration: myAppLogo(),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: _height * .6,
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Visibility(
                                  visible: _btnVis,
                                  child: Container(
                                    height: _height * .5,
                                    child: Column(
                                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text('Quick View', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 30.0),),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 40.0,),
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.only(left: 30),
                                              child: Row(
                                                children: <Widget>[
                                                  Icon(Icons.person, size: 40,),
                                                  Text(this.username.toString(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.0),)
                                                ],
                                              ),
                                            ),
                                            Container(height: 1, color: Colors.black, margin: EdgeInsets.fromLTRB(30, 0, 30, 0)),
                                            SizedBox(height: 20.0,),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                              child: SizedBox(
                                                child: _txtPassword,
                                              ),
                                            ),
                                            //Container(height: 1, color: Colors.black, margin: EdgeInsets.fromLTRB(30, 0, 30, 0)),
                                          ],
                                        ),
                                        SizedBox(height: 40.0,),
                                        SizedBox(
                                          width: _width * .5,
                                          child: RaisedButton(
                                            padding: EdgeInsets.all(12),
                                            color: mPrimaryColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                            child: Text('Activate', style: TextStyle(color: Colors.black87)),
                                            onPressed: () async {
                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                              _password = prefs.getString('_password');
                                              var _email = prefs.getString('_email');
                                              var _base_url = await ApiHelper.getBaseUrl();
                                              var _api_user = await ApiHelper.getApiUser();
                                              var _api_pass = await ApiHelper.getApiPass();
                                              //await ApiToken.requestApiToken();
                                              var token = await ApiToken.getApiToken();



                                              String url = '${_base_url}ValidateCredentials';
                                              print(url);
                                              List data = [];

                                              var res = await http.post(
                                                url,
                                                headers: {
                                                  HttpHeaders.authorizationHeader: 'Bearer $token',
                                                  "UserAccount": _email
                                                },
                                                body : {
                                                  "api_userid" : _api_user,
                                                  "api_password" : _api_pass,
                                                  "app_userid" : this.username,
                                                  "app_password" : password
                                                }
                                              );
                                              var json = jsonDecode(jsonDecode(res.body));
                                              print(json);
                                              showMessageDialog(json[0]['msgDescription']);
                                              if(json[0]['msgCode'] == '007'){
                                                setState(() {
                                                  _btnVis = false;
                                                  _codeVis = true;
                                                  if(_height >= 566){
                                                    iconSize = .45;
                                                  } else{
                                                    iconSize = .30;
                                                  }
                                                  _setQuickView(true);
                                                });
                                              } else {
                                                _setQuickView(false);
                                              }

                                              // if (_passwordcontroller.text.toString() == ''){
                                              //   nullPassword();
                                              //   _setQuickView(false);
                                              // } else if(_passwordcontroller.text != _password){
                                              //   showMessageDialog('Incorrect password');
                                              //   _setQuickView(false);
                                              // } else {
                                              //   setState(() {
                                              //     _btnVis = false;
                                              //     _codeVis = true;
                                              //     if(_height >= 566){
                                              //       iconSize = .45;
                                              //     } else{
                                              //       iconSize = .30;
                                              //     }
                                              //     _setQuickView(true);
                                              //   });
                                              // }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Visibility(
                                  visible: _codeVis,
                                  child: Container(
                                    height: _height * .5,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text('Thank You!', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 40.0),),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Column(
                                            children: <Widget>[
                                              Text('Quick View Activated!', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.0),),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: _width * .5,
                                          child: RaisedButton(
                                            padding: EdgeInsets.all(12),
                                            color: mPrimaryColor,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                            child: Text('Close', style: TextStyle(color: Colors.black87)),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),


                              ],
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  height: 60,
                                  child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
                                ),
                                myMultimediaAccounts(),
                                Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: copyRightText()
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),]
                ),
              )
          ),
        ],
      ),
    );
  }

  void nullPassword(){
    _loadingDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      contentPadding: EdgeInsets.all(0.0),
      content: myLoadingIcon(height: 125, width: 20),
    );
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text("Warning"),
          content: new Text('Fill the required fields.'),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }

  void showMessageDialog(String message){
    _loadingDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      contentPadding: EdgeInsets.all(0.0),
      content: myLoadingIcon(height: 125, width: 20),
    );
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text(message, textAlign: TextAlign.center,),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        ));
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
}
