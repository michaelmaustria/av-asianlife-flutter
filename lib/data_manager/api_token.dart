
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/utility/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ApiToken{

  static Future<String> getApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String _token;

    _token = prefs.getString('token');

    return _token;
  }

  static Future<String> requestInitApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic data;

    var _token;
    var user = await ApiHelper.getAPITokenUser();
    var pass = await ApiHelper.getAPITokenPass();

    String url = 'https://etiqa.com.ph/SmilePH/token';
    await http.post(
        url,
        body: {
          "grant_type": "password",
          "username" : user,
          "password" : pass
        }
    ).then((response){
      data = jsonDecode(response.body);
      _token = data['access_token'];
      prefs.setString('token', _token);
    });
  }

  static Future<String> requestApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic data;
    String _token;

    var email = prefs.getString('_email');
    var password = prefs.getString('_password');

    print(email);
    print(password);

    String url = 'https://etiqa.com.ph/SmilePH/token';
    try{
      await http.post(
          url,
          body: {
            "grant_type": "password",
            "username" : email,
            "password" : password.replaceAll('&', '%26')
          }
      ).then((response){
        data = jsonDecode(response.body);
        _token = data['access_token'];
        prefs.setString('token', _token);
      });
    }catch(e){
      print('API Token credentials not yet registered.');
      prefs.remove('token');
    }
  }

  static Future<String> registerApiToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _base_url = await ApiHelper.getBaseUrl();
    dynamic data;

    print('Register API Token');
    var email = prefs.getString('_email');
    var password = prefs.getString('_password');

    print(email);
    print(password);

    String url = '${_base_url}Account/Register';

    try{
      await http.post(
          url,
          body: {
            "Email": email,
            "Password": password.replaceAll('&', '%26'),
            "ConfirmPassword": password.replaceAll('&', '%26')
          }
      ).then((response){
        data = jsonDecode(response.body);
        print(data);
      });
    }catch(e){
      print(e);
    }
  }

  static Future<String> changePasswordApiToken(String oldpassword, String newpassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dynamic data;

    var token = await getApiToken();

    print('Change API token password');

    String url = 'https://etiqa.com.ph/SmilePH/api/Account/ChangePassword';

    try{
      await http.post(
          url,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token'
          },
          body:
          {
            "OldPassword": oldpassword.replaceAll('&', '%26'),
            "NewPassword": newpassword.replaceAll('&', '%26'),
            "ConfirmPassword": newpassword.replaceAll('&', '%26')
          }
      ).then((response){
        data = jsonDecode(response.body);
        print(data);
      });
      prefs.setString('_password',newpassword.replaceAll('&', '%26'));
    }catch(e){
      print(e);
    }
  }
}