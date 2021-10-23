import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/signup_request.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/login/view/login_page.dart';
import 'package:av_asian_life/login/view/quick_view.dart';
import 'package:av_asian_life/login/view/signup_login_page.dart';
import 'package:av_asian_life/profile_page/quickview_page.dart';
import 'package:av_asian_life/registration/verification/presenter/verification_presenter.dart';
import 'package:av_asian_life/registration/verification/verification_contract.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VerifySignUpPage extends StatefulWidget {
  final String cardNo;
  final SignUpRequest request;
  final bool isForVerification;

  VerifySignUpPage({this.cardNo, this.request, this.isForVerification});

  @override
  _VerifySignUpPageState createState() => _VerifySignUpPageState();
}

class _VerifySignUpPageState extends State<VerifySignUpPage> implements IVerificationView {
  final IVerificationPresenter _mPresenter = VerificationPresenter();
  TextEditingController controller = TextEditingController();
  VerificationRequest _request;

  double _height, _width;
  String _cardNo, _code = '', _sendcodethru = '' , _mobileno = '', _email = '';

  bool _codeVis = false, _btnVis = true, _isBtnResendEnable = false, _mobileNoVis = false;
  AlertDialog _loadingDialog;
  bool _isRequesting = false;

  Timer _timer;
  int _start = 60;

  getCardNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    String mobileno;
    String email;
    print('getMemberInfo');
    setState(() {
      this._cardNo = (prefs.getString('_Cardno') ?? '');
    });

    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();

    String url = '${_base_url}MemberInfo?userid=$_api_user&password=$_api_pass&cardno=${this._cardNo}&frommain=0';

