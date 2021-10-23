import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/signup_request.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_privacy_page/view/data_privacy_page.dart';
import 'package:av_asian_life/registration/signup/presenter/signup_presenter.dart';
import 'package:av_asian_life/registration/signup/signup_contract.dart';
import 'package:av_asian_life/registration/signup/view/data_privacy_page.dart';
import 'package:av_asian_life/registration/signup/view/terms_and_conditions_of_use.dart';
import 'package:av_asian_life/registration/verification/view/verify_signup_page.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignUpPage extends StatefulWidget {
  static String tag = 'signup-page';

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> implements ISignUpView {
  final ISignUpPresenter _mPresenter = SignUpPresenter();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _checkBoxValue1 = false;
  bool isGranted = false;
  bool _isHidden  = true;
  bool cardNoCancelVis = false, emailCancelVis = false, mobileCancelVis = false, userCancelVis = false, passwordIconVis = false, repasswordIconVis = false;
  SignUpRequest _request;
  String _cardNo;
  String _username;
  String _password;
  String _birthday;
  String _lastName;
  String _firstName;
  String _middleName;
  String _mobileNo;
  String _email;
  int _newsletter = 0;
  String _deviceId;

  AlertDialog _loadingDialog;

  var dobTextController = new TextEditingController();
  var _cardNoController = new TextEditingController();
  var _mobilenoController = new TextEditingController();
  var _emailController = new TextEditingController();
  var _usernameController = new TextEditingController();
  var _passwordController  = new TextEditingController();
  String selectedDateText = '';
  DateTime _date;

  bool _isInteractionDisabled = false;
  bool _isFullyFilled = true;

  @override
  void initState() {
    super.initState();
    _mPresenter.onAttach(this);
  }

  @override
  void onSuccess(SignUpResponse response) {
    _closeAlert();

    print('onSuccess: ${response.cardno}');
    Navigator.push(context,
      MaterialPageRoute(
          builder: (context) => VerifySignUpPage(cardNo: response.cardno, request: _request, isForVerification: false,)),
    );
  }

  @override
  void onError(String message) {
    setState(() {
      _isInteractionDisabled = false;
    });
    _closeAlert();
    _showAlertDialog(false, message);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: myAppBackground(),
      child: Stack(
        children: <Widget>[
          Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
              ),
              backgroundColor: Colors.transparent,
              body: LayoutBuilder(
                  builder: (context, constraint){
                    final height = constraint.maxHeight;
                    final width = constraint.maxWidth;
                    return SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: width * .25,
                              decoration: myAppLogo(),
                            ),
                            SizedBox(height: 15.0,),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Hello There,', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 30.0),),
                                    SizedBox(height: 10.0,),
                                    Text('Please register below to access your account.', style: TextStyle(fontSize: 15.0),),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10.0,),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: _getTextFields(height, width, context),
                            )
                          ],
                        ),
                      ),
                    );
                  })
          )
        ],
      ),
    );
  }

  var passKey = GlobalKey<FormFieldState>();
  var mobileKey = GlobalKey<FormFieldState>();
  var emailKey = GlobalKey<FormFieldState>();
  Widget _getTextFields(double height, double width, BuildContext context){


    return Form(
      key: _formKey,
      autovalidate: _autoValidate,
      child: Container(
        width: width,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                child: Focus(
                  child: TextFormField(
                    controller: _cardNoController,
                    keyboardType: TextInputType.number,
                    enabled: !_isInteractionDisabled,
                    inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "10112345123456000",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Card No.",
                      suffix: Visibility(
                        visible: cardNoCancelVis,
                        child: InkWell(
                          onTap: () =>_cardNoController.clear(),
                          child: Icon(
                            Icons.cancel,
                          ),
                        ),
                      ),
                    ),
                    validator: (val){
                      if(val.length != 17)
                        return "Invalid card number";
                    },
                    onSaved: (String val) {
                      _cardNo = val;
                    },
                  ),
                  onFocusChange: (hasFocus){
                    if(hasFocus){
                      setState((){
                        cardNoCancelVis = true;
                      });
                    } else {
                      setState((){
                        cardNoCancelVis = false;
                      });
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                child: TextFormField(
                  keyboardType: TextInputType.text,
                  enabled: !_isInteractionDisabled,
                  controller: dobTextController,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[]'))],
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: "Birthdate",
                    hintStyle: TextStyle(color: Colors.grey),
                    labelText: "Birthdate",),
                  validator: _mPresenter.validateInputLength,
                  onSaved: (String val) {
                    var month = '${_date.month}'.length == 1 ? '0${_date.month}' : '${_date.month}';
                    var day = '${_date.day}'.length == 1 ? '0${_date.day}' : '${_date.day}';
                    _birthday = '${_date.year}$month$day';
                  },
                  onTap: (){
                    _datePicker();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                child: Focus(
                  child: TextFormField(
                    controller: _emailController,
                    key: emailKey,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isInteractionDisabled,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@#$%&*!-_.]'))],
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Email",
                      suffix: Visibility(
                        visible: emailCancelVis,
                        child: InkWell(
                          onTap: () =>_emailController.clear(),
                          child: Icon(
                            Icons.cancel,
                          ),
                        ),
                      ),
                    ),
                    validator: _mPresenter.validateEmail,
                    onSaved: (String val) {
                      _email = val;
                    },
                  ),
                  onFocusChange: (hasFocus){
                    if(hasFocus){
                      setState((){
                        emailCancelVis = true;
                      });
                    } else {
                      setState((){
                        emailCancelVis = false;
                      });
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                child: Focus(
                  child: TextFormField(
                    controller: _mobilenoController,
                    key: mobileKey,
                    keyboardType: TextInputType.number,
                    enabled: !_isInteractionDisabled,
                    inputFormatters: [new WhitelistingTextInputFormatter(RegExp("[0-9]")),],
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Please key-in your 11 digit mobile number",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Mobile Number",
                      suffix: Visibility(
                        visible: mobileCancelVis,
                        child: InkWell(
                          onTap: () =>_mobilenoController.clear(),
                          child: Icon(
                            Icons.cancel,
                          ),
                        ),
                      ),
                    ),
                    validator: _mPresenter.phoneNumberValidator,
                    onSaved: (String val) {
                      _mobileNo = val;
                    },
                  ),
                  onFocusChange: (hasFocus){
                    if(hasFocus){
                      setState((){
                        mobileCancelVis = true;
                      });
                    } else {
                      setState((){
                        mobileCancelVis = false;
                      });
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                child: Focus(
                  child: TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !_isInteractionDisabled,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Username",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Username",
                      suffix: Visibility(
                        visible: userCancelVis,
                        child: InkWell(
                          onTap: () =>_usernameController.clear(),
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                child: Focus(
                  child: TextFormField(
                    key: passKey,
                    keyboardType: TextInputType.text,
                    obscureText: _isHidden,
                    enabled: !_isInteractionDisabled,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Password",
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
                ),
              ),
            ),
            SizedBox(
              child: Text('*NOTE: Password must contain at least 1 uppercase, 1 number and have at least 8 characters.',
                style: TextStyle(fontSize: 10.0, fontStyle: FontStyle.italic),
                maxLines: 2,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: SizedBox(
                child: Focus(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: _passwordController,
                    obscureText: _isHidden,
                    enabled: !_isInteractionDisabled,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.grey),
                      labelText: "Re-Type Password",
                      suffix: Visibility(
                        visible: repasswordIconVis,
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
                    validator: (confirmation) {
                      if (confirmation != passKey.currentState.value)
                        return 'Passwords does not match';
                      else return null;
                    },
                    onSaved: (String val) {
                      _password = val;
                    },
                  ),
                  onFocusChange: (hasFocus){
                    if(hasFocus){
                      setState((){
                        repasswordIconVis = true;
                      });
                    } else {
                      setState((){
                        repasswordIconVis = false;
                      });
                    }
                  },
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 5.0),
            //   child: SizedBox(
            //     child: TextFormField(
            //       keyboardType: TextInputType.text,
            //       enabled: !_isInteractionDisabled,
            //       decoration: InputDecoration(
            //         border: UnderlineInputBorder(),
            //         hintText: "First Name",
            //         labelText: "First Name",
            //       ),
            //       validator: _mPresenter.validateInputLength,
            //       onSaved: (String val) {
            //         _firstName = val.toUpperCase();
            //       },
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 5.0),
            //   child: SizedBox(
            //     child: TextFormField(
            //       keyboardType: TextInputType.text,
            //       enabled: !_isInteractionDisabled,
            //       decoration: InputDecoration(
            //         border: UnderlineInputBorder(),
            //         hintText: "Last Name",
            //         labelText: "Last Name",
            //       ),
            //       validator: _mPresenter.validateInputLength,
            //       onSaved: (String val) {
            //         _lastName = val.toUpperCase();
            //       },
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 5.0),
            //   child: SizedBox(
            //     child: TextFormField(
            //       keyboardType: TextInputType.text,
            //       enabled: !_isInteractionDisabled,
            //       decoration: InputDecoration(
            //         border: UnderlineInputBorder(),
            //         hintText: "Middle Name",
            //         labelText: "Middle Name",
            //       ),
            //       //validator: _mPresenter.validateInputLength,
            //       onSaved: (String val) {
            //         if(val != null)
            //           _middleName = val.toUpperCase();
            //         else _middleName = '';
            //       },
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 5.0),
            //   child: SizedBox(
            //     child: TextFormField(
            //       keyboardType: TextInputType.number,
            //       enabled: !_isInteractionDisabled,
            //       decoration: InputDecoration(
            //         border: UnderlineInputBorder(),
            //         hintText: "Mobile Number",
            //         labelText: "Re-Type Mobile Number",
            //       ),
            //       validator: (confirmation) {
            //         if (confirmation != mobileKey.currentState.value)
            //           return 'Mobile Numbers does not match';
            //         else return null;
            //       },
            //       onSaved: (String val) {
            //         _mobileNo = val;
            //       },
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 5.0),
            //   child: SizedBox(
            //     child: TextFormField(
            //       keyboardType: TextInputType.emailAddress,
            //       enabled: !_isInteractionDisabled,
            //       decoration: InputDecoration(
            //         border: UnderlineInputBorder(),
            //         hintText: "Email",
            //         labelText: "Re-Type Email",
            //       ),
            //       validator: (confirmation) {
            //         if (confirmation != emailKey.currentState.value)
            //           return 'Emails does not match';
            //         else return null;
            //       },
            //       onSaved: (String val) {
            //         _email = val;
            //       },
            //     ),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 5.0),
            //   child: SizedBox(
            //     child: TextFormField(
            //       keyboardType: TextInputType.emailAddress,
            //       enabled: !_isInteractionDisabled,
            //       decoration: InputDecoration(
            //         border: UnderlineInputBorder(),
            //         hintText: "Company Name",
            //         labelText: "Company Name",
            //       ),
            //       validator: _mPresenter.validateInputLength,
            //       onSaved: (String val) {

            //       },
            //     ),
            //   ),
            // ),
            // Container(
            //   padding: const EdgeInsets.only(top: 25.0,),
            //   alignment: Alignment.topLeft,
            //   child: Text('Data Privacy Consent', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
            // ),
            // Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 15.0),
            //     child: Row(
            //       mainAxisSize: MainAxisSize.max,
            //       children: <Widget>[
            //         Expanded(
            //           child: RaisedButton(
            //             padding: EdgeInsets.all(12),
            //             color: Colors.white,
            //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0), side: BorderSide(color: mPrimaryColor)),
            //             child: Text('Read Data Privacy Consent', style: TextStyle(color: Colors.black87)),
            //             //onPressed: _isInteractionDisabled ? null : _validateInputs,
            //             onPressed: () {
            //               _openDataPrivacyPage(context);
            //             },
            //           ),
            //         ),
            //       ],
            //     )
            // ),
            Row(
                children: <Widget>[
                  Checkbox(
                      value: _checkBoxValue1,
                      activeColor: mPrimaryColor,
                      onChanged: (bool newValue){
                        setState(() {
                          _checkBoxValue1 = newValue;
                          if(_checkBoxValue1 == true){
                            _newsletter = 1;
                          }
                        });
                      }
                  ),
                  Text('I agree to receive newsletter', style: TextStyle(fontSize: 15.0),),
                ]
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0),
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Expanded(
                          child: RaisedButton(
                            padding: EdgeInsets.all(12),
                            color: mPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            child: Text('Create Account', style: TextStyle(color: Colors.black87)),
                            //onPressed: _isInteractionDisabled ? null : _validateInputs,
                            onPressed: !_isFullyFilled ? null : _validateInputs,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:<Widget>[
                          Text('By clicking \"Create Account\" you agree to our ',
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                            maxLines: 2,
                          ),
                        ]
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          InkWell(
                            child: Text('Data Privacy Policy ',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.blue
                                )
                            ),
                            onTap: (){
                              _openDataPrivacyPage(context);
                            },
                          ),
                          Text('and ',
                            style: TextStyle(
                              fontSize: 13.0,
                            ),
                            maxLines: 2,
                          ),
                          InkWell(
                            child: Text('Terms and Conditions of Use.',
                                style: TextStyle(
                                    fontSize: 13.0,
                                    color: Colors.blue
                                )
                            ),
                            onTap: (){
                              _openTermsAndConditionsPage(context);
                            },
                          ),
                        ]
                    )
                  ]
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: copyRightText()
                )
            ),
          ],
        ),
      ),
    );
  }

  _openTermsAndConditionsPage(BuildContext context) async {
    final result = await Navigator.of(context).push(
        PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            pageBuilder: (BuildContext context, _, __) {
              return TermsAndConditionsPage();
            }
        )
    );

    print(result);
    setState(() {
      if(result == 'granted')
        _isFullyFilled = true;
      else
        //_isFullyFilled = false;
        _isFullyFilled = true;
    });
  }

  _openDataPrivacyPage(BuildContext context) async {
    final result = await Navigator.of(context).push(
        PageRouteBuilder(
            opaque: false,
            barrierDismissible: true,
            pageBuilder: (BuildContext context, _, __) {
              return PrivacyPage();
            }
        )
    );

    print(result);
    setState(() {
      if(result == 'granted')
        _isFullyFilled = true;
      else
        //_isFullyFilled = false;
        _isFullyFilled = true;
    });
  }


  void _datePicker() {
    DatePicker
        .showDatePicker(
        context,
        showTitleActions: true,
        minTime: DateTime(1800, 1, 1),
        maxTime: DateTime.now(),
        onChanged: (date) { print('change ${date.month}'); },
        onConfirm: (date) {
          print('confirm ${date.month} ${date.day} ${date.year}');
          setState(() {
            selectedDateText = '${date.month}/${date.day}/${date.year}';
            _date = date;
            dobTextController.text = selectedDateText;
          });
        },
        currentTime: DateTime.now(), locale: LocaleType.en);
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
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text(isSuccess ? "Success" : "Warning"),
      content: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text(isSuccess ? "Login Verified" : text == '' ? "Login Falied" : text),
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



  void _validateInputs() async {
    _deviceId = await ImeiPlugin.getImei();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      if (_formKey.currentState.validate()) {
        _showLoadingDialog();
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _formKey.currentState.save();
        if(_isFullyFilled) {
          prefs.setString('_username',_usernameController.text);
          prefs.setString('_password',_passwordController.text);
          prefs.setString('_Cardno',_cardNoController.text);
          prefs.setString('cardno',_cardNoController.text);
          prefs.setString('mobileno',_mobilenoController.text);
          prefs.setString('_email',_emailController.text);
          _request = SignUpRequest(
            cardNo: _cardNo,
            username: _username,
            userPassword: _password,
            birthday: _birthday,
            lastName: _lastName,
            firstName: _firstName,
            middleName: _middleName,
            mobileNo: _mobileNo,
            email: _email,
            newsletter: _newsletter,
            deviceId: _deviceId != null ? _deviceId : 'SMILE_APP',
          );
          setRegisterDetails(_request.username, _request.userPassword, _request.cardNo);
          _mPresenter.sendSignUpRequest(_request);
        }
      } else {
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }
    });
  }

  void setRegisterDetails(String username, String password, String cardno) async {
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    await myPreferenceHandler.setRegDetails(username, password, cardno);
  }

  void _togglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

}
