import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/availment.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/session_callback.dart';
import 'package:av_asian_life/request_log/presenter/requet_log_presenter.dart';
import 'package:av_asian_life/request_log/request_log_contract.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:av_asian_life/claims/view/view_claim_pdf_page.dart';

class DownloadClaimFormPage extends StatefulWidget {
  IApplicationSession appSessionCallback;
  Member member;

  DownloadClaimFormPage({this.appSessionCallback, this.member});

  @override
  _DownloadClaimFormPageState createState() => _DownloadClaimFormPageState();
}

class _DownloadClaimFormPageState extends State<DownloadClaimFormPage> {

  IRequestLogPresenter _mPresenter = RequestLogPresenter();
  double _width;
  IApplicationSession _appSessionCallback;

  String _selectedAvailment;
  String _availment;
  String _selectedPatient;
  String _patient;
  String _availtype;

  User _mUser;

  Future<List<Dependent>> _mDependent;
  Future<Null> _getUser() async {
    _mUser = await _mPresenter.getUserData();
    print('User: ${_mUser.cardNo}');
  }

  @override
  void initState(){
    super.initState();
    _appSessionCallback = widget.appSessionCallback;
    _getUser().then((_){
    setState(() {
      _mDependent = _mPresenter.initDependentsInfo(_mUser.cardNo);
    });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('Download Claim Form', textAlign: TextAlign.center),
        flexibleSpace: Image(
          image:  AssetImage('assets/images/appBar_background.png'),
          fit: BoxFit.fill,),
        centerTitle: true,
      ),
      body:LayoutBuilder(builder: (context, constraint) {
        final height = constraint.maxHeight;
        final width = constraint.maxWidth;
        _width = constraint.maxWidth;
        return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: <Widget>[
              SizedBox(height:10),
              SizedBox(
              height: height * .06,
              child: RaisedButton(
                elevation: 1.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                onPressed: () { _appSessionCallback.pauseAppSession(); },
                child: _getAvailmentDropdown()
                ),
              ),
              SizedBox(height:10),
              SizedBox(
                height: height * .06,
                child: RaisedButton(
                  elevation: 1.0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  onPressed: () {  },
                  child: FutureBuilder<List<Dependent>>(
                    future: _mDependent,
                    builder: (BuildContext context, AsyncSnapshot<List<Dependent>> snapshot){
                      if(!snapshot.hasData) {
                        print('dependents: ${snapshot.data}');
                        return _dropDownDisabledHolder('Choose Patient Name');
                      }else {
                        print('dependents: ${snapshot.data[0].message}');
                        if(snapshot.data[0].message != 'No Dependent')
                          return _getPatientDropdown(snapshot.data, true);
                        else
                          return _getPatientDropdown(snapshot.data, false);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height:10),
              RaisedButton(
                  padding: EdgeInsets.all(12),
                  color: mPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: Container(
                      alignment: Alignment.center,
                      width: width * .5,
                      child: Text('Submit', style: TextStyle(color: Colors.black))
                  ),
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    var errMsg = '';
                    var _userid = '';

                    dynamic data;

                    String _data;
                    String urlPDFPath = "";

                    dynamic datalist = [];

                    _userid = prefs.getString('_username');

                    if(_availment == 'OUTPATIENT'){
                      _availtype = '1';
                    } else {
                      _availtype = '2';
                    }

                    if((_selectedPatient == null) || (_selectedPatient == '')||(_availment == '')||(_availment == null)){

                      if((_selectedPatient == null) || (_selectedPatient == ''))
                        errMsg += '\nPlease select a patient';

                      if((_availment == '')||(_availment == null))
                        errMsg += '\nPlease select type of availment';

                      showMessageDialog(context, errMsg);
                    } else {
                      _showLoadingDialog(context);
                      var _email = prefs.getString('_email');
                      var _base_url = await ApiHelper.getBaseUrl();
                      var _api_user = await ApiHelper.getApiUser();
                      var _api_pass = await ApiHelper.getApiPass();
                      var token = await ApiToken.getApiToken();

                      String pdfUrl;
                      String msgCode;
                      String msgDescription;
                      String title = 'Download Claim Form';

                      var response = await http.post(
                          Uri.encodeFull('${_base_url}DownLoadClaimForm'),
                          headers: {
                            HttpHeaders.authorizationHeader: 'Bearer $token',
                            "UserAccount": _email
                          },
                          body: {
                            "userid" : _api_user,
                            "password" : _api_pass,
                            "availtype" : _availtype,
                            "cardno" : _patient,
                            "appuserid" : _userid
                          }
                      );

                      data = jsonDecode(response.body);
                      _data = data;
                      setState((){
                        datalist = jsonDecode(_data);
                        pdfUrl = datalist['ClaimForm'];
                        msgCode = datalist['msgCode'];
                        msgDescription = datalist['msgDescription'];
                      });

                      if (msgCode == '002'){
                        Navigator.pop(context);
                        showPdfFailedDialog(msgDescription);
                      } else {
                        setState((){
                          getFileFromUrl(pdfUrl, msgDescription).then((f) {
                            urlPDFPath = f.path;
                            print(urlPDFPath);
                            if(urlPDFPath != null){
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ViewClaimPdfPage(title: 'Download Claim Form' ,path: urlPDFPath, url: pdfUrl, fileName: widget?.member.cardno, cardno: _patient, member: widget?.member)));
                            }
                          });
                        });
                      }
                    }
                  }
              ),
              Container(
                height: MediaQuery.of(context).size.height * .65,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: copyRightText()
                    )
                ),
              ),
            ]
          )
        );
      }
    ));
  }

  Widget _dropDownDisabledHolder(String text) {
    return SizedBox(
        width: double.infinity,
        child: Text(text, textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.grey),)
    );
  }

  Widget _getAvailmentDropdown(){
    List<String> dropDownItems = ['INPATIENT','OUTPATIENT'];

    final Widget button = SizedBox(
      width: _width,
      height: 40,
      child: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: Stack(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(_availment == null ? 'Type of Availment' :'$_availment', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 16.5)
                  ),
                )
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Container(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,)
                )
            )
          ],
        ),
      ),
    );


    return MenuButton(
      child: button,
      items: dropDownItems,
      topDivider: true,
      crossTheEdge: true,
      scrollPhysics: AlwaysScrollableScrollPhysics(),
      dontShowTheSameItemSelected: false,
      // Use edge margin when you want the menu button don't touch in the edges
      edgeMargin: 30,
      itemBuilder: (value) => Container(
        height: 40,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(left: 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
              ),
            )
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
      onItemSelected: (newValue) {
        setState(() {
          _availment = newValue;
          print(_availment);
        });
        _appSessionCallback.pauseAppSession();
      },
      decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: const BorderRadius.all(
            Radius.circular(3.0),
          ),
          color: Colors.white),
      onMenuButtonToggle: (isToggle) {
        print(isToggle);
      },
    );
  }

  Widget _getPatientDropdown(List<Dependent> dependents, bool hasDependent){
    List<String> dropDownItems = [];
    dropDownItems.add('${widget.member.firstName} ${widget.member.lastName}');
    if(hasDependent) {
      dependents.forEach((dep) {
        String name = '${dep.firstName} ${dep.lastName}';
        dropDownItems.add((name));
      });
    }
    final Widget button = SizedBox(
      width: _width,
      height: 40,
      child: Padding(
        padding: const EdgeInsets.only(right: 0),
        child: Stack(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(_selectedPatient == null ? 'Choose patient name' :'$_selectedPatient', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54, fontSize: 16.5)
                  ),
                )
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Container(
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black,)
                )
            )
          ],
        ),
      ),
    );


    return MenuButton(
      child: button,
      items: dropDownItems,
      topDivider: true,
      crossTheEdge: true,
      scrollPhysics: AlwaysScrollableScrollPhysics(),
      dontShowTheSameItemSelected: false,
      // Use edge margin when you want the menu button don't touch in the edges
      edgeMargin: 30,
      itemBuilder: (value) => Container(
        height: 40,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(left: 10),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)
              ),
            )
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
      onItemSelected: (newValue) {
        setState(() {
          _selectedPatient = newValue;
          String member = '${widget.member.firstName} ${widget.member.lastName}';

          if (_selectedPatient == member){
            _patient = widget?.member.cardno;
            print(_patient);
          } else {
            dependents.forEach((prov) {
              String name = '${prov.firstName} ${prov.lastName}';
              if(name == _selectedPatient){
                _patient = prov.cardno;
                print(_patient);
              }
            });
          }
        });
        _appSessionCallback.pauseAppSession();
      },
      decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: const BorderRadius.all(
            Radius.circular(3.0),
          ),
          color: Colors.white),
      onMenuButtonToggle: (isToggle) {
        print(isToggle);
      },
    );
  }

  void showMessageDialog(BuildContext context, String errMsg){
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: new Text(""),
          content: new Text(errMsg,textAlign: TextAlign.center),
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

  Future<File> getFileFromUrl(String url, String msgDescription) async {
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
      showPdfFailedDialog(msgDescription);
      throw Exception("Error opening url file");
    }
  }

  void _showLoadingDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog _loadingDialog;
    _loadingDialog = AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
      contentPadding: EdgeInsets.all(0.0),
      content: myLoadingIcon(height: 125, width: 20),
    );

    // show the dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _loadingDialog;
      },
    );

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

}