    List<Member> data = [];
    var res = await http.post(
        url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email,
        "DeviceID": _deviceId
      },
      body : {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : this._cardNo,
        "frommain" : "0"
      }
    );
    var json = jsonDecode(jsonDecode(res.body));
    print(json);

    json.forEach((entity) {
      setState(() {
        data.add(Member.fromJson(entity));
        this._mobileno = entity['mobileno'].toString();
        this._email = entity['email'].toString();
        print('cardNo: ${this._cardNo}');
        print('mobileno: ${this._mobileno}');
        print('email: ${this._email}');
        prefs.setString('email',this._email);
        prefs.setString('mobileno',this._mobileno);
      });
    });
  }

  @override
  void initState() {
    getCardNo();
    _checkEmailEnforced();
    _mPresenter.onAttach(this);
    super.initState();
  }

  void _initVerificationRequest() {
    //sendcodethru 1 = email, 2 = sms

    setState(() {
      startTimer();
      _isRequesting = true;
      _request = VerificationRequest(cardNo: this._cardNo, sendcodethru: _sendcodethru);
      print('send code V: ${_request.sendcodethru}');
      print('send cardNo: ${_request.cardNo}');
      _mPresenter.sendVerificationRequest(_request);
    });
  }

  void _initResendVerificationRequest() {
    //sendcodethru 1 = email, 2 = sms

    setState(() {
      startTimer();
      _isRequesting = true;
      _request = VerificationRequest(cardNo: this._cardNo, sendcodethru: _sendcodethru);
      print('resend code V: ${_request.sendcodethru}');
      _mPresenter.resendVerificationRequest(_request);
    });
  }

  void _initAccountVerification() {
    if(_code != '') {
      _showLoadingDialog();
      setState(() {
        _isRequesting = true;
        _request = VerificationRequest(cardNo: this._cardNo, sendcodethru: _sendcodethru, code: _code);
        _mPresenter.sendAccountVerification(_request);
      });
    }
  }

  void startTimer() {
    _isBtnResendEnable = false;
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

  void _closeAlert() {
    Navigator.pop(context);//it will close last route in your navigator
  }

  void _showAlertDialog(bool isSuccess, String text) {

     Container successPage = Container(
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      height: _height / 6,
                      decoration: myAppLogo(),
                    ),
                    Container(
                      height: _height / 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text("You're all set.", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 35.0)),
                          Text("Your account has been created successfully!", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0), textAlign: TextAlign.center,)
                        ],
                      ),
                    ),
                    RaisedButton(
                      child: Text("Next", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18.0)),
                      padding: EdgeInsets.fromLTRB(40, 12, 40, 12),
                      color: mPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      onPressed: (){
                        Navigator.push(context,
                        MaterialPageRoute(
                          builder: (context) => SetQuickViewPage()),
                        );
                      },
                    ),
                    SizedBox(
                      height: _height / 9,
                    )
                  ],
                ),
              ),
            )
          ]
        )
      );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text(isSuccess ? "You're all set." : "Warning"),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(isSuccess ? "Your account has been created successfully." : text == '' ? "Verification Failed" : text),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK"),
          onPressed: () {
            setState(() {
              if(isSuccess) {
                //_sendEmail();
                // Navigator.of(context)
                //     .pushNamedAndRemoveUntil(
                //     LoginPage.tag, (Route<dynamic> route) => false
                // );
              }else {
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
        if(isSuccess){
          return successPage;
        }
        else{
          return alert;
        }
      },
    );
  }

  @override
  void onSuccess(SignUpResponse response, String sender) {

    if(response?.msgDescription == 'Verification code sent') {
      Future.delayed(const Duration(seconds: 60), () {
        setState(() {
          _isBtnResendEnable = true;
          print('isBtnResendEnable Success: $_isBtnResendEnable');
        });
      });
    }

    if(sender == 'request-v'){
      print('S request-v');
    }else if(sender == 'account-v'){
      print('S account-v');
      _showAlertDialog(true, '');
      _timer.cancel();
    }

    setState(() {
      _isRequesting = false;
    });
  }

  @override
  void onError(String message, String sender) {
    if(sender == 'request-v'){
      print('request-v: Error');
      setState(() {
        _isBtnResendEnable = true;
        print('isBtnResendEnable Success: $_isBtnResendEnable');
      });
    }else if(sender == 'account-v'){
      print('account-v: Error');
      _closeAlert();
      _showAlertDialog(false, message);
    }

    setState(() {
      _isRequesting = false;
    });
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
                automaticallyImplyLeading: false,
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
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: _height * .5,
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
                                          Visibility(
                                            visible: _mobileNoVis,
                                            child: OutlineButton(
                                              padding: EdgeInsets.all(16),
                                              color: mPrimaryColor,
                                              borderSide: BorderSide(color: mPrimaryColor),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                              child: Text('Send verification code to your Mobile Number: ${Common.formatMobileNo(this._mobileno)}  ', style: TextStyle(color: Colors.black87, fontSize: 16.0)),
                                              onPressed: () {
                                                setState(() {
                                                  _sendcodethru = '2';
                                                  _btnVis = false;
                                                  _codeVis = true;
                                                });
                                                //startTimer();
                                                _initVerificationRequest();
                                              },
                                            ),
                                          ),
                                          SizedBox(height: 16.0,),
                                          OutlineButton(
                                            padding: EdgeInsets.all(16),
                                            color: mPrimaryColor,
                                            borderSide: BorderSide(color: mPrimaryColor),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                            child: Text('Send verification code to your Email address: ${Common.formatEmail(this._email)} ', style: TextStyle(color: Colors.black87, fontSize: 16.0)),
                                            onPressed: () {
                                              //Init email verification.
                                              setState(() {
                                                _sendcodethru = '1';
                                                _btnVis = false;
                                                _codeVis = true;
                                              });
                                              //startTimer();
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
                                            Text('Please enter the verification code sent to your registered mobile no./email.', style: TextStyle(fontSize: 15.0), textAlign: TextAlign.center,),
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
                                    child: _isBtnResendEnable == true ? Text('0', style: TextStyle(color: Colors.grey,fontSize: 17),) : Text('$_start',style: TextStyle(fontSize: 17)),
                                  )
                                )
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
                ),
              )
          ),
        ],
      ),
    );
  }

  Future _checkEmailEnforced() async {
    String _emailPolicyEnforced;
    String _cardno;
    String _pnumber;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _cardno = (prefs.getString('_Cardno') ?? '');
    _pnumber = _cardno.substring(3,8);

    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetEmailPolicy';

    List<Member> data = [];
    try {
      var res = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email
        },
        body: {
          "userid" : _api_user,
          "password" : _api_pass,
          "pnumber" : _pnumber,
          "fbclid" : "IwAR2cmT2E11tStZc4Z86fS3prXUMVnzsd-QcS8t4YlkhubFC1i0AapvgKh3o"
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);

      json.forEach((entity) {
        data.add(Member.fromJson(entity));
        _emailPolicyEnforced = entity['emailPolicyEnforced'].toString();
      });

      setState(() {
        if(_emailPolicyEnforced != '0'){
            _mobileNoVis = false;
        } else if(_emailPolicyEnforced != '1'){
            _mobileNoVis = true;
        }
      });

      return data[0];
    }catch (e) {
      print(e);
      print('Server Error Occurred.');
      return Member(message: 'Connection Error Occured');
    }
  }
}
