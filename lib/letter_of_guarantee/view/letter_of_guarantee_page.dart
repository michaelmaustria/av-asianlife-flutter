import 'dart:convert';
import 'dart:io';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/letter_of_guarantee/presenter/letter_of_guarantee_presenter.dart';
import 'package:av_asian_life/letter_of_guarantee/view/view_pdf.dart';
import 'package:av_asian_life/rate_screen/view/rate_screen_page.dart';
import 'package:av_asian_life/request_log/view/request_log_page.dart';
import 'package:av_asian_life/letter_of_guarantee/view/VerifyCancelLogPage.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:http/http.dart' as http;

import '../letter_of_guarantee_contract.dart';

class LetterOfGuaranteePage extends StatefulWidget {
  static String tag = 'log-page';
  final Member member;


  final IApplicationSession appSessionCallback;

  LetterOfGuaranteePage({this.member, this.appSessionCallback});

  @override
  _LetterOfGuaranteePageState createState() => _LetterOfGuaranteePageState();
}

class _LetterOfGuaranteePageState extends State<LetterOfGuaranteePage> with AutomaticKeepAliveClientMixin<LetterOfGuaranteePage>
    implements ILetterOfGuaranteeView {

  @override
  bool get wantKeepAlive => true;

  IApplicationSession _appSessionCallback;

  ILetterOfGuaranteePresenter _mPresenter = LetterOfGuaranteePresenter();

  Future<List<Requests>> _outPatients, _inPatients;

  var cardHeight;
  var barColor;
  var textColor;
  var txtStatus;

  User _mUser;

  bool notifOpen = true;
  bool testNotif = false;
  bool fileLogVis = false;

  List msgDesc = [];
  List reqId = [];

  String _msgDesc;
  String urlPDFPath = "";
  String requestId;

  AlertDialog _loadingDialog;

  Member _mMember;

  @override
  void initState() {
    super.initState();
    _mPresenter.onAttach(this);

    _appSessionCallback = widget.appSessionCallback;

    setState(() {
      if(widget?.member.cardno.substring(14,17) != '000'){
        getPersonalSettings();
      } else {
        fileLogVis = true;
      }

      if(widget?.member.status == 'POLICY TERMINATED'){
        fileLogVis = false;
      } else {
        fileLogVis = true;
      }
      _getUserAndHistory();
    });
  }

  Future getPersonalSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    dynamic data;
    dynamic settings = [];

    String _username;

    _username = prefs.getString('_username')??('');

    var response = await http.post(
      Uri.encodeFull('${_base_url}GetPersonalSettings'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "appuserid" : _username
      }
    );
    data = json.decode(response.body);
    settings = json.decode(data);
    print(settings[1]['value']);
    setState((){
      if(settings[1]['value'] != 1){
        fileLogVis = false;
      } else {
        fileLogVis = true;
      }
    });
    return "Success!";
  }

  Future<String> cancelLog(String reqid) async {
    dynamic data;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    var response = await http.post(
      Uri.encodeFull("${_base_url}CancelLOGRequest"),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "requestid" : reqid,
        "appuserid" : "administrator",
      }
    );
    data = json.decode(response.body);
    msgDesc = json.decode(data);
    this._msgDesc = msgDesc[0]['msgDescription'];
    print(_msgDesc);
    Navigator.pop(context);
    successDialog();
    return "Success!";
  }

  void successDialog(){

    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text(this._msgDesc, textAlign: TextAlign.center,),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                _navigateToHomePage(widget.member.cardno);
              },
            )
          ],
        ));
  }

  void showCancelDialog(String reqid){
    Widget yesButton = FlatButton(
      child: Text('YES'),
      onPressed: () {
        cancelLog(reqid);
      },
    );
    Widget noButton = FlatButton(
      child: Text('NO'),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(""),
      content: Text("Are you sure you want to cancel this LOG Request?",textAlign: TextAlign.center),
      actions: [
        yesButton,
        noButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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

  _getUserAndHistory() async {
    _mUser = await _mPresenter.getUserData();
    print('User: ${_mUser.cardNo}');

    setState(() {
      _outPatients = _mPresenter.initLogHistory(_mUser, '1');
      _inPatients =  _mPresenter.initLogHistory(_mUser, '2');
    });
  }

  @override
  void onError(String message) {

  }

  @override
  void onSuccess(String message) {

  }

  void _updateNotification(){
    setState(() {
      notifOpen = false;
    });
    print(reqId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Letter of Guarantee (LOG)'),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
      ),
      body: DefaultTabController(
          length: 2,
          child: Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(maxHeight: 150.0),
                child: Material(
                  color: Colors.transparent,
                  child: TabBar(
                    labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                    indicatorWeight: 5.0,
                    onTap: (_) { _appSessionCallback.pauseAppSession(); },
                    tabs: [
                      Tab(text: 'Out-Patient',),
                      Tab(text: 'In-Patient',),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    GestureDetector(
                        onTap: () { _appSessionCallback.pauseAppSession(); },
                        child: _getOutPatientBody()
                    ),
                    GestureDetector(
                        onTap: () { _appSessionCallback.pauseAppSession(); },
                        child: _getInPatientBody(),
                    ),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      padding: const EdgeInsets.only(top: 5.0, bottom: 20.0),
                      child: copyRightText()
                  )
              ),
            ],
          ))
    );
  }

  Widget _getOutPatientBody(){
    return LayoutBuilder(
      builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                fileLogVis == true ? Align(
                  alignment: Alignment.topCenter,
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 10),
                    color: mPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(Icons.add, color: Colors.black87,)
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Text('Request LOG', style: TextStyle(fontSize: 18.0, color: Colors.black87))
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      _appSessionCallback.pauseAppSession();
                      Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => RequestLogPage(availType: '1', member: widget.member, appSessionCallback: _appSessionCallback)),
                      );
                    },
                  ),
                ) : Offstage(),
                SizedBox(
                  height: 10.0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('History of Requests', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FutureBuilder<List<Requests>>(
                  future: _outPatients,
                  builder: (BuildContext context, AsyncSnapshot<List<Requests>> snapshot){
                    if(!snapshot.hasData)
                      return Center(child: myLoadingIcon(height: height * .30, width: width * .25),);
                    else {
                      if(snapshot.data.length > 0)
                        return Column(
                          children: _getHistoryRequest(height, snapshot.data),
                        );
                      else return Center(child: Text('No records found.'),);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getInPatientBody(){
    return LayoutBuilder(
      builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                fileLogVis == true ? Align(
                  alignment: Alignment.topCenter,
                  child: RaisedButton(
                    padding: EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 10),
                    color: mPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    child: SizedBox(
                      width: double.infinity,
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(Icons.add, color: Colors.black87,)
                          ),
                          Align(
                              alignment: Alignment.center,
                              child: Text('Request LOG', style: TextStyle(fontSize: 18.0, color: Colors.black87))
                          ),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) => RequestLogPage(availType: '2', member: widget.member, appSessionCallback: _appSessionCallback,)),
                      );
                    },
                  ),
                ) : Offstage(),
                SizedBox(
                  height: 10.0,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('History of Requests', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FutureBuilder<List<Requests>>(
                  future: _inPatients,
                  builder: (BuildContext context, AsyncSnapshot<List<Requests>> snapshot){
                    if(!snapshot.hasData)
                      return Center(child: myLoadingIcon(height: height * .30, width: width * .25),);
                    else {
                      if(snapshot.data.length > 0)
                        return Column(
                          children: _getHistoryRequest(height, snapshot.data),
                        );
                      else return Center(child: Text('No records found.'),);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getHistoryRequest(double height, List<Requests> requests) {

    bool hasNotif = false;

    
  
    List<Widget> cards = List<Widget>();

    requests.forEach((request) {
      cardHeight = height / 3.5;
      txtStatus = request.status.toUpperCase();
      barColor = mPrimaryColor;
      textColor = Colors.black87;

      _setStatusColor(request);

      var dateFormat;
      if(request?.dateRequested != null) {
        dateFormat = DateFormat('MM-dd-yyyy | HH:mm').format(
            DateTime.parse(request.dateRequested.toIso8601String()));
      }

      if(txtStatus == 'EXPIRED'){
        reqId.add(request.reqId);
        hasNotif = true;
      }else{
        hasNotif = false;
      }

      var card = Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: InkWell(
          onTap: (){
            print('log tapped');
            setState(() {
              
            });
          },
          child: Container(
          height: cardHeight * .9,
          child: Stack(
            children: <Widget>[
              // CircleAvatar(
              //   backgroundColor: testNotif == false ? Colors.red : Colors.white,
              //   radius: 5,
              // ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: cardHeight - cardHeight * 0.3,
                  width: cardHeight - cardHeight * 0.2,
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // RaisedButton(
                        //     color: barColor,
                        //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                        //     elevation: 1.0,
                        //     onPressed: () {
                        //       var hsp = request.hospitalName;
                        //       var reId = request.reqId;
                        //       var dte = dateFormat;
                        //       var apvcode = request.status;
                        //       _appSessionCallback.pauseAppSession();
                        //           Navigator.of(context).push(
                        //           PageRouteBuilder(
                        //           pageBuilder: (context, _, __) => _getDownloadForm(context, hsp, reId, dte, apvcode), opaque: false));
                        //     },
                        //     child: Text('Download', style: TextStyle(fontSize: height <= 500 ? 9.0 : 12)),
                        //   ),
                        // RaisedButton(
                        //   color: barColor,
                        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                        //   elevation: 1.0,
                        //   onPressed: () async {
                        //     if(request.status.toString() == 'FOR APPROVAL'){
                        //       SharedPreferences prefs = await SharedPreferences.getInstance();
                        //       prefs.setString('reqId',request.reqId);
                        //       //cancelLog();
                        //       showCancelDialog();
                        //       // Navigator.push(context,
                        //       //     MaterialPageRoute(
                        //       //         builder: (context) => VerifyCancelLogPage(isForVerification: false)));
                        //       // _getUserAndHistory();
                        //     } else {
                        //       showMessageDialog();
                        //     }
                        //     _appSessionCallback.pauseAppSession();
                        //   },
                        //   child: Text('Cancel', style: TextStyle(fontSize: height <= 500 ? 9.0 : 12),),
                        // ),
                      ],
                    ),
                )
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: cardHeight - cardHeight * 0.3,
                    padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Patient:  ', style: TextStyle(fontSize: height <= 500 ? 11.0 : 14)),
                            Expanded(
                                child: Text(request.patientName == null ? 'N/A' : request?.patientName,
                                    overflow: TextOverflow.ellipsis, maxLines: 3, textAlign: TextAlign.end, style: TextStyle(fontSize: height <= 500 ? 11.0 : 14))
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Provider:  ', style: TextStyle(fontSize: height <= 500 ? 11.0 : 14)),
                            Expanded(
                                child: Text(request.hospitalName == null ? 'N/A' : request?.hospitalName,
                                  overflow: TextOverflow.ellipsis, maxLines: 3, textAlign: TextAlign.end, style: TextStyle(fontSize: height <= 500 ? 11.0 : 14))
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Request ID:', style: TextStyle(fontSize: height <= 500 ? 11.0 : 14)),
                            Expanded(
                                child: Text(request.reqId == null ? 'N/A' : request?.reqId,
                                  overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end, style: TextStyle(fontSize: height <= 500 ? 11.0 : 14))
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Request Date:', style: TextStyle(fontSize: height <= 500 ? 11.0 : 14)),
                            Expanded(
                                child: Text(dateFormat == null ? 'N/A' : dateFormat,
                                  overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end, style: TextStyle(fontSize: height <= 500 ? 11.0 : 14))
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  child: Container(
                    color: barColor,
                    height: cardHeight * 0.2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Stack(
                        children: <Widget>[
                          // Align(
                          //     alignment: Alignment.centerLeft,
                          //     child: Text('STATUS', style: TextStyle(fontSize: 15.0, color: textColor))
                          // ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(txtStatus, style: TextStyle(fontSize: 15.0, color: textColor))
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              // child: PopupMenuButton<String>(
                              //     padding: EdgeInsets.zero,
                              //     elevation: 4,
                              //     icon: Icon(Icons.more_vert),
                              //     itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              //       PopupMenuItem<String>(
                              //         value: 'Cancel',
                              //         height: 10.0,
                              //         child: InkWell(
                              //           splashColor: Colors.yellow,
                              //           highlightColor: Colors.blue.withOpacity(0.5),
                              //           onTap: () async {
                              //             SharedPreferences prefs = await SharedPreferences.getInstance();
                              //             print(request.status);
                              //             print(request.reqId);
                              //             if(request.status.toString() == 'FOR APPROVAL'){
                              //               prefs.setString('reqId',request.reqId);
                              //               showCancelDialog();
                              //             } else {
                              //               showMessageDialog();
                              //             }
                              //             _appSessionCallback.pauseAppSession();
                              //           },
                              //           child: Text('Cancel', textAlign: TextAlign.center,),
                              //         ),
                              //       ),
                              //     ]
                              // )
                            child: InkWell(
                              onTap: () async {
                                _appSessionCallback.pauseAppSession();
                                Navigator.of(context).push(PageRouteBuilder(
                                    pageBuilder: (context, _, __) => _questionMark(context, request.reqId, request.status), opaque: false));
                              },
                              child: Icon(Icons.more_vert),
                            )
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        )
      );

      cards.add(card);
    });

    //Future.delayed(const Duration(seconds: 9), () => _updateNotification());
    
    return cards;
  }

   Widget _getDownloadForm(BuildContext context, String hsp, String reId, String dte, String apvcode ) {
    return GestureDetector(
      onTap: (){
        _appSessionCallback.pauseAppSession();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 10.0),
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Center(
                child: Hero(
                  tag: 'tag',
                  child: Card(
                    elevation: 20.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child: Container(
                      height: 220,
                      child: Stack(
                        children: <Widget>[
                          apvcode == 'Approved' ? Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: cardHeight - cardHeight * 0.2,
                              width: cardHeight - cardHeight * 0.2,
                              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      child: Column(
                                        children: <Widget>[
                                          Card(
                                            color: mPrimaryColor,
                                            child: InkWell(
                                               onTap: (){
                                                    _appSessionCallback.pauseAppSession();
                                                    Navigator.push(context,
                                                    MaterialPageRoute(builder: (context) => Test(appSessionCallback: _appSessionCallback, requestId: reId)));
                                              },
                                              child: Stack(
                                              children: <Widget>[
                                                Text('Rate your', style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14)),
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                                  child: Text('Experience', style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14))
                                                ),
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                                                  child: Icon(Icons.star_border),
                                                ),
                                              ]
                                            )
                                             )
                                          )
                                        ]
                                      ),
                                    )
                                  ],
                                ),
                            )
                          ) : Offstage(),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              height: 180,
                              padding: EdgeInsets.fromLTRB(10, 0, 110, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text('Provider:  ',style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14)),
                                      Expanded(
                                          child: Text(hsp == null ? 'N/A' : hsp,
                                          overflow: TextOverflow.ellipsis, maxLines: 3, textAlign: TextAlign.end,style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14))
                                      ),
                                    ]
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text('Request ID:  ',style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14)),
                                      Expanded(
                                          child: Text(reId == null ? 'N/A' : reId,
                                          overflow: TextOverflow.ellipsis, maxLines: 3, textAlign: TextAlign.end,style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14))
                                      ),
                                    ]
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text('Request Date:  ',style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14)),
                                      Expanded(
                                          child: Text(dte == null ? 'N/A' : dte,
                                          overflow: TextOverflow.ellipsis, maxLines: 3, textAlign: TextAlign.end, style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14))
                                      ),
                                    ]
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text('Request Approved:  ', style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14)),
                                       Expanded(
                                          child: Text(apvcode == null ? 'N/A' : apvcode,
                                          overflow: TextOverflow.ellipsis, maxLines: 3, textAlign: TextAlign.end, style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14))
                                      ),                                     
                                    ]
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Text('Request Approved:  ', style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14)),
                                      // Expanded(
                                      //     child: Text(txtStatus == null ? 'N/A' : txtStatus,
                                      //     overflow: TextOverflow.ellipsis, maxLines: 3, textAlign: TextAlign.end, style: TextStyle(fontSize: cardHeight <= 130 ? 11.0 : 14))
                                      // ),
                                    ]
                                  ),
                                ]
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ClipRRect(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                 // RaisedButton(
                                 //     color: apvcode == 'approved' ? mPrimaryColor : barColor,
                                 //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                 //     elevation: 1.0,
                                 //     onPressed: () {
                                 //        _appSessionCallback.pauseAppSession();
                                 //     },
                                 //     child: Text('Download', style: TextStyle(fontSize: 12)),
                                 //  ),
                                  RaisedButton(
                                     color: mPrimaryColor,
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                     elevation: 1.0,
                                     onPressed: () {
                                       _appSessionCallback.pauseAppSession();
                                       Navigator.pop(context); 
                                     },
                                    child: Text('Cancel', style: TextStyle(fontSize: 12)),  
                                   ),
                                 ],
                               ),
                            ),
                          )
                        ],
                      ),
                    )
                  )
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _setStatusColor(Requests request) {

    barColor = mPrimaryColor;
    textColor = Colors.black87;
    txtStatus = request.status;

   if(request.status.toUpperCase() == 'FOR APPROVAL') {
     barColor = mPrimaryColor;
     textColor = Colors.black87;
     txtStatus = 'FOR APPROVAL';
   }else if(request.status.toUpperCase() == 'REQUEST RECEIVED') {
     barColor = mPrimaryColor;
     textColor = Colors.black87;
     txtStatus = 'REQUEST RECEIVED';
   }else if(request.status.toUpperCase() == 'APPROVED') {
     barColor = mPrimaryColor;
     textColor = Colors.black87;
     txtStatus = 'APPROVED';
   }else if(request.status.toUpperCase() == 'EXPIRED') {
     barColor = Colors.grey;
     textColor = Colors.white;
     txtStatus = 'EXPIRED';
   }else if(request.status.toUpperCase() == 'CANCELLED') {
     barColor = Color(0xffB5B5B5);
     textColor = Colors.black87;
     txtStatus = 'CANCELLED';
   }
   else if(request.status.toUpperCase() == 'DISAPPROVED') {
     barColor = Colors.grey;
     textColor = Colors.white;
     txtStatus = 'DISAPPROVED';
   }
   else if(request.status.toUpperCase() == 'COMPLETED') {
     barColor = Color(0xff737373);
     textColor = Colors.black87;
     txtStatus = 'COMPLETED';
   }
  }

  void showMessageDialog(){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text('You may only cancel those items that you personally requested and status are still FOR APPROVAL.',textAlign: TextAlign.center),
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

  Widget _questionMark(BuildContext context, String reqid, String status) {
    final _height = MediaQuery.of(context).size.height;
    context = this.context;
    return Container(
        color: Colors.grey[600].withOpacity(.8),
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        child: Container(
          child: Stack(children: <Widget>[
            Align(
                alignment: Alignment.topCenter,
                child: Column(children: <Widget>[
                  SizedBox(height: _height <= 669 ? _height * .7  : _height * .73),
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
                                      Container(
                                          alignment: AlignmentDirectional.topStart,
                                          margin: EdgeInsets.fromLTRB(15, 10, 10, 10),
                                          child: Material(
                                            color: Colors.white,
                                            child: InkWell(
                                              child: Row(
                                                children: <Widget>[
                                                  Text("Cancel LOG Request")
                                                ],
                                              ),
                                              onTap: () async {
                                                //if(status == 'FOR APPROVAL'){
                                                  showCancelDialog(reqid);
                                                //} else {
                                                  //showMessageDialog();
                                                //}
                                              },
                                            ),
                                          )
                                      ),
                                      Container(
                                        color: Colors.black,
                                        height: 1,
                                      ),
                                      Container(
                                          alignment: AlignmentDirectional.topStart,
                                          margin: EdgeInsets.fromLTRB(15, 10, 10, 10),
                                          child: Material(
                                            color: Colors.white,
                                            child: InkWell(
                                              child: Row(
                                                children: <Widget>[
                                                  Text("View LOG Form")
                                                ],
                                              ),
                                              onTap: () async {
                                                _showLoadingDialog();
                                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                                var _email = prefs.getString('_email');
                                                var _base_url = await ApiHelper.getBaseUrl();
                                                var _api_user = await ApiHelper.getApiUser();
                                                var _api_pass = await ApiHelper.getApiPass();
                                                var token = await ApiToken.getApiToken();

                                                String pdfUrl;
                                                String msgCode;
                                                String msgDescription;

                                                String url = '${_base_url}ViewLOGForm';
                                                var res = await http.post(
                                                  url,
                                                  headers: {
                                                    HttpHeaders.authorizationHeader: 'Bearer $token',
                                                    "UserAccount": _email
                                                  },
                                                  body: {
                                                    "userid" : _api_user,
                                                    "password" : _api_pass,
                                                    "requestID" : reqid,
                                                  }
                                                );
                                                var json = jsonDecode(jsonDecode(res.body));

                                                List<Requests> data = [];
                                                json.forEach((entity) {
                                                  data.add(Requests.fromJson(entity));
                                                  pdfUrl = entity['logfile'];
                                                  msgCode = entity['msgCode'];
                                                  msgDescription = entity['msgDescription'];
                                                });

                                                if(msgCode == '019'){
                                                  Navigator.pop(context);
                                                  showPdfFailedDialog(msgDescription);
                                                } else if ((status == 'APPROVED')&&(msgCode != '019')){
                                                  getFileFromUrl(pdfUrl,msgDescription).then((f) {
                                                    setState(() {
                                                      urlPDFPath = f.path;
                                                      print(urlPDFPath);
                                                      if(urlPDFPath != null){
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ViewPdfPage(path: urlPDFPath, url: pdfUrl, fileName: reqid)));
                                                      }
                                                    });
                                                  });
                                                } else {
                                                  Navigator.pop(context);
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) => new AlertDialog(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                                                        ),
                                                        title: new Text(""),
                                                        content: new Text(msgDescription,textAlign: TextAlign.center),
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
                                              },
                                            ),
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                              ]
                          )
                      )
                  ),
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

  Future<File> getFileFromUrl(String url, String msgDescription) async {
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      Navigator.pop(context);
      showPdfFailedDialog(msgDescription);
      throw Exception("Error opening url file");
    }
  }

  void showPdfFailedDialog(String message){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: new Text(""),
          content: new Text(message,textAlign: TextAlign.center),
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

}
