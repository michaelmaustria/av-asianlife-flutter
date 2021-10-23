import 'dart:async';
import 'dart:convert';

import 'package:av_asian_life/claims/claims_contract.dart';
import 'package:av_asian_life/claims/model/claims_model.dart';
import 'package:av_asian_life/claims/presenter/claims_presenter.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/claims_request.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/login/view/quick_view.dart';
import 'package:av_asian_life/registration/verification/presenter/verification_presenter.dart';
import 'package:av_asian_life/registration/verification/verification_contract.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'change_password_page.dart';

class VerifyChangePasswordPage extends StatefulWidget {

  ClaimRequest request;

  final bool isForVerification;
  final Member member;

  VerifyChangePasswordPage({this.request, this.isForVerification, this.member});
  @override
  _VerifyChangePasswordPageState createState() => _VerifyChangePasswordPageState();
}

class _VerifyChangePasswordPageState extends State<VerifyChangePasswordPage> implements IVerificationView {
  final IVerificationPresenter _mPresenter = VerificationPresenter();
  IClaimsPresenter _claimsPresenter = ClaimsPresenter();
  TextEditingController controller = TextEditingController();
  VerificationRequest _request;

  double _height, _width;
  String _cardNo, _code = '', _sendcodethru = '' , _mobileno = '', _email = '';

  bool _codeVis = false, _btnVis = true, _isBtnResendEnable = false;
  bool _isRequesting = false, _mobileNoVis = false;

  AlertDialog _loadingDialog;

  Timer _timer;
  int _start = 60;

  List msgDesc = [];
  String _msgDesc;

  Member _mMember;

  getCardNo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // this._cardNo = (prefs.getString('_Cardno') ?? '');
      // this._mobileno = (prefs.getString('mobileno') ?? '');
      // this._email = (prefs.getString('email') ?? '');
      this._cardNo = (widget?.member.cardno ?? '');
      this._mobileno = (widget?.member.mobileno ?? '');
      this._email = (widget?.member.email ?? '');
      print('cardNo: ${this._cardNo}');
      print( 'mobile no: ${this._mobileno}');
      print('email: ${this._email}');
    });
  }

  Future<Member> _navigateToHomePage(String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var baseUrl = await ApiHelper.getBaseUrl();
    var apiUser = await ApiHelper.getApiUser();
    var apiPass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();

    String url = '${baseUrl}MemberInfo';
    var res = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email,
        "DeviceID": _deviceId
      },
      body : {
        "userid" : apiUser,
        "password" : apiPass,
        "cardno" : cardNo,
        "frommain" : "0"
      }
    );
    var json = jsonDecode(jsonDecode(res.body));

    List<Member> data = [];
    json.forEach((entity) {
      data.add(Member.fromJson(entity));
    });

    if (data[0].cardno != null) {
      _mMember = data[0];
      print(_mMember);
      Navigator.of(context)
          .pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => HomePage(member: _mMember)
          ),
              (Route<dynamic> route) => false
      );
      return data[0];
    } else {
      print('Error Fetching Member Info: $json');
      return null;
    }
  }

  @override
  void initState() {
    _checkEmailEnforced();
    getCardNo();
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

  void _initAccountVerification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(_code != '') {
      prefs.setString('otp',_code);
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

  @override
  Future<void> onSuccess(SignUpResponse response, String sender) async {

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
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ChangePasswordPage(member: widget?.member))
      );
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
      _validateOTP();
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
                                                _initResendVerificationRequest();
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
                                              _initResendVerificationRequest();
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
          content: new Text(message,textAlign: TextAlign.center),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                _navigateToHomePage(this._cardNo);
                _timer.cancel();
              },
            )
          ],
        ));
  }

  void _validateOTP(){
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
          content: new Text('You have entered an invalid verification code.',textAlign: TextAlign.center),
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

