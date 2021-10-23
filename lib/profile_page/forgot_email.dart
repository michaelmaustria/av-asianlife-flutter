import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/choose_where_to_send_code_response.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/login/model/login_model.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/login/view/new_login_page.dart';
import 'package:av_asian_life/profile_page/profile_page.dart';
import 'package:av_asian_life/registration/forgot_password/forgot_password_contract.dart';
import 'package:av_asian_life/registration/forgot_password/presenter/forgot_password_presenter.dart';
import 'package:av_asian_life/success_screen/succes_screen_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';


class ForgotEmailPage extends StatefulWidget {
  static String tag = 'forgot-pass';
  final SendEmailPass sendEmailPass;
  ForgotEmailPage({this.sendEmailPass});
  @override
  _ForgotEmailPageState createState() => _ForgotEmailPageState();
}

class _ForgotEmailPageState extends State<ForgotEmailPage> implements IForgotPasswordView {
  final IForgotPasswordPresenter _mPresenter = ForgotPasswordPresenter();
  LoginModel loginModel = new LoginModel();
  IApplicationSession _appSessionCallback;
  Member _mMember;

  TextEditingController controller = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _reemailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _changePassFormKey = GlobalKey<FormState>();
  var passKey = GlobalKey<FormFieldState>();
  bool _autoValidate = false;

  bool _isInteractionDisabled = false;
  VerificationRequest _request;
  double _height, _width;
  String _sendcodethru, _username, _cardNo, _code, _password, _email, _reemail, _mobileNo;
  String mobileno;
  List msgCode = [];
  List memberInfo = [];
  String _messageCode;
  String _messageDesc;
  String _displayPic;

  bool _isEmail = false, _isMobile = false, _isBtnResendEnable = false;

  AlertDialog _loadingDialog;
  bool _isRequesting = false;

  Timer _timer;
  int _start = 60;

  bool _btnVis = true, _userBtnVis = true, _successVis = false, _codeVis = false, _changePassVis = false;

  //get http => null;

  getCardNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _mPresenter.onAttach(this);
    setState(() {
      this._cardNo = (prefs.getString('cardno') ?? '');
      print('cardNo: ${this._cardNo}');
    });
  }


  Future<String> updateContactInfo() async {
    dynamic data;
    String _msgCode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String url = "${_base_url}UpdateMemberContactInfo";
    var response = await http.post(
        Uri.encodeFull(url),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : this._cardNo,
        "mobileno" : this.mobileno,
        "emailadd" : _emailController.text,
        "displaypic" : "test",
        "otp" : _code
      }
    );
    print(url);
    data = json.decode(response.body);
    print(data);
    _msgCode = data;
    setState(() {
      msgCode = json.decode(_msgCode);
    });
    this._messageCode = msgCode[0]['msgCode'].toString();
    this._messageDesc = msgCode[0]['msgDescription'].toString();
    if(this._messageCode != '007'){
      showMessageDialog();
    } else {
      _changePassVis = false;
      showSuccessDialog();
       _successVis = true;
    }
    return "Success!";
  }

  Future<String> getMemberInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('_email');
    dynamic data;
    String _msgCode;
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();
    var response = await http.post(
        Uri.encodeFull("${_base_url}MemberInfo"),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": email,
        "DeviceID": _deviceId
      },
      body : {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : this._cardNo,
        "frommain" : "0"
      }
    );
    data = json.decode(response.body);
    _msgCode = data;
    setState(() {
      memberInfo = json.decode(_msgCode);
    });
    this._displayPic = memberInfo[0]['displaypic'].toString();
    this.mobileno = memberInfo[0]['mobileno'].toString();
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    getCardNo();
    getMemberInfo();
    _mPresenter.onAttach(this);

    _mobileNo = widget.sendEmailPass.mobile;
    if(_mobileNo != null) _isMobile = true;
  }

  @override
  void onSuccess(SignUpResponse response, String sender) {
    print('onSuccess: $sender : ${response?.msgDescription}');

    if(response?.msgDescription == 'Verification code sent') {
      Future.delayed(const Duration(seconds: 60), () {
        setState(() {
          _isBtnResendEnable = true;
          print('isBtnResendEnable Success: $_isBtnResendEnable');
        });
      });
    }

    setState(() {
      _isRequesting = false;
    });
    print('onSuccess: $sender : $response');

    if(sender == 'account-v') {
      _closeAlert();
    }
  }

  @override
  void onError(String message, String sender) {
    print('onError: $sender : $message');

    if(sender == 'r-verification'){
      setState(() {
        _isBtnResendEnable = true;
        print('isBtnResendEnable Success: $_isBtnResendEnable');
      });
    }

    _closeAlert();
    _showAlertDialog(false, message, sender);

    setState(() {
      _isRequesting = false;
    });
  }


  @override
  void resetPasswordSuccess(SignUpResponse response) {
    _closeAlert();
    _changePassSuccessDialog('Message',response.msgDescription);
  }

  @override
  void accountVerificationSuccess(SignUpResponse response) {
    _closeAlert();
    setState(() {
      _isInteractionDisabled = false;
      _codeVis = false;
      _changePassVis = true;
    });
  }

  @override
  void forgotPasswordRequestSuccess(ChooseWhereToSendCodeResponse response, String cardNo) {
    _closeAlert();

    _cardNo = cardNo;
    _email = response?.email != null ? response?.email : null;
    _mobileNo = response?.mobileno != null ? response?.mobileno : null;
    if(response.mobileno != null)
      _isMobile = true;
    else
      _isMobile = false;

    if(response.email != null)
      _isEmail = true;
    else
      _isEmail = false;

    setState(() {
      _btnVis = true;
      
      _isRequesting = false;
    });
  }

  void _initResendVerificationRequest() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //sendcodethru 1 = email, 2 = sms
      setState(() {
        startTimer();
        _isBtnResendEnable = false;
        _isRequesting = true;
        _request = VerificationRequest(cardNo: prefs.getString('_email'), sendcodethru: _sendcodethru);
        print('resend code V: ${_request.sendcodethru}');
        _mPresenter.reSendVerificationRequest(_request);
      });
  }

  void _initVerificationRequest() {
    //sendcodethru 1 = email, 2 = sms
    setState(() {
      //startTimer();
      _isRequesting = true;
      _request = VerificationRequest(cardNo: this._cardNo, sendcodethru: _sendcodethru);
      print('send code V: ${_request.sendcodethru}');
      print('send cardNo: ${_request.cardNo}');
      _mPresenter.sendVerificationRequest(_request);
    });
  }

  void _initAccountVerification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('otp',_code);
    if(_code != '' || _code != null) {
      _showLoadingDialog();
      setState(() {
        _isRequesting = true;
        _request = VerificationRequest(cardNo: prefs.getString('_email'), sendcodethru: _sendcodethru, code: _code);
        _mPresenter.sendAccountVerification(_request);
      });
    } else {
      _codeVis = false;
      _changePassVis = true;
    }
  }

  void startTimer() {
  const oneSec = const Duration(seconds: 1);
  _timer = new Timer.periodic(
    oneSec,
    (Timer timer) => setState(
      () {
        if (_start < 1) {
          timer.cancel();
          _start = 60;
          _isBtnResendEnable = true;
        } else {
          _start = _start - 1;
        }
      },
    ),
  );
}

 @override
