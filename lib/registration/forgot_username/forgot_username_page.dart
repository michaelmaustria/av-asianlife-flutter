import 'dart:async';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/choose_where_to_send_code_response.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/registration/forgot_password/forgot_password_contract.dart';
import 'package:av_asian_life/registration/forgot_password/presenter/forgot_password_presenter.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';


class ForgotUsernamePage extends StatefulWidget {
  static String tag = 'forgot-pass';
  @override
  _ForgotUsernamePageState createState() => _ForgotUsernamePageState();
}

class _ForgotUsernamePageState extends State<ForgotUsernamePage> implements IForgotPasswordView {
  final IForgotPasswordPresenter _mPresenter = ForgotPasswordPresenter();

  TextEditingController controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _changePassFormKey = GlobalKey<FormState>();
  var passKey = GlobalKey<FormFieldState>();
  bool _autoValidate = false;

  bool _isInteractionDisabled = false;
  VerificationRequest _request;
  double _height, _width;
  String _sendcodethru, _username, _cardNo, _code, _password, _email, _mobileNo;

  bool _isEmail = false, _isMobile = false, _isBtnResendEnable = false;

  AlertDialog _loadingDialog;
  bool _isRequesting = false;
  
  Timer _timer;
  int _start = 60;

  bool _userVis = true, _btnVis = false, _userBtnVis = true, _codeVis = false, _changePassVis = false;

  @override
  void initState() {
    super.initState();
    _mPresenter.onAttach(this);
  }

  @override
  void onSuccess(SignUpResponse response, String sender) {
    print('onSuccess: $sender : ${response?.msgDescription}');

    if(response?.msgDescription == 'Verification code sent') {
      Future.delayed(const Duration(seconds: 59), () {
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
      _userVis = false;
      _isRequesting = false;
    });
  }

  void _initResendVerificationRequest() {
    //sendcodethru 1 = email, 2 = sms
      setState(() {
        startTimer();
        _isBtnResendEnable = false;
        _isRequesting = true;
        _request = VerificationRequest(cardNo: _cardNo, sendcodethru: _sendcodethru);
        print('resend code V: ${_request.sendcodethru}');
        _mPresenter.reSendVerificationRequest(_request);
      });
  }

  void _initVerificationRequest() {
    //sendcodethru 1 = email, 2 = sms
    setState(() {
      startTimer();
      _isRequesting = true;
      _request = VerificationRequest(cardNo: _cardNo, sendcodethru: _sendcodethru);
      print('send code V: ${_request.sendcodethru}');
      print('send cardNo: ${_request.cardNo}');
      _mPresenter.sendVerificationRequest(_request);
    });
  }

  void _initAccountVerification() {
    if(_code != '' || _code != null) {
      _showLoadingDialog();
      setState(() {
        _isRequesting = true;
        _request = VerificationRequest(cardNo: _cardNo, sendcodethru: _sendcodethru, code: _code);
        _mPresenter.sendAccountVerification(_request);
      });
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
                    _userVis = false;
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
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text('Verify your account.', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),),
                                              SizedBox(height: 10.0,),
                                              Text('Please choose how you want to verify your account.', style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: <Widget>[
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
                                                });
                                                _initVerificationRequest();
                                              },
                                            ),
                                            SizedBox(height: 16.0,),
                                            OutlineButton(
                                              padding: EdgeInsets.all(16),
                                              color: mPrimaryColor,
                                              borderSide: BorderSide(color: mPrimaryColor),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                              child: Text('Send verification code to your Email address:  ${Common.formatEmail(_email)}', style: TextStyle(color: Colors.black87, fontSize: 16.0)),
                                              onPressed: !_isEmail ? null : () {
                                                //Init email verification.
                                                setState(() {
                                                  _sendcodethru = '1';
                                                  _userBtnVis = false;
                                                  _codeVis = true;
                                                });
                                                _initVerificationRequest();
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                Visibility(
                                  visible: _userVis,
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
                                              Text('Forgot Username', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),),
                                              SizedBox(height: 10.0,),
                                              Text('Please enter your registered e-mail address.', style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                          child: Form(
                                            key: _formKey,
                                            autovalidate: _autoValidate,
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                  child: TextFormField(
                                                    keyboardType: TextInputType.emailAddress,
                                                    enabled: !_isInteractionDisabled,
                                                    decoration: InputDecoration(
                                                      border: UnderlineInputBorder(),
                                                      hintText: "Email",
                                                      labelText: "Email",
                                                    ),
                                                    validator: _mPresenter.validateUserName,
                                                    onSaved: (String val) {
                                                      _username = val;
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
                                            onPressed: () {
                                              setState(() {
                                                _sendcodethru = '1';
                                                _userBtnVis = false;
                                                _userVis = false;
                                                _codeVis = true;
                                                _isBtnResendEnable = false;
                                                startTimer();
                                              });
                                            }
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
                                    Text('Please enter the verification code sent to your registered mobile number/email.', style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  children: <Widget>[
                                    PinCodeTextField(
                                      controller: controller,
                                      keyboardType: TextInputType.text,
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
                                  },
                                ),
                              ),
                              FlatButton(
                                child: Text('Resend Code', style: TextStyle(decoration: TextDecoration.underline)),
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
                                    Text('Password Reset', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.0),),
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
                                          key: passKey,
                                          keyboardType: TextInputType.text,
                                          obscureText: true,
                                          enabled: !_isInteractionDisabled,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            hintText: "Username",
                                            labelText: "Username",),
                                          validator: _mPresenter.validatePassword,
                                          onSaved: (String val) {

                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Text('*NOTE: Password must contain at least 1 uppercase, 1 number and have at least 8 characters.',
                                          style: TextStyle(fontSize: 10.0, fontStyle: FontStyle.italic),
                                          maxLines: 2,),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.text,
                                          obscureText: true,
                                          enabled: !_isInteractionDisabled,
                                          decoration: InputDecoration(
                                            border: UnderlineInputBorder(),
                                            hintText: "Password",
                                            labelText: "Re-Type Password",),
                                          validator: (confirmation){
                                            if (confirmation != passKey.currentState.value)
                                              return 'Passwords does not match';
                                            else return null;
                                          },
                                          onSaved: (String val) {
                                            _password = val;
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
                                  onPressed: _validateInputPassword,
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

}
