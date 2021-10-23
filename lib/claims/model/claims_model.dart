
import 'dart:convert';

import 'package:av_asian_life/claims/view/view_claim_pdf_page.dart';
import 'package:av_asian_life/colors/decoration_pallete.dart';
import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/claim_response.dart';
import 'package:av_asian_life/data_manager/claims.dart';
import 'package:av_asian_life/data_manager/claims_request.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/home_page/home_page.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';

import 'package:path/path.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh/ssh.dart';

import 'package:http/http.dart' as http;

import '../claims_contract.dart';

class ClaimsModel implements IClaimsModel {

  @override
  Future<List<Claims>> getClaimsHistory(User user, String claimType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();


    String url = '${_base_url}GetClaims';

    var res = await http.post(
        url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user,
        "password" : _api_pass,
        "cardno" : user.cardNo,
        "claimtype" : "3",
      }
    );
    var json = jsonDecode(jsonDecode(res.body));

    List<Claims> data = [];
    json.forEach((entity) {
      data.add(Claims.fromJson(entity));
    });

    print('getClaimsHistory: Done');
    return data;
  }

  @override
  Future<ClaimResponse> postClaimRequest(ClaimRequest request, BuildContext context, Member member) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    String file = '';
    String claimForm = '';
    String _data;
    String _message;
    String _reqid;

    List files = [];
    List claimForms = [];
    List msg = [];
    List msgs = [];

    dynamic data = [];

    print(request.attachments);
    if(request.attachments != null) {
      request.attachments.forEach((element) {
        print('element: $element');
        if (element.path != null) {
          file = basename(element.path);
          files.add(file);
          _uploadImage(element);
        }
      });
    }

    print(request.claimForm);
    if(request.claimForm != null) {
      request.claimForm.forEach((element) {
        print('element: $element');
        if (element.path != null) {
          claimForm = basename(element.path);
          claimForms.add(claimForm);
          _uploadClaimForm(element);
        }
      });
    }

    print('Files: $files');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    var response = await http.post(
        Uri.encodeFull('${_base_url}PostOnlineClaimOP'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body : {
        "userid" : _api_user.toString(),
        "password" : _api_pass.toString(),
        "cardno" : request.cardNo.toString(),
        "claimamount" : request.claimAmount.toString(),
        "availmentdate" : request.availmentDate.toString(),
        "complaints" : request.complaints.toString(),
        "remarksconsult" : request.remarksConsult.toString(),
        "remarkslab" : request.remarksLab.toString(),
        "remarksmed" : request.remarksMed.toString(),
        "diagnosis" : request.diagnosis.toString(),
        "fundtransfer" : request.fundTransfer.toString(),
        "bnkcode" : request.bnkCode.toString(),
        "acctno" : request.acctNo.toString(),
        "acctname" : request.acctName.toString(),
        "acctaddress" : request.acctAddress.toString(),
        "appuserid" : request.appUserId.toString(),
        "hospcode" : request.hospCode.toString(),
        "othhosp" : request.otherHosp.toString(),
        "hospdocStatement" : "".toString(),
        "chargeslip" : "".toString(),
        "receipt" : files.toString(),
        "amountlab" : request?.amountLab.toString(),
        "amountmed" : request?.amountMed.toString(),
        "claimform" : request.claimForm.toString()
      }
    );
    data = json.decode(response.body);
    _data = data;
    msg = json.decode(_data);
    for(var i = 0; i < msg.length; i++){
      msgs.add(msg[i]["msgDescription"]);
    }
    _reqid = msg[0]["requestID"];

    if(_data == '{"Message":"An error has occurred."}'){
      _message = msg[0]['Message'];
    } else {
      _message = msg[0]['msgDescription'];
    }

    showMessageDialog(member.cardno, _reqid, _message, context, member);
  }

  @override
  Future<ClaimResponse> postClaimIpRequest(ClaimRequest request, BuildContext context, Member member) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    String _data;
    String _message;
    String _reqid;

    String _statement = '';
    String _slip = '';
    String _receipt = '';
    String _claimForm = '';

    List statements = [];
    List slips = [];
    List receipts = [];
    List claimForms = [];

    List msg = [];
    List msgs = [];

    dynamic data = [];

    print(request.doctorStatementList);
    print(request.chargeSlipList);
    print(request.officialReceiptList);

    if(request.doctorStatementList != null) {
      request.doctorStatementList.forEach((element) {
        print('element: $element');
        if (element.path != null) {
          _statement = basename(element.path);
          statements.add(_statement);
          _uploadDoctorStatement(element);
        }
      });
    }

    if(request.chargeSlipList != null) {
      request.chargeSlipList.forEach((element) {
        print('element: $element');
        if (element.path != null) {
          _slip = basename(element.path);
          slips.add(_slip);
          _uploadSlips(element);
        }
      });
    }

    if(request.officialReceiptList != null) {
      request.officialReceiptList.forEach((element) {
        print('element: $element');
        if (element.path != null) {
          _receipt = basename(element.path);
          receipts.add(_receipt);
          _uploadReceipt(element);
        }
      });
    }

    if(request.claimForm != null) {
      request.claimForm.forEach((element) {
        print('element: $element');
        if (element.path != null) {
          _claimForm = basename(element.path);
          claimForms.add(_claimForm);
          _uploadClaimForm(element);
        }
      });
    }

    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    var response = await http.post(
        Uri.encodeFull('${_base_url}PostOnlineClaimIP'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        "UserAccount": _email
      },
      body: {
        "userid" : _api_user.toString(),
        "password" : _api_pass.toString(),
        "cardno" : request.cardNo.toString(),
        "claimamount" : request.claimAmount.toString(),
        "availmentdate" : request.availmentDate.toString(),
        "complaints" : "".toString(),
        "remarksconsult" : "".toString(),
        "remarkslab" : "".toString(),
        "remarksmed" : "".toString(),
        "diagnosis" : request.diagnosis.toString(),
        "fundtransfer" : request.fundTransfer.toString(),
        "bnkcode" : request.bnkCode.toString(),
        "acctno" : request.acctNo.toString(),
        "acctname" : request.acctName.toString(),
        "acctaddress" : request.acctAddress.toString(),
        "appuserid" : request.appUserId.toString(),
        "residewithinsured" : request.resideWithEnsured.toString(),
        "isemployeed" : request.isEmployed.toString(),
        "patientemployer" : request.employer.toString(),
        "patientdesignation" : request.patientDesignation.toString(),
        "symptomnoticed" : request.symptomNoticed.toString(),
        "consulteddoc" : request.consultedDoc.toString(),
        "consulteddocdate" : request.consultedDocDate.toString(),
        "findings" : request.findings.toString(),
        "physicianname" : request.physicianName.toString(),
        "physicianaddress" : request.physicianAddress.toString(),
        "duetoinjury" : request.dueToInjury.toString(),
        "whenwherehappened" : request.whenWhereHappened.toString(),
        "doingwhenhappened" : request.injuryWhatHappened.toString(),
        "statehowhappened" : request.injuryHowHappened.toString(),
        "withotherinsurance" : request.withOtherInsurance.toString(),
        "otherinsurance" : request.insuranceCompany.toString(),
        "hospcode" : request.hospCode.toString(),
        "attendingphysician" : request.attendingPhysician.toString(),
        "otherhosp" : request.otherHosp.toString(),
        "hospdocStatement" : statements.toString(),
        "chargeslip" : slips.toString(),
        "receipt" : receipts.toString(),
        "washospitalized" : request.insuredHospitalized.toString(),
        "claimform" : request.claimForm.toString()
      }
    );

    data = json.decode(response.body);
    _data = data;
    msg = json.decode(_data);
    for(var i = 0; i < msg.length; i++){
      msgs.add(msg[i]["msgDescription"]);
    }
    _reqid = msg[0]["requestID"];

    if(_data == '{"Message":"An error has occurred."}'){
      _message = msg[0]['Message'];
    } else {
      _message = msg[0]['msgDescription'];
    }


    showMessageDialog(member.cardno, _reqid, _message, context, member);
  }

  void _uploadImage(File document) async {
    var result;
    SSHClient client;
    try{

      var host = await ApiHelper.getSFTPHost();
      var port = await ApiHelper.getSFTPPort();
      var user = await ApiHelper.getSFTPUser();
      var pass = await ApiHelper.getSFTPPass();

      if(document != null) {
        client = new SSHClient(
          host: host,
          port: port,
          username: user,
          passwordOrKey: pass,
        );

        var clientResult = await client.connect();

        if (clientResult == 'session_connected') {
          var sftpResult = await client.connectSFTP();

          if(sftpResult == 'sftp_connected') {

            result = await client.sftpUpload(
              path: document.path,
              toPath: '/data/Claims/Receipt',
              callback: (progress) {
                print('Progress: $progress'); // read upload progress
              },
            );

            print('Upload result: $result');
            await client?.disconnectSFTP();
          }
          await client?.disconnect();
        }
      }
    }on PlatformException catch(e) {
      print(e);
      print('Closing Clients on catch');
      await client?.disconnectSFTP();
      await client?.disconnect();
    }
  }

  void _uploadClaimForm(File document) async {
    var result;
    SSHClient client;
    try{

      var host = await ApiHelper.getSFTPHost();
      var port = await ApiHelper.getSFTPPort();
      var user = await ApiHelper.getSFTPUser();
      var pass = await ApiHelper.getSFTPPass();

      if(document != null) {
        client = new SSHClient(
          host: host,
          port: port,
          username: user,
          passwordOrKey: pass,
        );

        var clientResult = await client.connect();

        if (clientResult == 'session_connected') {
          var sftpResult = await client.connectSFTP();

          if(sftpResult == 'sftp_connected') {

            result = await client.sftpUpload(
              path: document.path,
              toPath: '/data/Claims/ClaimForm',
              callback: (progress) {
                print('Progress: $progress'); // read upload progress
              },
            );

            print('Upload result: $result');
            await client?.disconnectSFTP();
          }
          await client?.disconnect();
        }
      }
    }on PlatformException catch(e) {
      print(e);
      print('Closing Clients on catch');
      await client?.disconnectSFTP();
      await client?.disconnect();
    }
  }

  void _uploadDoctorStatement(File document) async {
    var result;
    SSHClient client;
    try{

      var host = await ApiHelper.getSFTPHost();
      var port = await ApiHelper.getSFTPPort();
      var user = await ApiHelper.getSFTPUser();
      var pass = await ApiHelper.getSFTPPass();

      if(document != null) {
        client = new SSHClient(
          host: host,
          port: port,
          username: user,
          passwordOrKey: pass,
        );

        var clientResult = await client.connect();

        if (clientResult == 'session_connected') {
          var sftpResult = await client.connectSFTP();

          if(sftpResult == 'sftp_connected') {

            result = await client.sftpUpload(
              path: document.path,
              toPath: '/data/Claims/DoctorStatement',
              callback: (progress) {
                print('Progress: $progress'); // read upload progress
              },
            );

            print('Upload result: $result');
            await client?.disconnectSFTP();
          }
          await client?.disconnect();
        }
      }
    }on PlatformException catch(e) {
      print(e);
      print('Closing Clients on catch');
      await client?.disconnectSFTP();
      await client?.disconnect();
    }
  }

  void _uploadSlips(File document) async {
    var result;
    SSHClient client;
    try{

      var host = await ApiHelper.getSFTPHost();
      var port = await ApiHelper.getSFTPPort();
      var user = await ApiHelper.getSFTPUser();
      var pass = await ApiHelper.getSFTPPass();

      if(document != null) {
        client = new SSHClient(
          host: host,
          port: port,
          username: user,
          passwordOrKey: pass,
        );

        var clientResult = await client.connect();

        if (clientResult == 'session_connected') {
          var sftpResult = await client.connectSFTP();

          if(sftpResult == 'sftp_connected') {

            result = await client.sftpUpload(
              path: document.path,
              toPath: '/data/Claims/Slips',
              callback: (progress) {
                print('Progress: $progress'); // read upload progress
              },
            );

            print('Upload result: $result');
            await client?.disconnectSFTP();
          }
          await client?.disconnect();
        }
      }
    }on PlatformException catch(e) {
      print(e);
      print('Closing Clients on catch');
      await client?.disconnectSFTP();
      await client?.disconnect();
    }
  }

  void _uploadReceipt(File document) async {
    var result;
    SSHClient client;
    try{

      var host = await ApiHelper.getSFTPHost();
      var port = await ApiHelper.getSFTPPort();
      var user = await ApiHelper.getSFTPUser();
      var pass = await ApiHelper.getSFTPPass();

      if(document != null) {
        client = new SSHClient(
          host: host,
          port: port,
          username: user,
          passwordOrKey: pass,
        );

        var clientResult = await client.connect();

        if (clientResult == 'session_connected') {
          var sftpResult = await client.connectSFTP();

          if(sftpResult == 'sftp_connected') {

            result = await client.sftpUpload(
              path: document.path,
              toPath: '/data/Claims/Receipt',
              callback: (progress) {
                print('Progress: $progress'); // read upload progress
              },
            );

            print('Upload result: $result');
            await client?.disconnectSFTP();
          }
          await client?.disconnect();
        }
      }
    }on PlatformException catch(e) {
      print(e);
      print('Closing Clients on catch');
      await client?.disconnectSFTP();
      await client?.disconnect();
    }
  }

  void showMessageDialog(String cardno, String reqid, String message, BuildContext context, Member member){
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => new AlertDialog(
          title: new Text(""),
          content: new Text(message,textAlign: TextAlign.center),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                navigateToHomePage(cardno, context);
                // _showLoadingDialog(context);
                // var _base_url = await ApiHelper.getBaseUrl();
                // var _api_user = await ApiHelper.getApiUser();
                // var _api_pass = await ApiHelper.getApiPass();
                //
                // String pdfUrl;
                // String msgCode;
                // String title = 'View Claim Form';
                //
                // String url = '${_base_url}GenerateClaimForm?userid=$_api_user&password=$_api_pass&requestID=$reqid';
                // var res = await http.get(url);
                // var json = jsonDecode(jsonDecode(res.body));
                //
                // List<Requests> data = [];
                // json.forEach((entity) {
                //   data.add(Requests.fromJson(entity));
                //   pdfUrl = entity['COBFile'];
                //   msgCode = entity['msgCode'];
                // });
                //
                // print(reqid);
                // String urlPDFPath = "";
                //
                //
                //   getFileFromUrl(pdfUrl).then((f) {
                //     urlPDFPath = f.path;
                //     print(urlPDFPath);
                //     if(urlPDFPath != null){
                //       Navigator.pop(context);
                //       Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //               builder: (context) =>
                //                   ViewClaimPdfPage(title: title ,path: urlPDFPath, url: pdfUrl, fileName: reqid, mode: 'Delete', reqId: reqid, cardno: cardno, member: member,)));
                //     }
                //   });
              },
            )
          ],
        ));
  }

  Future<File> getFileFromUrl(String url) async {
    try {
      var data = await http.get(url);
      var bytes = data.bodyBytes;
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/mypdfonline.pdf");

      File urlFile = await file.writeAsBytes(bytes);
      return urlFile;
    } catch (e) {
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

  Future<Member> navigateToHomePage(String cardNo, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var baseUrl = await ApiHelper.getBaseUrl();
    var apiUser = await ApiHelper.getApiUser();
    var apiPass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();

    Member _mMember;

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
}