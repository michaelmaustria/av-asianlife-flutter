
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/choose_where_to_send_code_response.dart';
import 'package:av_asian_life/data_manager/forgot_password_response.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/data_manager/verification_request.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../forgot_password_contract.dart';

class ForgotPasswordModel implements IForgotPasswordModel {

  @override
  Future<ForgotPasswordResponse> postForgotPasswordRequest(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    await ApiToken.requestInitApiToken();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}ForgotPassword';
    print(url);

    List<ForgotPasswordResponse> data = [];

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
          "username_or_email" : username
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);
      json.forEach((entity) {
        data.add(ForgotPasswordResponse.fromJson(entity));
      });

    }catch (e){
      print(e);
      print('HTTP Exception');
      return ForgotPasswordResponse(message: 'Connection Error Occurred.');
    }

    return data[0];
  }


  @override
  Future<ChooseWhereToSendCodeResponse> postChooseWhereToSendCode(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}ChooseWhereToSendCode';
    print(url);

    List<ChooseWhereToSendCodeResponse> data = [];

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
        data.add(ChooseWhereToSendCodeResponse.fromJson(entity));
      });

    }catch (e){
      print(e);
      print('HTTP Exception');
      return ChooseWhereToSendCodeResponse(message: 'Connection Error Occurred.');
    }

    return data[0];
  }


  @override
  Future<ForgotPasswordResponse> postResendCode(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}ResendCode';
    print(url);

    List<ForgotPasswordResponse> data = [];

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
          "username" : username
        }
      );
      var json = jsonDecode(jsonDecode(res.body));
      print(json);
      json.forEach((entity) {
        data.add(ForgotPasswordResponse.fromJson(entity));
      });

    }catch (e){
      print(e);
      print('HTTP Exception');
      return ForgotPasswordResponse(message: 'Connection Error Occurred.');
    }

    return data[0];
  }

  @override
  Future<SignUpResponse> postVerificationRequest(VerificationRequest request) async {
    print('send code P: ${request.sendcodethru}');
    print('postVerificationRequest');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}SendVerificationCode';

    print(url);
    print(request.cardNo);

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
          "username" : request.cardNo,
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
          "username" : request.cardNo,
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

  @override
  Future<SignUpResponse> postResetPassword(String password, String cardNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _otp = prefs.getString('otp');
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}ResetPassword';
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
          "userid": _api_user,
          "password": _api_pass,
          "username": cardNo,
          "newpassword": password,
          "otp": _otp,
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