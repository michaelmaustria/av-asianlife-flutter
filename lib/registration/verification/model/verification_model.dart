
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/resend_code_response.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/registration/verification/verification_contract.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerificationModel implements IVerificationModel {

  @override
  Future<SignUpResponse> postVerificationRequest(VerificationRequest request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('send code P: ${request.sendcodethru}');
    print('postVerificationRequest');

    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}SendVerificationCode';
    print(url);
    List<SignUpResponse> data = [];

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
          "username" : prefs.getString('_username'),
          "sendcodethru" : request.sendcodethru,
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);
      json.forEach((entity) {
        data.add(SignUpResponse.fromJson(entity));
      });

    }catch (e){
      print(e);
      print('HTTP Exception');
      return SignUpResponse(message: 'Connection Error Occurred.');
    }

    return data[0];
  }


  @override
  Future<ResendCodeResponse> postResendCode(String username) async {
    print('postResendVerificationRequest');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}ResendCode';
    print(url);

    List<ResendCodeResponse> data = [];

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
          "username" : username,
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);
      json.forEach((entity) {
        data.add(ResendCodeResponse.fromJson(entity));
      });

    }catch (e){
      print(e);
      print('HTTP Exception');
      return ResendCodeResponse(message: 'Connection Error Occurred.');
    }

    return data[0];
  }

  @override
  Future<SignUpResponse> postAccountVerification(VerificationRequest request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}VerifyAccount';
    print(url);

    List<SignUpResponse> data = [];

    try {
      var res = await http.post(
          url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          "UserAccount": _email
        },
        body : {
          "userid" : _api_user,
          "password" : _api_pass,
          "username" : prefs.getString('_username'),
          "verificationcode" : request.code
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);
      json.forEach((entity) {
        data.add(SignUpResponse.fromJson(entity));
      });

    }catch (e){
      print(e);
      print('HTTP Exception');
      return SignUpResponse(message: 'Connection Error Occurred.');
    }

    return data[0];
  }


}
