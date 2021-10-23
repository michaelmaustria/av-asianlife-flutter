import 'dart:convert';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/common.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final Member member;

  final IApplicationSession appSessionCallback;

  StarRating({this.starCount = 5, this.rating = .0, this.onRatingChanged, this.color, this.member, this.appSessionCallback});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Theme.of(context).buttonColor,
        size: 50,
      );
    }
    else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: 50
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: 50
      );
    }
    return new GestureDetector(
      onTap: onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: new List.generate(starCount, (index) => buildStar(context, index))
      );
  }
}

class Test extends StatefulWidget {

  final Member member;
  final IApplicationSession appSessionCallback;
  final String requestId;

  Test({this.member, this.appSessionCallback, this.requestId});

  @override
  _TestState createState() => new _TestState();
}

class _TestState extends State<Test> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _rating = 3;
  IApplicationSession _appSessionCallback;
  bool _isInteractionDisabled = false;
  bool _autoValidate = false;
  double _height, _width;
  AlertDialog _loadingDialog;
  
  TextEditingController _inquiryCtrl = TextEditingController();
  String _inquiry;

  @override
  void initState() {
    super.initState();
    print('init state');
    _appSessionCallback = widget.appSessionCallback;

    print(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Rate'),
        flexibleSpace: Image(
          image: AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,
        ),
      ),
      body: LayoutBuilder(builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        final heightBody = height * .8;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 10,),
                    Text('Rate your Letter of Guarantee request experience.',style: TextStyle(fontSize:18), textAlign: TextAlign.left),
                    SizedBox(height: 25,),
                    Container(
                    child: Text('Tap a star to rate our service.',style: TextStyle(fontSize:18)),
                    ),
                    SizedBox(height: 20,),
                    Container(
                      color: Colors.white,
                      //padding: EdgeInsets.only(left: width/7.1),
                      child: new StarRating(
                        rating: _rating,
                        onRatingChanged: (_rating) => setState(() => this._rating = _rating),
                      )
                    ),
                    SizedBox(height: 20,),
                    Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: _getMessageTextBox(),
                    ),
                    SizedBox(height: 30,),
                    RaisedButton(
                      padding: EdgeInsets.all(12),
                      color: mPrimaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      child: Container(
                        width: _width * .5,
                        alignment: Alignment.center,
                          child: Text('Submit',style: TextStyle(color: Colors.black))),
                          onPressed: _isInteractionDisabled ? null : _validateInputs,
                    ),
                  ]
                ),
              ),
              SizedBox(height: heightBody /11 ,),
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
              )
            ],
          )
        );
      }),
    );
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

  Widget _getMessageTextBox() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TextFormField(
          controller: _inquiryCtrl,
          keyboardType: TextInputType.multiline,
          maxLines: 12,
          validator: Common.validateInputLength,
          enabled: !_isInteractionDisabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black87)),
            hintText: 'Tell us what you think....',
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

  void _showAlertDialog(String body) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text('your rating is: $_rating'),
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
        //_showLoadingDialog();
        _isInteractionDisabled = true;
        //If all data are correct then init onSave function in each TextFormField
        _formKey.currentState.save();

        print(_inquiry);
        print(_rating);
       _showAlertDialog(_inquiry);
        // _postInquiry();
      } else {
        //If all data are not valid then start auto validation.
        setState(() {
          _autoValidate = true;
        });
      }
    });
  }
}
