import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:av_asian_life/utility/my_preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InquiriesPage extends StatefulWidget {
  static String tag = 'inquiry-page';

  final IApplicationSession appSessionCallback;

  InquiriesPage({this.appSessionCallback});

  @override
  _InquiriesPageState createState() => _InquiriesPageState();
}

class _InquiriesPageState extends State<InquiriesPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _subjectCtrl = TextEditingController();
  TextEditingController _inquiryCtrl = TextEditingController();
  double _height, _width;
  String _inquiry;
  String _subject = 'Choose your inquiry category';
  String _categoryDescription;
  String _categoryID;

  bool _isInteractionDisabled = false;
  bool _autoValidate = false;
  bool categoryErr = false;
  AlertDialog _loadingDialog;

  IApplicationSession _appSessionCallback;

  User _mUser;

  String newval;


  List category = [];
  dynamic data;

  Future<String> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    var response = await http.post(
      Uri.encodeFull('${_base_url}GetInquiryCategory'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
      }
    );
    List categoryDescription;
    data = json.decode(response.body);
    _categoryDescription = data;
    setState(() {
      categoryDescription = json.decode(_categoryDescription);
    });
    for(var i = 0; i < categoryDescription.length; i++){
      this.category.add(categoryDescription[i]["categoryDescription"]);
    }
    return "Success!";
  }

  @override
  void initState() {
    super.initState();
    this.getData();
    _appSessionCallback = widget.appSessionCallback;
    _getUserData();
  }

  void _getUserData() async {
    MyPreferenceHandler myPreferenceHandler = MyPreferenceHandler();
    _mUser = await myPreferenceHandler.getUserData();
  }


  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    final Widget button = SizedBox(
     width: _width,
     height: 40,
     child: Padding(
       padding: const EdgeInsets.only(left: 16, right: 11),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: <Widget>[
           Container(
             child: Text(
               _subject,
               style: TextStyle(color: _subject == 'Choose your inquiry category' ? Colors.black45 : Colors.black),
               overflow: TextOverflow.ellipsis,
             ),
           ),
           SizedBox(
             width: 12,
             height: 17,
             child: FittedBox(
               fit: BoxFit.fill,
               child: Icon(
                 Icons.arrow_drop_down,
                 color: Colors.grey,
               )
             )
           ),
         ],
       ),
     ),
   );

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Inquiries'),
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          flexibleSpace: Image(
            image: AssetImage('assets/images/appBar_background.png'),
            fit: BoxFit.fill,
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            //height: _height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Align(
                    child: Container(
                        child: Column(
                  children: <Widget>[
                    SizedBox(height: 30,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(children: <Widget>[
                            SizedBox(
                              width: 25.0,
                            ),
                            Text(
                              'How can we make you',
                              style: TextStyle(
                                fontSize: _height <= 600 ? 14 : 20.0,
                              ),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Image.asset(
                              'assets/images/smile_text.png',
                              height: _height <= 600 ? 20 : 30.0,
                            ),
                          ])
                        ]),
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'today?',
                      style: TextStyle(
                        fontSize: _height <= 600 ? 14 : 20.0,
                      ),
                    ),
                  ],
                ))),
                Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Container(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: _height <= 600 ? 12 : 17,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
//                               DropdownButtonFormField(
//                                 hint: Text(
//                                   ' Choose your inquiry category',
//                                   style: TextStyle(
//                                     fontSize: _height <= 600 ? 11 : 14,
//                                   ),
//                                 ),
//                                 value: _subject,
//                                 decoration: InputDecoration(
//                                   alignLabelWithHint: true,
//                                   border: OutlineInputBorder(
//                                     borderSide:  BorderSide(color: Colors.black87)
//                                   )
//                                 ),
//                                 icon: Icon(Icons.arrow_drop_down),
//                                 items: category.map((value) {
//                                   return DropdownMenuItem(
//                                       value: value,
//                                       child: Text(value, style: TextStyle(fontSize: _height <= 600 ? 11 : 14,)));
// }
//                                 ).toList(),
//                                 onTap: () {
//                                   _appSessionCallback.pauseAppSession();
//                                 },
//                                 onChanged: (value) {
//                                   setState(() {
//                                     category.remove(value);
//                                     category.insert(0, value);
//                                     _subject = value;
//                                   });
//                                 },
//                                 // onSaved: (value) {
//                                 //   setState(() {
//                                 //     _subject = value;
//                                 //   });
//                                 // },
//                               ),
                             MenuButton(
                               child: button,
                               items: category,
                               topDivider: true,
                               crossTheEdge: true,
                               dontShowTheSameItemSelected: false,
                               // Use edge margin when you want the menu button don't touch in the edges
                               edgeMargin: 12,
                               itemBuilder: (value) => Container(
                                 height: 40,
                                 alignment: Alignment.centerLeft,
                                 padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
                                 child: Text(
                                   value,
                                   overflow: TextOverflow.ellipsis,
                                 ),
                               ),
                               toggledChild: Container(
                                 color: Colors.white,
                                 child: button,
                               ),
                               divider: Container(
                                 height: 1,
                                 color: Colors.white,
                               ),
                               onItemSelected: (value) {
                                 setState(() {
                                   categoryErr = false;
                                   _subject = value;
                                 });
                               },
                               decoration: BoxDecoration(
                                   border: Border.all(color: categoryErr == true ? Colors.red : Colors.black54),
                                   borderRadius: const BorderRadius.all(
                                     Radius.circular(3.0),
                                   ),
                                   color: Colors.white),
                               onMenuButtonToggle: (isToggle) {
                                 print(isToggle);
                               },
                             ),
                            ],
                          ),
                        ),
                        categoryErr == true ? SizedBox(
                          height: 15, 
                          child: Text('No inquiry category selected', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ) :
                        Offstage(),
                        SizedBox(height: 10,),
                        _getMessageTextBox(),
                        SizedBox(height: 30),
                        RaisedButton(
                          padding: EdgeInsets.all(12),
                          color: mPrimaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Container(
                              width: _width * .3,
                              alignment: Alignment.center,
                              child: Text('Send',
                          style: TextStyle(color: Colors.black))),
                          onPressed: _isInteractionDisabled ? null : _validateInputs,
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
                          height: _height >= 600 ? _height - _height * .85 : 20
                        ),
                        myMultimediaAccounts(),
                        SizedBox(
                          height: 10.0,
                        ),
                        copyRightText()
                      ],
                    )),
              ],
            ),
          ),
        ));
  }

  Widget _getMessageTextBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          alignment: Alignment.topLeft,
          child: Text('Message',
              style: TextStyle(fontSize: _height <= 600 ? 12 : 17)),
        ),
        SizedBox(
          height: 10.0,
        ),
        TextFormField(
          controller: _inquiryCtrl,
          keyboardType: TextInputType.multiline,
          maxLines: _height <= 600 ? 9 : 12,
          validator: Common.validateInputLength,
          enabled: !_isInteractionDisabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87)),
            hintText: 'Your Inquiry...',
          ),
          onTap: () {
            _appSessionCallback.pauseAppSession();
          },
          onSaved: (String val) {
            _inquiry = val;
          },
        ),
      ],
    );
  }

  void _closeAlert() {
    Navigator.pop(context); //it will close last route in your navigator
  }

  void _showLoadingDialog() {
    // set up the AlertDialog
    _loadingDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
    _appSessionCallback.pauseAppSession();
  }

  void _showAlertDialog(String title, String body) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
            _appSessionCallback.pauseAppSession();
            setState(() {
              _isInteractionDisabled = false;
              Navigator.of(this.context).pop('dialog');
              //Redirect UI to another page i.e. HomePage
              _subjectCtrl.clear();
              _inquiryCtrl.clear();
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

  void _validateInputs() {
    _appSessionCallback.pauseAppSession();
    setState(() {
      if (_formKey.currentState.validate()) {
        if(_subject == 'Hospitals/Clinics/Doctors Inquiry'){
          this._categoryID = '1';
        } else if(_subject == 'Reimbursement'){
          this._categoryID = '2';
        } else if(_subject == 'Letter of Guarantee'){
          this._categoryID = '3';
        } else if(_subject == 'How to use the mobile app'){
          this._categoryID = '4';
        } else if(_subject == 'Member details'){
          this._categoryID = '5';
        } else if(_subject == 'Others'){
          this._categoryID = '6';
        }
        if(_subject == 'Choose your inquiry category'){
           setState(() {
             print('No Inquiry category');
             categoryErr = true;
           });
        }else{
        _showLoadingDialog();
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _formKey.currentState.save();

        print(_subject + ' ' + _inquiry);
        //_showAlertDialog(_subject, _inquiry);
        _postInquiry();
        }
      } else {
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }
    });
  }

  void _postInquiry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cardNo;
    cardNo = (prefs.getString('_Cardno') ?? '');
    print('cardNo: $cardNo');
    print('_postInquiry');

    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}PostCategorizedInquiry';
    List<LogResponse> data = [];
    print(url);
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
          "cardno" : cardNo,
          "category" : this._categoryID,
          "remarks" : _inquiry
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      json.forEach((entity) {
        data.add(LogResponse.fromJson(entity));
      });

      _closeAlert();
      _showAlertDialog('Message', data[0].msgDescription);
    } catch (e) {
      print('HTTP Exception.');
      print(e);
      _closeAlert();
      _showAlertDialog('Warning', 'Connection Error Occurred.');
    }
  }
}
