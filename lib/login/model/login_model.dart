
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/login_response.dart';
import 'package:av_asian_life/data_manager/member.dart';
import 'package:av_asian_life/data_manager/principal_info.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../login_contract.dart';

class LoginModel implements ILoginModel {
  static String errorMessage;
  @override
  Future<LoginResponse> sendLoginRequest(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userid = await ApiHelper.getAPITokenUser();
    print('sendLoginRequest');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    await ApiToken.requestInitApiToken();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();

    var _cardno;
    var _email;
    print('validatelogin $token');

    String url = '${_base_url}ValidateLogin';
    List<LoginResponse> data = [];
    print(url);

    try {
      var res = await http.post(
          url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": userid,
          "DeviceID": _deviceId
        },
        body: {
          "api_userid": _api_user,
          "api_password": _api_pass,
          "app_userid": user.username,
          "app_password": user.password.replaceAll('&', '%26')
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);

      json.forEach((entity) {
        data.add(LoginResponse.fromJson(entity));

        _cardno = entity['cardno'];
        _email = entity['email'];
        print('email: $_email');
        errorMessage = entity['msgDescription'];

        prefs.setString('_Cardno', _cardno);
        prefs.setString('_email', _email);

      });

      return data[0];
    }catch (e){
      print(e);
      print('Server Error Occurred.');
      return LoginResponse(message: 'Connection Error Occured');
    }
  }

  @override
  Future LogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    print('LogOutToken');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    print('logout $token');

    String url = '${_base_url}LogOut';
    print(url);
    List data = [];

    try {
      var res = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email,
        },
        body: {
          "api_userid" : _api_user,
          "api_password" : _api_pass,
          "app_userid" : _email
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);
      return data[0];
    }catch (e){
      print(e);
      print('Server Error Occurred.');
      return LoginResponse(message: 'Connection Error Occured');
    }
  }


  @override
  Future<Member> getMemberInfo(String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    String mobileno;
    String email;
    print('getMemberInfo');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    await ApiToken.requestApiToken();
    var token = await ApiToken.getApiToken();
    String _deviceId = await ImeiPlugin.getImei();
    print('getmembertoken $token');

    String url = '${_base_url}MemberInfo';

    List<Member> data = [];
    try {
      var res = await http.post(
          url,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            "UserAccount": _email,
            "DeviceID": _deviceId
          },
          body : {
            "userid" : _api_user,
            "password" : _api_pass,
            "cardno" : cardNo,
            "frommain" : "1"
          }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);

      json.forEach((entity) {
        data.add(Member.fromJson(entity));
        mobileno = entity['mobileno'].toString();
        email = entity['email'].toString();
      });
      prefs.setString('_email',email);
      prefs.setString('_mobileno',mobileno);
      return data[0];
    }catch (e) {
      print(e);
      print('Server Error Occurred.');
      return Member(message: 'Connection Error Occured');
    }
  }

  Future<List<PrincipalInfo>> getPrincipalInfo(String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    print('getPrincipalInfo');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetPrincipalInfo';

    List<PrincipalInfo> data = [];
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
    print(json);

    json.forEach((entity) {
      data.add(PrincipalInfo.fromJson(entity));
    });
    return data;
  }

}