void dispose() {
  _timer.cancel();
  super.dispose();
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

  void _showAlertDialog(bool isSuccess, String text, String code) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text(isSuccess ? "Success" : "Warning"),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(isSuccess ? "Account Verified" : text == '' ? "Verification Falied" : text),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            setState(() {
              if(isSuccess) {
                if(code == 'r-forgot') {
                  setState(() {
                    _btnVis = true;
                  });
                  Navigator.of(this.context).pop('dialog');
                } else if (code == 'reset-success') {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(
                      LoginPage.tag, (Route<dynamic> route) => false
                  );
                }
              }else {
                _isInteractionDisabled = false;
                Navigator.of(this.context).pop('dialog');
              }
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

  void _changePassSuccessDialog(String title, String body) {
    // set up the AlertDialog
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
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(
                  LoginPage.tag, (Route<dynamic> route) => false
              );
            });
          },
        )
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: this.context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _closeAlert() {
    Navigator.pop(context);//it will close last route in your navigator
  }

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
              body: SingleChildScrollView(
                child: Container(
                  height: _height,
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        height: _width * .25,
                        decoration: myAppLogo(),
                      ),
                      Visibility(
                        visible: _userBtnVis,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: _height * .6,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                              Text('Verify your account.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),),
                                              SizedBox(height: 10.0,),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: <Widget>[
                                            SizedBox(height: _height * .15),
                                            OutlineButton(
                                              padding: EdgeInsets.all(16),
                                              color: mPrimaryColor,
                                              borderSide: BorderSide(color: mPrimaryColor),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                              child: Text('Send verification code to your Mobile Number:  ${Common.formatMobileNo(_mobileNo)}', style: TextStyle(color: Colors.black87, fontSize: 16.0)),
                                              onPressed: !_isMobile ? null : () {
                                                setState(() {
                                                  _sendcodethru = '2';
                                                  _userBtnVis = false;
                                                  _codeVis = true;
                                                  _isBtnResendEnable = false;
                                                });
                                                _initResendVerificationRequest();
                                                //_initVerificationRequest();
                                                //startTimer();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                    Text('Key in your verification code.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),),
                                    SizedBox(height: 10.0,),
                                    Text('Please enter the verification code sent to your Mobile Number.', style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  children: <Widget>[
                                    PinCodeTextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      highlight: true,
                                      highlightColor: mAccentColor,
                                      defaultBorderColor: mPrimaryColor,
                                      hasTextBorderColor: mPrimaryColor,
                                      pinCodeTextFieldLayoutType: PinCodeTextFieldLayoutType.AUTO_ADJUST_WIDTH,
                                      wrapAlignment: WrapAlignment.start,
                                      pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                                      pinTextStyle: TextStyle(fontSize: 30.0),
                                      pinBoxHeight: 50.0,
                                      pinBoxWidth: 50.0,
                                      onDone: (text) {
                                        print("Code: $text");
                                        _code = '';
                                        _code = text;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: _width * .5,
                                child: RaisedButton(
                                  padding: EdgeInsets.all(12),
                                  color: mPrimaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  child: Text('Verify', style: TextStyle(color: Colors.black87)),
                                  onPressed: () {
                                    _initAccountVerification();
                                    // _codeVis = false;
                                    // _changePassVis = true;
                                  },
                                ),
                              ),
                              FlatButton(
                                child: Text('Resend Code'),
                                onPressed: _isBtnResendEnable ? _initResendVerificationRequest : null,
                              ),
                              Container(
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: mPrimaryColor,
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: _isBtnResendEnable == true ? Text('0', style: TextStyle(color: Colors.grey, fontSize: 17),) : Text('$_start',style: TextStyle(fontSize: 17)),
                                  )
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                          visible: _successVis,
                          child: Container(
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: EdgeInsets.fromLTRB(60, 10, 60, 10),
                              child: Text('Close', style: TextStyle(fontSize: 20)),
                              color: mPrimaryColor,
                              onPressed: (){
                                Navigator.pop(context);
                              },
                            ),
                          )
                      ),
                      Visibility(
                        visible: _changePassVis,
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
                                    Text('Change Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),),
                                    SizedBox(height: 10.0,),
                                    Text('', style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Form(
                                  key: _changePassFormKey,
                                  autovalidate: _autoValidate,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: TextFormField(
                                          controller: _emailController,
                                          key: passKey,
                                          keyboardType: TextInputType.text,
                                          obscureText: false,
                                          enabled: !_isInteractionDisabled,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            hintText: "New Email",
                                            labelText: "New Email",),
                                          validator: _mPresenter.validatePassword,
                                          onSaved: (String val) {
                                            _email = val;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: TextFormField(
                                          controller: _reemailController,
                                          keyboardType: TextInputType.text,
                                          obscureText: false,
                                          enabled: !_isInteractionDisabled,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            hintText: "Re-Type New Email",
                                            labelText: "Re-Type New Email",),
                                          validator: (confirmation){
                                            if (confirmation != passKey.currentState.value)
                                              return 'Email does not match';
                                            else return null;
                                          },
                                          onSaved: (String val) {
                                            _reemail = val;
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: _width * .5,
                                child: RaisedButton(
                                  padding: EdgeInsets.all(12),
                                  color: mPrimaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                  child: Text('Submit', style: TextStyle(color: Colors.black87)),
                                  onPressed: () async {
                                    //_validateInputPassword();
                                    if(_emailController.text != _reemailController.text){
                                      emailNotMatch();
                                    } else if((_emailController.text) == '' || (_reemailController.text) == ''){
                                      invalidEmail();
                                    } else {
                                      updateContactInfo();
                                    }
                                    _appSessionCallback.pauseAppSession();
                                  }
                                ),
                              ),
                              FlatButton(
                                child: Text(''),
                                onPressed: null,
                              )
                            ],
                          ),
                        ),
                      ),


                      Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text('Powered by:', style: TextStyle(color: Colors.black87)),
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
                ),
              )
          ),
        ],
      ),
    );
  }

  void _validateInputs() {
    print('_validateInputs');
    setState(() {
      if (_formKey.currentState.validate()) {
        _showLoadingDialog();
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _formKey.currentState.save();

        _mPresenter.sendForgotPasswordRequest(_username);
      } else {
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }

    });
  }

  void _validateInputPassword() {
    print('_validateInputPassword');
    setState(() {
      if (_changePassFormKey.currentState.validate()) {
        _showLoadingDialog();
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _changePassFormKey.currentState.save();

       _mPresenter.sendResetPassword(_password, _cardNo);
      } else {
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }

    });
  }
 void invalidEmail(){
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
         content: new Text("Please fill all required fields."),
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
  void emailNotMatch(){
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
          content: new Text("Email does not match."),
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
  void showSuccessDialog(){
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
          title: new Text(''),
          content: new Text('${this._messageDesc}.\n You will need to re-login.', textAlign: TextAlign.center),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                await loginModel.LogOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('_email', _emailController.text);
                ApiToken.registerApiToken();
                Navigator.of(context)
                    .pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => NewLoginPage()
                    ),
                        (Route<dynamic> route) => false
                );
                //_navigateToHomePage(this._cardNo);
              },
            )
          ],
        ));
  }
  void showMessageDialog(){
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
          content: new Text(this._messageDesc, textAlign: TextAlign.center),
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
}
