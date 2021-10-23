import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/utility/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PolicyDetailsPage extends StatefulWidget {
  static String tag = 'policy-details';
  final Member member;
  final IApplicationSession appSessionCallback;

  PolicyDetailsPage({this.member, this.appSessionCallback});

  @override
  _PolicyDetailsPageState createState() => _PolicyDetailsPageState();
}

class _PolicyDetailsPageState extends State<PolicyDetailsPage> {
  Future<List<Dependent>> _mDependent;
  final formatter = new NumberFormat("#,###.0");

  Matrix4 matrix = Matrix4.identity();
  Matrix4 zerada =  Matrix4.identity();

  String _formatCardNo(String str) => str.substring(0, 3) + " " + str.substring(3, 8) + " " + str.substring(8, 14,) + " " + str.substring(14, str.length);

  IApplicationSession _appSessionCallback;

  AlertDialog _loadingDialog;

  String cardNo;
  String rightCardNo;

  bool _isMember = false;
  bool _hasMatBenefits = false;
  bool _hasOPBenefits = false;
  bool _hasIPBenefits = false;
  bool _hasData = true;

  //lists of data for out-patient schedule of benefits
  List benefit = [];
  List benefits = [];
  List uniqueBenefits = [];
  List item = [];
  List daycount = [];
  List rate = [];
  List limit = [];
  List itemMAJOR = [];
  List daycountMAJOR = [];
  List rateMAJOR = [];
  List limitMAJOR = [];
  String _benefit;
  dynamic data;

  //lists of data for in-patient schedule of benefits
  List benefitIP = [];
  List benefitsIP = [];
  List uniqueBenefitsIP = [];
  List itemIP = [];
  List daycountIP = [];
  List rateIP = [];
  List limitIP = [];
  String _benefitIP;
  List itemIPMAJOR = [];
  List daycountIPMAJOR = [];
  List rateIPMAJOR = [];
  List limitIPMAJOR = [];
  dynamic dataIP;

  //lists of data for maternal schedule of benefits
  List benefitMAT = [];
  List benefitsMAT = [];
  List uniqueBenefitsMAT = [];
  List itemMAT = [];
  List daycountMAT = [];
  List rateMAT = [];
  List limitMAT = [];
  String _benefitMAT;
  List itemMATMAJOR = [];
  List daycountMATMAJOR = [];
  List rateMATMAJOR = [];
  List limitMATMAJOR = [];

  dynamic dataMAT;

