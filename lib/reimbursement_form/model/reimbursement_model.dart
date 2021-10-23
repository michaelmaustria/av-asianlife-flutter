
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/availment.dart';
import 'package:av_asian_life/data_manager/dependent.dart';
import 'package:av_asian_life/data_manager/log_request.dart';
import 'package:av_asian_life/data_manager/log_response.dart';
import 'package:av_asian_life/data_manager/procedure.dart';
import 'package:av_asian_life/data_manager/provider.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssh/ssh.dart';

import '../reimbursement_claim_contract.dart';

class ReimburseModel implements IReimburseModel {

  @override
  Future<LogResponse> postReimbursementRequest(LogRequest request) async {
    List<LogResponse> data = [];
    String file = '';
    List files = [];
    bool isUpLoaded = false;
    if(request.attachments != null) {
      request.attachments.forEach((element) {
        print('element: $element');
        if (element.path != null) {
          file = basename(element.path);
          files.add(file);
          //_uploadImage(element);
        }
      });
    }
    print('Files: $files');
    print('Procedures: ${request.procedures}');

    // var _base_url = await ApiHelper.getBaseUrl();
    // var _api_user = await ApiHelper.getApiUser();
    // var _api_pass = await ApiHelper.getApiPass();

    // String url = '${_base_url}PostLOGRequest?userid=$_api_user&password=$_api_pass&username=${request.username}&cardno_patient=${request.cardNo}&availment_type=${request.availType}&availment_date=${request.availDate}&provider_code=${request.providerCode}&complaint=${request.complaint}&procedures=${request.procedures}&doctors=${request.doctors}&attachment=$files';
    // print('postLogRequest: $url');

    // var res = await http.get(url);
    // try {
    //   var json = jsonDecode(jsonDecode(res.body));
    //   print(json);

    //   json.forEach((entity) {
    //     data.add(LogResponse.fromJson(entity));
    //   });
    // } catch (e) {
    //   print(res.body);
    //   data.add(LogResponse(msgDescription: 'An error has occurred.'));
    // }

    return data[0];

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
              toPath: '/data/LOGRequest',
              callback: (progress) {
                print('Progress: $progress'); // read upload progress
              },
            );

            print('Upload result: $result');
            client?.disconnectSFTP();
          }
          client?.disconnect();
        }
      }
    }on PlatformException catch(e) {
      print(e);
      print('Closing Clients on catch');
      client?.disconnectSFTP();
      client?.disconnect();
    }
  }

  Future<List<Dependent>> getDependentsInfo(String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetDependentsInfo';

    print('getDependentsInfo: $url');
    print(json);
    List<Dependent> data = [];
    print(data.length);

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
          "cardno" : cardNo
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      json.forEach((entity) {
        data.add(Dependent.fromJson(entity));
      });

      if (data[0].cardno != null) {
        print('data');
        print(data[0].cardno);
        print('${data[0].firstName} ${data[0].lastName}');
        return data;
      }
    }catch (e) {
      print('Exception occurred');
      print(e);
      data.add(Dependent(message: 'No Dependent'));
    }

    data.add(Dependent(message: 'No Dependent'));
    return data;
  }

}