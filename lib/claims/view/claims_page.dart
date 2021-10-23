import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/claims/presenter/claims_presenter.dart';
import 'package:av_asian_life/claims/view/view_claim_pdf_page.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/claims.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/reimbursement_form/view/reimbursement_claim.dart';
import 'package:av_asian_life/reimbursement_form/view/reimbursement_form_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../claims_contract.dart';
import 'download_claim_form.dart';

class ClaimsPage extends StatefulWidget {
  static String tag = 'claims-page';
  final Member member;
  final IApplicationSession appSessionCallback;

  ClaimsPage({this.member, this.appSessionCallback});

  @override
  _ClaimsPageState createState() => _ClaimsPageState();
}

class _ClaimsPageState extends State<ClaimsPage> with AutomaticKeepAliveClientMixin<ClaimsPage>
    implements IClaimsView {

  @override
  bool get wantKeepAlive => true;

  IClaimsPresenter _mPresenter = ClaimsPresenter();

  Future<List<Claims>> _mReimbursement, _mGP;

  User _mUser;
  IApplicationSession _appSessionCallback;
  Member _member;
  Member _mMember;

  AlertDialog _loadingDialog;

  List msgDesc = [];

  String _msgDesc;

  var barColor;
  var txtStatus;
  var textColor;

  bool fileClaimVis = false;

  @override
  void initState() {
    super.initState();
    _member = widget?.member;
    _mPresenter.onAttach(this);
    _appSessionCallback = widget.appSessionCallback;
    setState(() {
      if(_member.cardno.substring(14,17) != '000'){
        getPersonalSettings();
      } else {
        fileClaimVis = true;
      }

      if(_member.status == 'POLICY TERMINATED'){
        fileClaimVis = false;
      } else {
        fileClaimVis = true;
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
        "appuserid" : _username,
      }
    );
    data = json.decode(response.body);
    settings = json.decode(data);
    print(settings[0]['value']);
    setState((){
      if(settings[0]['value'] != 1){
        fileClaimVis = false;
      } else {
        fileClaimVis = true;
      }
    });
    return "Success!";
  }

  Future<String> cancelClaim(String reqId) async {
    dynamic data;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();

    var response = await http.post(
        Uri.encodeFull("${_base_url}CancelClaimRequest"),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email,
        "DeviceID": _deviceId
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "requestid" : reqId,
        "mode" : "1",
        "appuserid" : "administrator",
      }
    );
    data = json.decode(response.body);
    msgDesc = json.decode(data);
    this._msgDesc = msgDesc[0]['msgDescription'];
    print(_msgDesc);
    successDialog(_msgDesc);
    return "Success!";
  }

  void successDialog(String msgDesc){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text(msgDesc, textAlign: TextAlign.center,),
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
      _mReimbursement = _mPresenter.initClaimsHistory(_mUser, '1');
      _mGP =  _mPresenter.initClaimsHistory(_mUser, '2');
    });
  }
  @override
  void onError(String message) {
    showMessageDialog(message);
  }

  @override
  void onSuccess(String message) {
    showMessageDialog(message);
  }

  void showMessageDialog(String message){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text(message,textAlign: TextAlign.center),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                // _navigateToHomePage(this._cardNo);
                // _timer.cancel();
              },
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Claims', textAlign: TextAlign.center),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
        centerTitle: true,
      ),
      // body: DefaultTabController(
      //     length: 2,
      //     child: Column(
      //       children: <Widget>[
      //         Container(
      //           constraints: BoxConstraints(maxHeight: 150.0),
      //           child: Material(
      //             color: Colors.transparent,
      //             child: TabBar(
      //               labelStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      //               indicatorWeight: 5.0,
      //               onTap: (_) { _appSessionCallback.pauseAppSession(); },
      //               tabs: [
      //                 Tab(text: 'Reimbursement',),
      //                 Tab(text: 'Direct Claims',),
      //               ],
      //             ),
      //           ),
      //         ),
      //         Expanded(
      //           child: TabBarView(
      //             children: [
      //               GestureDetector(
      //                 onTap: () { _appSessionCallback.pauseAppSession(); },
      //                   child: _getReimbursementBody()
      //               ),
      //               GestureDetector(
      //                   onTap: () { _appSessionCallback.pauseAppSession(); },
      //                   child: _getGPBody()
      //               ),
      //             ],
      //           ),
      //         ),
      //         Align(
      //           alignment: Alignment.bottomCenter,
      //           child: Column(
      //             children: <Widget>[
      //             //   Container(
      //             //      padding: const EdgeInsets.fromLTRB(40, 5, 40, 10),
      //             //      child: RaisedButton(
      //             //      padding: EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 10),
      //             //      color: mPrimaryColor,
      //             //      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      //             //      child: SizedBox(
      //             //        width: double.infinity,
      //             //        child: Stack(
      //             //          children: <Widget>[
      //             //            Align(
      //             //                alignment: Alignment.center,
      //             //                child: Text('Reimbursement Form', style: TextStyle(fontSize: 18.0, color: Colors.black87))
      //             //            ),
      //             //          ],
      //             //        ),
      //             //      ),
      //             //      onPressed: () {
      //             //        _appSessionCallback.pauseAppSession();
      //             //     Navigator.push(context,
      //             //       MaterialPageRoute(
      //             //           builder: (context) => ReimbursementClaimPage(
      //             //              appSessionCallback: _appSessionCallback,
      //             //           )),
      //             //     );
      //             //      },
      //             //    ),
      //             //  ),
      //              Container(
      //                padding: EdgeInsets.only(bottom: 20),
      //                child: copyRightText(),
      //              )
      //             ]
      //           )
      //         ),
      //       ],
      //     )),
      body: Scrollbar(child: _getReimbursementBody()),
    );
  }

  Widget _getReimbursementBody(){
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
                Visibility(
                  visible: fileClaimVis,
                  child: Align(
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
                                child: Text('Download Claim Form', style: TextStyle(fontSize: 18.0, color: Colors.black87))
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        _appSessionCallback.pauseAppSession();
                        Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => DownloadClaimFormPage(appSessionCallback: _appSessionCallback, member: _member,)),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Visibility(
                  visible: fileClaimVis,
                  child: Align(
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
                                child: Text('File a claim', style: TextStyle(fontSize: 18.0, color: Colors.black87))
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        _appSessionCallback.pauseAppSession();
                        Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => ReimbursementPage(appSessionCallback: _appSessionCallback, member: _member,)),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('Claims Record', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FutureBuilder<List<Claims>>(
                  future: _mReimbursement,
                  builder: (BuildContext context, AsyncSnapshot<List<Claims>> snapshot){
                    if(!snapshot.hasData)
                      return Center(child: myLoadingIcon(height: height * .30, width: width * .25),);
                    else {
                      if(snapshot.data.length > 0)
                        //return Center(child: Text('len: ${snapshot.data.length}'),);
                        return Column(
                          children: _getHistoryRequest(height, snapshot.data),
                        );
                      else return Center(child: Text('No record found.'),);
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

  Widget _getGPBody(){
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
                Align(
                  alignment: Alignment.topLeft,
                  child: Text('Claims Record', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300),),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FutureBuilder<List<Claims>>(
                  future: _mGP,
                  builder: (BuildContext context, AsyncSnapshot<List<Claims>> snapshot){
                    if(!snapshot.hasData)
                      return Center(child: CircularProgressIndicator(),);
                    else {
                      if(snapshot.data.length > 0)
                        //return Center(child: Text('len: ${snapshot.data.length}'),);
                        return Column(
                          children: _getHistoryRequest(height, snapshot.data),
                        );
                      else return Center(child: Text('No record found.'),);
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

  List<Widget> _getHistoryRequest(double height, List<Claims> requests) {

    List<Widget> cards = List<Widget>();

    requests.forEach((request) {
      var cardHeight = height / 4;
      barColor = mPrimaryColor;
      textColor = Colors.black87;
      txtStatus = request.status.toUpperCase();

      _setStatusColor(request);

      var card = Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Container(
          height: cardHeight + 20,
          child: Stack(
            children: <Widget>[
              Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    height: cardHeight - cardHeight * 0.1,
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Patient:  '),
                            Expanded(
                                child: Text(request.patientName == null ? 'N/A' : request?.patientName,
                                  overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end,)
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Provider:  '),
                            Expanded(
                                child: Text(request.hospitalName == null ? 'N/A' : request?.hospitalName,
                                  overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end,)
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Request ID:'),
                            Expanded(
                                child: Text(request.reqId == null ? 'N/A' : request?.reqId,
                                  overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end,)
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text('Request Date:'),
                            Expanded(
                                child: Text(request.dateRequested == null ? 'N/A' : request?.dateRequested.toString(),
                                  overflow: TextOverflow.ellipsis, maxLines: 2, textAlign: TextAlign.end,)
                            ),
                          ],
                        ),
                        // Card(
                        //   elevation: 5.0,
                        //   child: Container(
                        //     height: cardHeight /5.5,
                        //     child: Padding(
                        //       padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        //       child: Stack(
                        //         children: <Widget>[
                        //           Align(
                        //               alignment: Alignment.centerLeft,
                        //               child: Text('** REMARKS' , style: TextStyle(color: Colors.grey)),
                        //               //child: Text( request.dateRequested == null ? '** REMARKS' : 'this is the remarks', style: TextStyle(color: request.dateRequested == null ? Colors.grey : Colors.black),)
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 10,)
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
                    height: cardHeight * 0.3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Stack(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Text(txtStatus, style: TextStyle(fontSize: 15.0, color: textColor))
                          ),
                          Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () async {
                                  _appSessionCallback.pauseAppSession();
                                  Navigator.of(context).push(PageRouteBuilder(
                                      pageBuilder: (context, _, __) => _questionMark(context,request.reqId, request.status), opaque: false));
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
      );


      cards.add(card);
    });

    return cards;
  }


  void _setStatusColor(Claims request) {

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
   else if(request.status.toUpperCase() == 'CLAIMED') {
     barColor = Colors.black87;
     textColor = Colors.white;
     txtStatus = 'CLAIMED';
   }
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
                                                  Text("Cancel Claim Request")
                                                ],
                                              ),
                                              onTap: () async {
                                                showCancelDialog(reqid);
                                              },
                                            ),
                                          )
                                      ),
                                      // Container(
                                      //   color: Colors.black,
                                      //   height: 1,
                                      // ),
                                      // Container(
                                      //     alignment: AlignmentDirectional.topStart,
                                      //     margin: EdgeInsets.fromLTRB(15, 10, 10, 10),
                                      //     child: Material(
                                      //       color: Colors.white,
                                      //       child: InkWell(
                                      //         child: Row(
                                      //           children: <Widget>[
                                      //             Text("View Claim Form")
                                      //           ],
                                      //         ),
                                      //         onTap: () async {
                                      //           _showLoadingDialog();
                                      //           var _base_url = await ApiHelper.getBaseUrl();
                                      //           var _api_user = await ApiHelper.getApiUser();
                                      //           var _api_pass = await ApiHelper.getApiPass();
                                      //
                                      //           String pdfUrl;
                                      //           String msgCode;
                                      //           String msgDescription;
                                      //           String title = 'View Claim Form';
                                      //
                                      //           String url = '${_base_url}GenerateClaimForm?userid=$_api_user&password=$_api_pass&requestID=$reqid';
                                      //           var res = await http.get(url);
                                      //           var json = jsonDecode(jsonDecode(res.body));
                                      //
                                      //           print(json);
                                      //
                                      //           List<Requests> data = [];
                                      //           json.forEach((entity) {
                                      //             data.add(Requests.fromJson(entity));
                                      //             pdfUrl = entity['COBFile'];
                                      //             msgCode = entity['msgCode'];
                                      //             msgDescription = entity['msgDescription'];
                                      //           });
                                      //
                                      //           print(reqid);
                                      //           String urlPDFPath = "";
                                      //
                                      //           getFileFromUrl(pdfUrl, msgDescription).then((f) {
                                      //             if(msgCode == '019'){
                                      //               Navigator.pop(context);
                                      //               showPdfFailedDialog(msgDescription);
                                      //             } else {
                                      //               setState(() {
                                      //                 urlPDFPath = f.path;
                                      //                 print(urlPDFPath);
                                      //                 if(urlPDFPath != null){
                                      //                   Navigator.pop(context);
                                      //                   Navigator.push(
                                      //                       context,
                                      //                       MaterialPageRoute(
                                      //                           builder: (context) =>
                                      //                               ViewClaimPdfPage(title: title, path: urlPDFPath, url: pdfUrl, fileName: reqid, mode: 'Cancel', reqId: reqid, member: widget?.member, cardno: widget?.member.cardno)));
                                      //                 }
                                      //               });
                                      //             }
                                      //           });
                                      //         },
                                      //       ),
                                      //     )
                                      // ),
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
                                                  Text("View Claim Computation")
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
                                                String title = 'View Claim Computation';

                                                String url = '${_base_url}ViewComputationSheet';
                                                var res = await http.post(
                                                    url,
                                                  headers: {
                                                    HttpHeaders.authorizationHeader: 'Bearer $token',
                                                    "UserAccount": _email
                                                  },
                                                  body: {
                                                    "userid" : _api_user,
                                                    "password" : _api_pass,
                                                    "claimNo" : reqid,
                                                  }
                                                );
                                                var json = jsonDecode(jsonDecode(res.body));

                                                print(json);

                                                List<Requests> data = [];
                                                json.forEach((entity) {
                                                  data.add(Requests.fromJson(entity));
                                                  pdfUrl = entity['COBFile'];
                                                  msgCode = entity['msgCode'];
                                                  msgDescription = entity['msgDescription'];
                                                });

                                                print(pdfUrl);
                                                String urlPDFPath = "";

                                                setState((){
                                                  getFileFromUrl(pdfUrl, msgDescription).then((f) {
                                                    if(msgCode == '019'){
                                                      Navigator.pop(context);
                                                      showPdfFailedDialog(msgDescription);
                                                    } else {
                                                      setState(() {
                                                        urlPDFPath = f.path;
                                                        print(urlPDFPath);
                                                        if(urlPDFPath != null){
                                                          Navigator.pop(context);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      ViewClaimPdfPage(title: title, path: urlPDFPath, url: pdfUrl, fileName: reqid, mode: 'Cancel', reqId: reqid, member: widget?.member, cardno: widget?.member.cardno)));
                                                        }
                                                      });
                                                    }
                                                  });
                                                });
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
        )
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

  void showCancelDialog(String reqId){
    Widget yesButton = FlatButton(
      child: Text('YES'),
      onPressed: () {
        Navigator.pop(context);
        cancelClaim(reqId);
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
      content: Text("Are you sure you want to cancel this claim?",textAlign: TextAlign.center),
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
}