  Future<String> getBenefitsOP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    var response = await http.post(
      Uri.encodeFull('${_base_url}getSOB'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : widget?.member.cardno,
        "category" : "OP"
      }
    );
    data = json.decode(response.body);
    _benefit = data;
    setState(() {
      benefit = json.decode(_benefit);
    });
    for(var i = 0; i < benefit.length; i++){
      this.benefits.add(benefit[i]["benefitType"]);
      if(benefit[i]["benefitType"] == 'Major Benefits'){
        this.itemMAJOR.add(benefit[i]["item"]);
        benefit[i]["dayCount"] == 0.0 ? this.daycountMAJOR.add('-'):this.daycountMAJOR.add(formatter.format(benefit[i]["dayCount"]));
        benefit[i]["rate"] == 0.0 ? this.rateMAJOR.add('-'):this.rateMAJOR.add(formatter.format(benefit[i]["rate"]));
        benefit[i]["limit"] == 0.0 ? this.limitMAJOR.add('-'):this.limitMAJOR.add(formatter.format(benefit[i]["limit"]));
      } else if (benefit[i]["benefitType"] == 'Basic Benefits'){
        this.item.add(benefit[i]["item"]);
        benefit[i]["dayCount"] == 0.0 ? this.daycount.add('-'):this.daycount.add(formatter.format(benefit[i]["dayCount"]));
        benefit[i]["rate"] == 0.0 ? this.rate.add('-'):this.rate.add(formatter.format(benefit[i]["rate"]));
        benefit[i]["limit"] == 0.0 ? this.limit.add('-'):this.limit.add(formatter.format(benefit[i]["limit"]));
      }
    }
    this.uniqueBenefits = this.benefits.toSet().toList();
    setState(() {
      uniqueBenefits.length == 0 ? _hasOPBenefits = false : _hasOPBenefits = true;
    });
    return "Success!";
  }

  Future<String> getBenefitsIP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    var response = await http.post(
      Uri.encodeFull('${_base_url}getSOB'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : widget?.member.cardno,
        "category" : "IP"
      }
    );
    dataIP = json.decode(response.body);
    _benefitIP = dataIP;
    setState(() {
      benefitIP = json.decode(_benefitIP);
    });
    for(var i = 0; i < benefitIP.length; i++){
      this.benefitsIP.add(benefitIP[i]["benefitType"]);
      if(benefitIP[i]["benefitType"] == 'Major Benefits'){
        this.itemIPMAJOR.add(benefitIP[i]["item"]);
        benefitIP[i]["dayCount"] == 0.0 ? this.daycountIPMAJOR.add('-'):this.daycountIPMAJOR.add(formatter.format(benefitIP[i]["dayCount"]));
        benefitIP[i]["rate"] == 0.0 ? this.rateIPMAJOR.add('-'):this.rateIPMAJOR.add(formatter.format(benefitIP[i]["rate"]));
        benefitIP[i]["limit"] == 0.0 ? this.limitIPMAJOR.add('-'):this.limitIPMAJOR.add(formatter.format(benefitIP[i]["limit"]));
      }
      else if (benefitIP[i]["benefitType"] == 'Basic Benefits'){
        this.itemIP.add(benefitIP[i]["item"]);
        benefitIP[i]["dayCount"] == 0.0 ? this.daycountIP.add('-'):this.daycountIP.add(formatter.format(benefitIP[i]["dayCount"]));
        benefitIP[i]["rate"] == 0.0 ? this.rateIP.add('-'):this.rateIP.add(formatter.format(benefitIP[i]["rate"]));
        benefitIP[i]["limit"] == 0.0 ? this.limitIP.add('-'):this.limitIP.add(formatter.format(benefitIP[i]["limit"]));
      }
    }
    this.uniqueBenefitsIP = this.benefitsIP.toSet().toList();
    setState(() {
      uniqueBenefitsIP.length == 0 ? _hasIPBenefits = false : _hasIPBenefits = true;
    });
    return "Success!";
  }

  Future<String> getBenefitsMAT() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    var response = await http.post(
      Uri.encodeFull('${_base_url}getSOB'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : widget?.member.cardno,
        "category" : "MAT"
      }
    );
    dataMAT = json.decode(response.body);
    _benefitMAT = dataMAT;
    setState(() {
      benefitMAT = json.decode(_benefitMAT);
    });
    for(var i = 0; i < benefitMAT.length; i++){
      this.benefitsMAT.add(benefitMAT[i]["benefitType"]);
      if(benefitMAT[i]["benefitType"] == 'Major Benefits'){
        this.itemMATMAJOR.add(benefitMAT[i]["item"]);
        benefitMAT[i]["dayCount"] == 0.0 ? this.daycountMATMAJOR.add('-'):this.daycountMATMAJOR.add(formatter.format(benefitMAT[i]["dayCount"]));
        benefitMAT[i]["rate"] == 0.0 ? this.rateMATMAJOR.add('-'):this.rateMATMAJOR.add(formatter.format(benefitMAT[i]["rate"]));
        benefitMAT[i]["limit"] == 0.0 ? this.limitMATMAJOR.add('-'):this.limitMATMAJOR.add(formatter.format(benefitMAT[i]["limit"]));
      }
      else if (benefitMAT[i]["benefitType"] == 'Basic Benefits'){
        this.itemMAT.add(benefitMAT[i]["item"]);
        benefitMAT[i]["dayCount"] == 0.0 ? this.daycountMAT.add('-'):this.daycountMAT.add(formatter.format(benefitMAT[i]["dayCount"]));
        benefitMAT[i]["rate"] == 0.0 ? this.rateMAT.add('-'):this.rateMAT.add(formatter.format(benefitMAT[i]["rate"]));
        benefitMAT[i]["limit"] == 0.0 ? this.limitMAT.add('-'):this.limitMAT.add(formatter.format(benefitMAT[i]["limit"]));
      }
    }
    this.uniqueBenefitsMAT = this.benefitsMAT.toSet().toList();
    setState(() {
      uniqueBenefitsMAT.length == 0 ? _hasMatBenefits =  false : _hasMatBenefits =  true;
    });
    return "Success!";
  }


  @override
  void initState() {
    super.initState();
    getBenefitsOP();
    getBenefitsIP();
    getBenefitsMAT();
    _appSessionCallback = widget.appSessionCallback;
    setState(() {
      cardNo = widget.member.cardno;
      rightCardNo = cardNo.substring(14,17);
      print(rightCardNo);
      if(rightCardNo != '000'){
        this._isMember = false;
      } else {
        this._isMember = true;
      }
      _mDependent = _getDependentsInfo();
      Timer(Duration(seconds: 10), () {
        setState((){
          _hasData = false;
          print('has no data');
        });
      });
    });
  }

  void _openDialer(String contactNumber) {
    UrlLauncher.openPhone(contactNumber);
    _appSessionCallback.pauseAppSession();
  }

  Future<List<Dependent>> _getDependentsInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetDependentsInfo';
    var res = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : widget?.member.cardno
      }
    );
    var json = jsonDecode(jsonDecode(res.body));

    print(url);
    List<Dependent> data = [];
    json.forEach((entity) {
      data.add(Dependent.fromJson(entity));
    });

    if(data[0].cardno != null) {
      print('data');
      print(data[0].cardno);
      print('${data[0].firstName} ${data[0].lastName}');
      return data;
    }
    return null;
  }

  Widget _generateQRCode(double size, String qrData){
    return QrImage(
      data: qrData,
      version: QrVersions.auto,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Policy Details'),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
      ),
      body: GestureDetector(
        onDoubleTap: (){
          setState(() {
            //matrix = zerada;
          });
        },
        child: MatrixGestureDetector(
          shouldRotate: false,
          onMatrixUpdate: (m,tm,sm,rm){
            matrix = m;
            notifier.value = matrix;
          },
          child: AnimatedBuilder(
            animation: notifier,
            builder: (ctx, child){
              return Container(
                child: LayoutBuilder(
                    builder: (context, constraint) {
                      final height = constraint.maxHeight;
                      final width = constraint.maxWidth;
                      final heightBody = height * .9;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              height: heightBody,
                              width: width,
                              child: ListView(
                                children: <Widget>[
                                  _virtualIDCard(height, width),
                                  SizedBox(height: 15.0,),
                                  _getEntitlementDetails(heightBody, width),
                                  //_getDivider(height, width),
                                  //_getDentalInfo(height, width),
                                  _getDivider(heightBody, width),
                                  _getLifeEnsuredDetails(heightBody, width),
                                  _getDivider(heightBody, width),
                                  Visibility(
                                    visible: _isMember,
                                    child: _getDependentsDetails(heightBody, width),
                                  ),
                                  Visibility(
                                    visible: _isMember,
                                    child: _getDivider(heightBody, width),
                                  )
                                  //_getAnnualPhysicalExam(heightBody, width),
                                ],
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    copyRightText()
                                  ],
                                )
                            ),
                          ],
                        ),
                      );
                    }
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _getEntitlementDetails(double height, double width) {
    return Container(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: Text('Schedule of Benefits',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),)
          ),
          SizedBox(height: 20),
          // _basicMedical(),
          // _basicMedical(),
          // _basicMedical(),
          //_basicMedical(),
          Visibility(
            visible: _hasIPBenefits,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10,0,10,10),
              child: RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black87)),
                elevation: 1.0,
                onPressed: () {
                  _appSessionCallback.pauseAppSession();
                },
                child: ExpansionTile(
                    trailing: Icon(Icons.add),
                    title: Text('IN PATIENT', style: TextStyle(color: Colors.black)),
                    backgroundColor: Colors.white,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Container(
                          color: mPrimaryColor,
                          height: 2,
                        ),
                      ),
                      ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: this.uniqueBenefitsIP.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ExpansionTile(
                                trailing: Icon(Icons.add),
                                title: Text(this.uniqueBenefitsIP[index], style: TextStyle(color: Colors.black)),
                                backgroundColor: Colors.white,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                                    child: Container(
                                      color: mPrimaryColor,
                                      height: 2,
                                    ),
                                  ),
                                  Scrollbar(
                                    isAlwaysShown: true,
                                    showTrackOnHover: true,
                                    hoverThickness: 10,
                                    thickness: 10,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 1.0),
                                                child: Container(
                                                  color: mPrimaryColor,
                                                  height: 2,
                                                ),
                                              ),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text('Item', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getItemIP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Rate', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getRateIP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Day Count', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getDayCountIP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Limit', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getLimitIP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                            ]
                                        )
                                    ),
                                  ),
                                ]
                            );
                          }
                      )
                    ]
                ),
              ),
            ),
          ),
          Visibility(
            visible: _hasOPBenefits,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10,0,10,10),
              child: RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black87)),
                elevation: 1.0,
                onPressed: () {
                  _appSessionCallback.pauseAppSession();
                },
                child: ExpansionTile(
                    trailing: Icon(Icons.add),
                    title: Text('OUT PATIENT', style: TextStyle(color: Colors.black)),
                    backgroundColor: Colors.white,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Container(
                          color: mPrimaryColor,
                          height: 2,
                        ),
                      ),
                      ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: this.uniqueBenefits.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ExpansionTile(
                                trailing: Icon(Icons.add),
                                title: Text(this.uniqueBenefits[index], style: TextStyle(color: Colors.black)),
                                backgroundColor: Colors.white,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                                    child: Container(
                                      color: mPrimaryColor,
                                      height: 2,
                                    ),
                                  ),
                                  Scrollbar(
                                    isAlwaysShown: true,
                                    showTrackOnHover: true,
                                    hoverThickness: 10,
                                    thickness: 10,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(vertical: 1.0),
                                                      child: Container(
                                                        color: mPrimaryColor,
                                                        height: 2,
                                                      ),
                                                    ),
                                                    Text('Item', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getItemOP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Rate', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getRateOP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Day Count', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getDayCountOP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Limit', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getLimitOP(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                            ]
                                        )
                                    ),
                                  ),
                                ]
                            );
                          }
                      )
                    ]
                ),
              ),
            ),
          ),
          Visibility(
            visible: _hasMatBenefits,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10,0,10,10),
              child: RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Colors.black87)),
                elevation: 1.0,
                onPressed: () {
                  _appSessionCallback.pauseAppSession();
                },
                child: ExpansionTile(
                    trailing: Icon(Icons.add),
                    title: Text('MATERNITY', style: TextStyle(color: Colors.black)),
                    backgroundColor: Colors.white,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Container(
                          color: mPrimaryColor,
                          height: 2,
                        ),
                      ),
                      ListView.builder(
                          primary: false,
                          shrinkWrap: true,
                          itemCount: this.uniqueBenefitsMAT.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ExpansionTile(
                                trailing: Icon(Icons.add),
                                title: Text(this.uniqueBenefitsMAT[index], style: TextStyle(color: Colors.black)),
                                backgroundColor: Colors.white,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 1.0),
                                    child: Container(
                                      color: mPrimaryColor,
                                      height: 2,
                                    ),
                                  ),
                                  Scrollbar(
                                    isAlwaysShown: true,
                                    showTrackOnHover: true,
                                    hoverThickness: 10,
                                    thickness: 10,
                                    child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 1.0),
                                                child: Container(
                                                  color: mPrimaryColor,
                                                  height: 2,
                                                ),
                                              ),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Item', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getItemMAT(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Rate', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getRateMAT(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Day Count', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getDayCountMAT(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                              SizedBox(width:20),
                                              Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text('Limit', style:TextStyle(fontSize: 12.0)),
                                                    SizedBox(height: 10.0),
                                                    getLimitMAT(index),
                                                    SizedBox(height: 20.0),
                                                  ]
                                              ),
                                            ]
                                        )
                                    ),
                                  ),
                                ]
                            );
                          }
                      )
                    ]
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Container(
              height: (height * .25) * .75,
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('Period Coverage', style: TextStyle(fontSize: height <= 500 ? 12 : 15.0,),),
                      Text('Room and Board', style: TextStyle(fontSize: height <= 500 ? 12 : 15.0,),),
                      Text('Max Benefit Limit', style: TextStyle(fontSize: height <= 500 ? 12 : 15.0,),),
                    ],
                  ),
                  SizedBox(width: 50.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text('${widget.member.coverstartdt} - ${widget.member.coverenddt}',
                          style: TextStyle(fontSize: height <= 500 ? 12 : 15.0,), textAlign: TextAlign.right),
                        Text(widget.member.roomnboard, style: TextStyle(fontSize: height <= 500 ? 12 : 15.0,),textAlign: TextAlign.right),
                        Text(widget.member.limit, style: TextStyle(fontSize: height <= 500 ? 12 : 15.0,),textAlign: TextAlign.right),
                      ],
                    ),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }

  Widget _getLifeEnsuredDetails(double height, double width) {
    return Container(
      height: height * .3,
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: Text('Member Information',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),)
          ),
          Container(
              height: (height * .3) * .8,
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text('First Name', style: TextStyle(fontSize: 15.0,),),
                      Text('Last Name', style: TextStyle(fontSize: 15.0,),),
                      Text('Middle Name', style: TextStyle(fontSize: 15.0,),),
                      Text('Date of Birth', style: TextStyle(fontSize: 15.0,),),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(widget.member?.firstName, style: TextStyle(fontSize: 15.0,),),
                        Text(widget.member?.lastName, style: TextStyle(fontSize: 15.0,),),
                        Text(widget.member?.midname, style: TextStyle(fontSize: 15.0,),),
                        Text(widget.member?.dob, style: TextStyle(fontSize: 15.0,),),
                      ],
                    ),
                  ),
                ],
              )
          )
        ],
      ),

    );
  }

  Widget _getDentalInfo(double height, double width) {
    return Container(
      //height: height * .4,
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: Text('Dental',
                style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),)
          ),
          SizedBox(height: 10),
          Container(
              height: 60,
              child: Text('For Dental Availment, the member must call their assigned Dental Group for appointment. Please see list below.')
          ),
          Container(
            width: width,
            child: Text('Dental Network Company', textAlign: TextAlign.left, style: TextStyle(fontSize: 15.0),),
          ),
          SizedBox(height: 10),
          Stack(
              children: <Widget>[
                Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Icon(Icons.phone, size: height <= 600 ? 60 : 70,)
                    )
                ),
                Container(
                    height: (height * .2) * .7,
                    padding: const EdgeInsets.only(left: 90.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text('No Data', style: TextStyle(fontSize: 14.0,),),
                            Text('No Data', style: TextStyle(fontSize: 14.0,),),
                            Text('No Data', style: TextStyle(fontSize: 14.0,),),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                  child: InkWell(
                                    child: Text('Call now >>>', style: TextStyle(fontSize: 14.0,),),
                                    onTap: (){
                                      _openDialer('');
                                    },
                                  )
                              ),
                              Container(
                                  child: InkWell(
                                    child: Text('Call now >>>', style: TextStyle(fontSize: 14.0,),),
                                    onTap: (){
                                      _openDialer('');
                                    },
                                  )
                              ),
                              Container(
                                  child: InkWell(
                                    child: Text('Call now >>>', style: TextStyle(fontSize: 14.0,),),
                                    onTap: (){
                                      _openDialer('');
                                    },
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ]
          ),
          SizedBox(height: 20,)
        ],
      ),

    );
  }

  Widget _getDependentsDetails(double height, double width) {
    return Container(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text('Dependents Details',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w600),),
              )
          ),
          FutureBuilder<List<Dependent>>(
            future: _mDependent,
            builder: (BuildContext context, AsyncSnapshot<List<Dependent>> snapshot){
              if(snapshot.hasData) {
                print('dependent has data');
                if(snapshot.data != null) {
                  if (snapshot.data.length > 0) {
                    print('dependent valid data');
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _getDependents(snapshot.data),
                    );
                  }else {
                    print('dependent null data');
                    return Container(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: Container(child: _hasData == true ? CircularProgressIndicator() : Text('No data found'),));
                  }
                }
                else {
                  print('dependent invalid data');
                  return Container(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Container(child: _hasData == true ? CircularProgressIndicator() : Text('No data found'),));
                }
              }else {
                print('{ no data');
                return Container(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Container(child: _hasData == true ? CircularProgressIndicator() : Text('No data found'),
                    )
                );
              }
            },
          ),
        ],
      ),

    );
  }


  List<Widget> _getDependents(List<Dependent> dependent) {
    List<Widget> list = List();
    dependent.forEach((entity) {
      list.add(_getDependentButton(entity));
    });

    return list;
  }
  

  Widget _getDependentButton(Dependent dependent){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: RaisedButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        elevation: 1.0,
        onPressed: () {
          _appSessionCallback.pauseAppSession();
        },
        child: ExpansionTile(
          title: Text('${dependent.firstName} ${dependent.lastName} (${dependent.reldesc})', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: Container(
                color: mPrimaryColor,
                height: 2,
              ),
            ),
            Scrollbar(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          height: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Text('Relationship',style: TextStyle(fontSize: 12)),
                              Text('First Name',style: TextStyle(fontSize: 12)),
                              Text('Last Name',style: TextStyle(fontSize: 12)),
                              Text('Middle Name',style: TextStyle(fontSize: 12)),
                              Text('Date of Birth',style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        SizedBox(width:20),
                        Container(
                          height: 150,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(dependent.reldesc,style: TextStyle(fontSize: 12)),
                              Text(dependent.firstName,style: TextStyle(fontSize: 12)),
                              Text(dependent.lastName,style: TextStyle(fontSize: 12)),
                              Text(dependent.midname,style: TextStyle(fontSize: 12)),
                              Text(dependent.dob,style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                        SizedBox(width: 15),
                        InkWell(
                          onTap: () {
                            _appSessionCallback.pauseAppSession();
                            Navigator.of(context).push(
                                PageRouteBuilder(
                                    opaque: false,
                                    barrierDismissible: true,
                                    pageBuilder: (BuildContext context, _, __) {
                                      return _fullScreenQRCode(context, dependent.qrcode, dependent.qrcode);
                                    }
                                )
                            );
                          },
                          child: Hero(
                            tag: dependent.qrcode,
                            child: Container(
                              width: 100,
                              child: _generateQRCode(100, dependent.qrcode),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Column(
                      children: <Widget>[
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text('Benefits',
                              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600),)
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              height: 90,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text('Period Coverage',style: TextStyle(fontSize: 12)),
                                  Text('Room and Board',style: TextStyle(fontSize: 12)),
                                  Text('Max Benefit Limit',style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Container(
                              height: 90,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Flexible(
                                      fit: FlexFit.loose,
                                      child: Text('${dependent.coverstartdt} - ${dependent.coverenddt}',softWrap: false, overflow: TextOverflow.fade, style: TextStyle(fontSize: 12))
                                  ),
                                  Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(dependent.roomnboard,softWrap: false, maxLines: 2,  overflow: TextOverflow.fade, style: TextStyle(fontSize: 12))
                                  ),
                                  Flexible(
                                      fit: FlexFit.loose,
                                      child: Text(dependent.limit, softWrap: false, maxLines: 2, overflow: TextOverflow.fade, style: TextStyle(fontSize: 12))
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            )
          ],),
      ),
    );
  }

  Widget _getDivider(double height, double width) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: Container(
        color: mPrimaryColor,
        height: 2,
        width: width,
      ),
    );
  }

  Widget _fullScreenQRCode(BuildContext context, String qrCode, String tag) {
    return GestureDetector(
      onTap: (){
        _appSessionCallback.pauseAppSession();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        color: Colors.black.withOpacity(0.7),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  child: FloatingActionButton(
                      elevation: 3.0,
                      backgroundColor: Colors.teal,
                      onPressed: (){
                        _appSessionCallback.pauseAppSession();
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close, color: Colors.white,)
                  ),
                ),
              ),
              Center(
                child: Hero(
                  tag: tag,
                  child: Container(
                      height: 350,
                      color: Colors.white,
                      child: _generateQRCode(350, qrCode)
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _virtualIDCard(double height, double width){
    return InkWell(
      onTap: () {
        _appSessionCallback.pauseAppSession();
        Navigator.of(context).push(
            PageRouteBuilder(
                opaque: false,
                barrierDismissible: true,
                pageBuilder: (BuildContext context, _, __) {
                  return _fullScreenQRCode(context, widget.member.qrcode, 'member-qr');
                }
            )
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          child: Container(
            height: height / 2.8,
            width: width,
            color: mPrimaryColor,
            child: Stack(
              children: <Widget>[
                Positioned(
                    bottom: (height / 4.2),
                    child: _topLogo(height / 4, width / 4)
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: width * .25,
                    //color: Colors.white60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Hero(
                          tag: 'member-qr',
                          child: _generateQRCode(90, widget.member.qrcode),
                        ),
                        //Text('Scan QR Code', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: (height / 5) * .65,
                  child: Container(
                    width: width,
                    height: (height / 3.2) * .7,
                    //color: Colors.white54,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0, bottom: 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                            width: width * .65,
                            child: Text(
                                widget.member.lastName + ', ' + widget.member.firstName,
                                style: TextStyle(
                                    fontFamily: 'Abel',
                                    fontSize: height <= 600 ? 12.0 : 17.0,
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text('${_formatCardNo(widget.member.cardno)}',
                              style: TextStyle(fontFamily: 'Abel', fontSize: height <= 600 ? 12.0 :17.0, letterSpacing: 4.0)),
                          // SizedBox(
                          //   height: .65,
                          // ),
                          Text(widget.member.policyholder,
                              style: TextStyle(fontFamily: 'Abel', fontSize: height <= 600 ? 12.0 :15.0,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: 3.0,
                          ),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Stack(children: <Widget>[
                                  Text('MAX BENEFIT LIMIT',
                                      style: TextStyle(fontFamily: 'Abel', fontSize: height <= 565 ? 9.0 : 11.0)),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.fromLTRB(0, 17, 10, 0),
                                            child: Text(
                                                widget.member.limit, style: TextStyle(fontFamily: 'Abel', fontWeight: FontWeight.bold, fontSize: height <= 565 ? 9.0 : 13)))
                                      ],
                                    ),
                                  ),
                                ]),
                                SizedBox(width: 15),
                                Stack(children: <Widget>[
                                  Text('VALIDITY PERIOD',
                                      style: TextStyle(fontFamily: 'Abel', fontSize: height <= 565 ? 9.0 : 11.0)),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                            margin: EdgeInsets.fromLTRB(0, 17, 10, 0),
                                            child: Text(
                                                widget.member.coverstartdt + ' - ' + widget.member.coverenddt, style: TextStyle(fontFamily: 'Abel', fontWeight: FontWeight.bold,  fontSize: height <= 565 ? 9.0 : 13)))
                                      ],
                                    ),
                                  ),
                                ]),
                              ]),
                          SizedBox(height: 3),
                          Text(
                            'ROOM & BOARD UNIT',
                            style: TextStyle(fontFamily: 'Abel', fontSize: height <= 565 ? 9.0 : 11.0),
                          ),
                          SizedBox(
                            width: width * .75,
                            child: Text(widget.member.roomnboard,
                                style: TextStyle(
                                    fontFamily: 'Abel',
                                    fontSize: height <= 565 ? 9.0 : 13.0,
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topLogo(double height, double width) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Container(
          height: height,
          width: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 150,
              child: Image.asset('assets/images/EtiqaLogoColored_SmileApp.png', fit: BoxFit.contain),
            ),
          ),
        ),
      ],
    );
  }

  getItemIP(int index){
    if(this.uniqueBenefitsIP[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: this.itemIP.map((itemIP) => Text(itemIP.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsIP[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: this.itemIPMAJOR.map((itemIPMAJOR) => Text(itemIPMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getItemOP(int index){
    if(this.uniqueBenefits[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: this.item.map((item) => Text(item.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefits[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: this.itemMAJOR.map((itemMAJOR) => Text(itemMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getItemMAT(int index){
    if(this.uniqueBenefitsMAT[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: this.itemMAT.map((itemMAT) => Text(itemMAT.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsMAT[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: this.itemMATMAJOR.map((itemMATMAJOR) => Text(itemMATMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getRateIP(int index){
    if(this.uniqueBenefitsIP[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.rateIP.map((rateIP) => Text(rateIP.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsIP[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.rateIPMAJOR.map((rateIPMAJOR) => Text(rateIPMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getRateOP(int index){
    if(this.uniqueBenefits[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.rate.map((rate) => Text(rate.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefits[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.rateMAJOR.map((rateIPMAJOR) => Text(rateMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getRateMAT(int index){
    if(this.uniqueBenefitsMAT[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.rateMAT.map((rateMAT) => Text(rateMAT.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsMAT[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.rateMATMAJOR.map((rateMATMAJOR) => Text(rateMATMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getDayCountIP(int index){
    if(this.uniqueBenefitsIP[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.daycountIP.map((daycountIP) => Text(daycountIP.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsIP[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.daycountIPMAJOR.map((daycountIPMAJOR) => Text(daycountIPMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getDayCountOP(int index){
    if(this.uniqueBenefits[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.daycount.map((daycount) => Text(daycount.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefits[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.daycountMAJOR.map((daycountMAJOR) => Text(daycountMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getDayCountMAT(int index){
    if(this.uniqueBenefitsMAT[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.daycountMAT.map((daycountMAT) => Text(daycountMAT.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsMAT[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.daycountMATMAJOR.map((daycountMATMAJOR) => Text(daycountMATMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getLimitIP(int index){
    if(this.uniqueBenefitsIP[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.limitIP.map((limitIP) => Text(limitIP.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsIP[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.limitIPMAJOR.map((limitIPMAJOR) => Text(limitIPMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getLimitOP(int index){
    if(this.uniqueBenefits[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.limit.map((limit) => Text(limit.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefits[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.limitMAJOR.map((limitMAJOR) => Text(limitMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
  getLimitMAT(int index){
    if(this.uniqueBenefitsMAT[index] == 'Basic Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.limitMAT.map((limitMAT) => Text(limitMAT.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
    else if(this.uniqueBenefitsMAT[index] == 'Major Benefits'){
      return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: this.limitMATMAJOR.map((limitMATMAJOR) => Text(limitMATMAJOR.toString(), style:TextStyle(fontSize: 12.0))).toList()
      );
    }
  }
}
