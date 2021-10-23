/*
  Created by Warren Cedro 8/29/19
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/FAQ/view/faq_page.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/offline_page.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:av_asian_life/login/presenter/login_presenter.dart';
import 'package:av_asian_life/registration/forgot_password/view/forget_password_page.dart';
import 'package:av_asian_life/registration/forgot_username/forgot_username_page.dart';
import 'package:av_asian_life/registration/signup/view/signup_page.dart';
import 'package:av_asian_life/registration/verification/view/verify_signup_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:trust_fall/trust_fall.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../data_manager/no_connection_page.dart';
import '../login_contract.dart';


class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> implements ILoginView {
  final ILoginPresenter _mPresenter = LoginPresenter();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  PageController _controller = PageController(
    initialPage: 0
  );

  var _usernamecontroller = TextEditingController();
  var _passwordcontroller = TextEditingController();

  bool _autoValidate = false;
  bool _isAuthorized;
  bool _isInteractionDisabled = false;
  bool _isHidden  = true;
  bool userCancelVis = false;
  bool passwordIconVis = false;

  String _email = '';
  String _username = ''; //juan
  String _password = ''; //P@ssw0rd
  String _cardNo;
  String _imgUrl;
  String _imgLink;

  List imgUrl = [];
  List imgLink = [];
  List imgUrls = [];
  List imgLinks = [];

  Widget _txtUsername;
  Widget _txtPassword;
  Widget _btnLogin;
  Widget _btnSignUp;
  Widget _btnForgotPass;
  Widget _btnForgotUsername;
  Widget _btnForgotUsernamePassword;
  Widget _btnFaq;

  int index = 0;

  AlertDialog _loadingDialog;

  final LocalAuthentication auth = LocalAuthentication();

  List<BiometricType> _availableBiometrics;

  @override
  void initState() {
    print('login page.');
    super.initState();
    setState((){
      getAnnouncements(context);
      checkConnection();
      getSystemStatus();
    });
    initBiometricTest();

    _mPresenter.onAttach(this);
  }

  initBiometricTest(){
    Future.wait([
      _checkJailbreak(),
      _checkBiometrics(),
      _getAvailableBiometrics(),
    ]);
  }

  void checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
      }
    } on SocketException catch (_) {
      print('not connected');
      Navigator.of(context)
          .pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => OfflinePage()
          ),
              (Route<dynamic> route) => false
      );
    }
  }

  Future getSystemStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var _base_url = await ApiHelper.getBaseUrl();

    dynamic data;
    dynamic status = [];
    dynamic stats = [];

    String _status;

    var response = await http.get(
      Uri.encodeFull('${_base_url}CheckSystemStatus'),
    );
    data = json.decode(response.body);
    _status = data;
    setState(() {
      status = json.decode(_status);
    });
    for(var i = 0; i < status.length; i++){
      stats.add(status);
    }
    if(stats[0]['SystemStatus'] != '1'){
      Navigator.of(context)
          .pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => OfflineApiPage()
          ),
              (Route<dynamic> route) => false
      );
    }
    return "Success!";
  }

  Future<String> getAnnouncements(BuildContext context) async {
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    dynamic data;
    try {
      var response = await http.post(
        Uri.encodeFull('${_base_url}GetAnnouncements'),
        body: {
          "userid" : _api_user,
          "password" : _api_pass
        }
      );
      data = json.decode(response.body);
      _imgUrl = data;
      _imgLink = data;
      setState(() {
        imgUrl = json.decode(_imgUrl);
        imgLink = json.decode(_imgLink);
      });
      for(var i = 0; i < imgUrl.length; i++){
        imgUrls.add(imgUrl[i]["url"]);
        imgLinks.add(imgLink[i]["link"]);
      }
      if(imgUrls.length != 0){
        WidgetsBinding.instance.addPostFrameCallback((_) => showPromotionsDialog(context));
      }
    } on Exception catch (e) {
      Navigator.pop(context);
    }
    return "Success!";
  }

  @override
  void onSuccess(Member member) {
    print('onSuccess: init navigate to HomePage');
    if(member.cardno != null) {
      print('member card: ${member.cardno}');
      print('Name: ${member.firstName} ${member.lastName}');
      print('Picture: ${member.displaypic}');

      Navigator.of(context)
          .pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => HomePage(member: member)
          ),
              (Route<dynamic> route) => false
      );

    }else {
      _closeAlert();
      _showAlertDialog(false, '');
    }
  }
  @override
  void onError(String cardNo, String message) {
    print('onError: $message');
    setState(() {
      _isInteractionDisabled = false;
    });
    _closeAlert();

    if(message == 'Account not yet verified' || message == 'You have entered an invalid verification code.')
      _showNotVerifiedDialog(cardNo, message);
    else
      _showAlertDialog(false, message);


  }


  @override
  Widget build(BuildContext context) {
    _txtUsername =
      Focus(
      child: TextFormField(
        controller: _usernamecontroller,
        keyboardType: TextInputType.emailAddress,
        enabled: !_isInteractionDisabled,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          hintText: "Username",
          labelText: "Username",
          suffix: Visibility(
            visible: userCancelVis,
            child: InkWell(
              onTap: () =>_usernamecontroller.clear(),
              child: Icon(
                  Icons.cancel,
              ),
            ),
          ),
        ),
        validator: _mPresenter.validateUserName,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@#$%&*!-_.]'))],
        onSaved: (String val) {
          _username = val;
        },
      ),
      onFocusChange: (hasFocus){
        if(hasFocus){
          setState((){
            userCancelVis = true;
          });
        } else {
          setState((){
            userCancelVis = false;
          });
        }
      },
    );

    _txtPassword = Focus(
      child: TextFormField(
        controller: _passwordcontroller,
        keyboardType: TextInputType.text,
        obscureText: _isHidden,
        enabled: !_isInteractionDisabled,
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
        validator: _mPresenter.validatePassword,
        onSaved: (String val) {
          _password = val;
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

    _btnLogin = RaisedButton(
      padding: EdgeInsets.all(12),
      color: mPrimaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Text('Log In', style: TextStyle(color: Colors.black54)),
      onPressed: _isInteractionDisabled ? null : _validateInputs,
    );

    _btnSignUp = OutlineButton(
      padding: EdgeInsets.all(12),
      color: mPrimaryColor,
      borderSide: BorderSide(color: mPrimaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Text('Sign Up', style: TextStyle(color: Colors.black54)),
      onPressed: _isInteractionDisabled ? null : () {
        Navigator.pushNamed(context, SignUpPage.tag);
        // Navigator.push(context,
        // MaterialPageRoute(builder: (context) => CodeSignupPage()));
      } ,
    );

    _btnForgotPass = FlatButton(
      child: Text('Forgot Password',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: _isInteractionDisabled ? null : () {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
      } ,
    );

    _btnForgotUsername = FlatButton(
      child: Text('Forgot Username',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: _isInteractionDisabled ? null : () {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => ForgotUsernamePage()));
        //Navigator.pushNamed(context, ForgotUsernamePage.tag);
      } ,
    );

    _btnFaq = FlatButton(
      child: Text('FAQ          ',
        style: TextStyle(color: Colors.black),
      ),
      onPressed: _isInteractionDisabled ? null : () {
        Navigator.push(context,
        MaterialPageRoute(builder: (context) => FaqPage()));
        //Navigator.pushNamed(context, ForgotUsernamePage.tag);
      } ,
    );

    _btnForgotUsernamePassword = FlatButton(
      child: Text('Forgot username/password?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: _isInteractionDisabled ? null : () {
        Navigator.pushNamed(context, ForgotUsernamePage.tag);
      } ,
    );

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      decoration: myAppBackground(),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: Container(
              height: height,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  SizedBox(height: 1.0,),
                  Container(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: EdgeInsets.only(right: 30),
                        child:  InkWell(
                          onTap: (){
                            // Navigator.push(context,
                            // MaterialPageRoute(builder: (context) => FaqPage()));
                            Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (context, _, __) => _questionMark(context), opaque: false));
                          },
                          child: Icon(Icons.question_answer),
                        )
                      )
                    ),
                  ),
                  Container(
                    height: width * .25,
                    decoration: myAppLogo(),
                  ),
                  _textFields(height, width),
                  //_loginOptions(height, width),
                  SizedBox(height: width / 8,),
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
                        ],
                      )
                  ),
                ],
              ),
            ),
          )
        ),
    );
  }

  Widget _textFields(double height, double width) {
    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                child: _txtUsername,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                child: _txtPassword,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                      child: _btnSignUp
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                      child: _btnLogin
                  ),
                ],
              )
            ),
            // Align(
            //   alignment: Alignment.bottomCenter,
            //   child: _btnForgotUsernamePassword,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _getLoginOptionIcons(String image, String text){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(image,
          fit: BoxFit.contain,
          height: 40,
        ),
        SizedBox(
          height: 10.0,
        ),
        SizedBox(
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              fontSize: 10.0
          ),),
        ),
      ],
    );
  }

  Widget _loginOptions(double height, double width){
    return Container(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Text('Login Via',
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.0
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
            // child: Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: <Widget>[
            //     InkWell(
            //       onTap: () {
            //         if(_availableBiometrics.contains(BiometricType.face) || _availableBiometrics.contains(BiometricType.fingerprint))
            //           _authenticate('face-id');
            //         else
            //           _messageDialog('Warning', 'This service may not be supported by your device.');
            //       },
            //       child: _getLoginOptionIcons('assets/images/face_id_finger_scan_v1.png', 'Fingerprint'),
            //     ),
            //   ],
            // ),
          ),
        ],
      ),
    );
  }

  void _showNotVerifiedDialog(String cardNo, String msg) {
    print('_showNotVerifiedDialog');
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text("Warning"),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(msg),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            setState(() {
              _isInteractionDisabled = false;
              Navigator.of(this.context).pop('dialog');
              Navigator.of(context)
                  .pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => VerifySignUpPage(cardNo: cardNo, isForVerification: true,)
                  ), (Route<dynamic> route) => false
              );

            });
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showAlertDialog(bool isSuccess, String text) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text(isSuccess ? "Success" : "Warning"),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(isSuccess ? "Login Verified" : text == '' ? "Can't establish session. Please try re-registering or changing your password." : text, textAlign: TextAlign.center,),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            setState(() {
              _isInteractionDisabled = false;
              Navigator.of(this.context).pop('dialog');
            });
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _showLoadingDialog() {
    // set up the AlertDialog
    _loadingDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      contentPadding: EdgeInsets.all(0.0),
      content: myLoadingIcon(height: 125, width: 20),
    );

    // show the dialog
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _loadingDialog;
      },
    );

  }

  void _showJailBrokenDialog() {
    String platform;
    if (Platform.isAndroid) {
      // Android-specific code
      platform = 'Rooted';
    } else if (Platform.isIOS) {
      // iOS-specific code
      platform = 'Jail Broken';
    }

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text('Warning: $platform Device'),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text('A $platform device allows the attackers with privileged user access to steal client information stored on the device.'),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('Close App'),
          onPressed: () {
            setState(() {
              exit(0);
            });
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );

  }

  void _closeAlert() {
    Navigator.pop(context);//it will close last route in your navigator
  }

  void _validateInputs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_formKey.currentState.validate()) {
        _showLoadingDialog();
        prefs.setString('_username', _usernamecontroller.text);
        prefs.setString('_password', _passwordcontroller.text);
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _formKey.currentState.save();

        _mPresenter.initLoginProcess(User(username: _username, password: _password, cardNo: _cardNo, email: _email));
        Timer(Duration(seconds: 60), () {
          setState((){
            Navigator.pop(context);
            showMessageDialog();
          });
        });
        addUsername();
      } else {
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }

    });
  }

  Future<void> _checkJailbreak() async {
    bool isJailBroken;
    try {
      isJailBroken = await TrustFall.isJailBroken;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      print('isRooted: $isJailBroken');
      if(isJailBroken)
        _showJailBrokenDialog();
    });
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      print('canCheckBiometrics: $canCheckBiometrics');
      //_canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      print('availableBiometrics: $availableBiometrics');
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate(String mode) async {
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    bool hasAuthData = await myPreferenceHandler.hasUserAuthData();

    if(hasAuthData) {
      bool authenticated = false;
      User user = await myPreferenceHandler.getAuthData();
      try {
        authenticated = await auth.authenticateWithBiometrics(
            localizedReason: 'You were logged in as ${user.username}',
            useErrorDialogs: true,
            stickyAuth: true);
      }catch (e) {
        _messageDialog('Finger Print Exception', e);
        print(e);
      }

      if (!mounted) return;

      setState(() {
        _isAuthorized = authenticated;
      });

      if(_isAuthorized) {
        _showLoadingDialog();
        _isInteractionDisabled = true;

        if(user.email != null)
          _email = user.email;

        _mPresenter.initLoginProcess(User(username: user.username, password: user.password, email: _email));
      }else{
        initBiometricTest();
      }
    } else {
      print('No Login data');
      _messageDialog('Message', 'No login data available.');
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
          child: Text("OK"),
          onPressed: () {
            setState(() {
              _isInteractionDisabled = false;
              Navigator.of(this.context).pop('dialog');
              //Redirect UI to another page i.e. HomePage
            });
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _questionMark(BuildContext context,) {
    final _height = MediaQuery.of(context).size.height;
    context = this.context;
    return Container(
      color: Colors.grey[600].withOpacity(.8),
      padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
      child: SafeArea(
        child: Stack(children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Column(children: <Widget>[
              SizedBox(height: _height * .65),
              Container(
                child:Card(
                shape: new RoundedRectangleBorder(
                   borderRadius: new BorderRadius.circular(10.0)
                ),
                color: Colors.white,
                child: Stack(
                  children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: <Widget>[
                // Container(
                //     alignment: AlignmentDirectional.topStart,
                //     margin: EdgeInsets.fromLTRB(15, 10, 10, 0),
                //     child: Row(children: <Widget>[
                //       Icon(Icons.person),
                //       _btnForgotUsername
                //     ],)
                // ),
                // Container(
                //   color: Colors.black,
                //   height: 1,
                // ),
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.fromLTRB(15, 5, 10, 0),
                    child: Row(children: <Widget>[
                      Icon(Icons.lock),
                      _btnForgotPass
                    ],)
                ),
                Container(
                  color: Colors.black,
                  height: 1,
                ),
                Container(
                    alignment: AlignmentDirectional.topStart,
                    margin: EdgeInsets.fromLTRB(15, 5, 10, 0),
                    child: Row(children: <Widget>[
                      Icon(Icons.question_answer),
                      _btnFaq
                    ],)
                )
              ],
            ),
          ),
        ]))),
        Container(
          height: 40,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: Icon(Icons.close, color: Colors.white, size: 40,),
            ),
          ),
        )
            ],
            )
          ),
        ],
        ),
      )
      );
  }

  void showMessageDialog(){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text('SMILE PH is unavailable right now but we are working to have things back to normal soon. Please try again later.', textAlign: TextAlign.center,),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
               Navigator.pop(context);
              },
            )
          ],
        ));
  }

  void showPromotionsDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
          builder: (_) => new Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: EdgeInsets.all(1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:<Widget>[
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: Colors.white, size: 40)
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.07,)
                  ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:<Widget>[
                    InkWell(
                        onTap: (){
                          setState((){
                            if(index >=1){
                              index -= 1;
                              Navigator.pop(context);
                              showPromotionsDialog(context);
                            }
                          });
                        },
                        child: Icon(Icons.arrow_left, color: Colors.white, size: 40)
                    ),
                    Container(
                      color: Colors.yellow[700],
                      height:  MediaQuery.of(context).size.height * 0.6,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: InkWell(
                        onTap: (){
                          launch(imgLinks[index]);
                        },
                        child: Image.network(
                            imgUrls[index],
                            fit: BoxFit.fill,
                            loadingBuilder:(BuildContext context, Widget child,ImageChunkEvent loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null ?
                                  loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                                      : null,
                                ),
                              );
                            },
                        )
                      )
                    ),
                    InkWell(
                        onTap: (){
                          setState((){
                            if(index < imgUrls.length-1){
                              index += 1;
                              Navigator.pop(context);
                              showPromotionsDialog(context);
                            }
                          });
                        },
                        child: Icon(Icons.arrow_right, color: Colors.white, size: 40)
                    ),
                  ]
                ),
                ],
              )
      )
    );
    // showDialog(
    //     context: context,
    //     builder: (_) => new AlertDialog(
    //       backgroundColor: Colors.transparent,
    //       elevation: 0,
    //       insetPadding: EdgeInsets.all(1),
    //       //contentPadding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 24.0),
    //       content: Row(
    //         children:<Widget>[
    //           InkWell(
    //               onTap: (){
    //                 Navigator.pop(context);
    //               },
    //               child: Icon(Icons.arrow_left, color: Colors.white, size: 25)
    //           ),
    //           Column(
    //               mainAxisSize: MainAxisSize.min,
    //               children: <Widget>[
    //                 Row(
    //                     mainAxisAlignment: MainAxisAlignment.end,
    //                     children: <Widget>[
    //                       InkWell(
    //                           onTap: (){
    //                             Navigator.pop(context);
    //                           },
    //                           child: Icon(Icons.close, color: Colors.white, size: 40)
    //                       ),
    //                     ]
    //                 ),
    //                 Container(
    //                     color: Colors.red,
    //                     height:  MediaQuery.of(context).size.height * 0.5,
    //                     width: MediaQuery.of(context).size.width * 0.75,
    //                     child: Column(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.stretch,
    //                         children:<Widget>[
    //                           // CarouselSlider(
    //                           //   options: CarouselOptions(height: MediaQuery.of(context).size.height* 0.5),
    //                           //   items: imgUrls.map((i) {
    //                           //     return Builder(
    //                           //       builder: (BuildContext context) {
    //                           //         return Container(
    //                           //             width: MediaQuery.of(context).size.width,
    //                           //             //margin: EdgeInsets.symmetric(horizontal: 5.0),
    //                           //             decoration: BoxDecoration(
    //                           //                 color: Colors.amber
    //                           //             ),
    //                           //             child: InkWell(
    //                           //               onTap: (){
    //                           //                 int index = imgUrls.indexOf(i);
    //                           //                 launch(imgLinks[index]);
    //                           //               },
    //                           //               child: Image.network(i,fit: BoxFit.fill)
    //                           //             )
    //                           //         );
    //                           //       },
    //                           //     );
    //                           //   }).toList(),
    //                           // )
    //                         ]
    //                     )
    //                 )
    //               ]
    //           ),
    //           InkWell(
    //               onTap: (){
    //                 Navigator.pop(context);
    //               },
    //               child: Icon(Icons.arrow_right, color: Colors.white, size: 25)
    //           ),
    //         ]
    //       ),
    //     ));
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }
  addUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('UserName',_usernamecontroller.text);
  }
}

