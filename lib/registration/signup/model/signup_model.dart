
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/signup_request.dart';
import 'package:av_asian_life/data_manager/signup_response.dart';
import 'package:av_asian_life/registration/signup/signup_contract.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:imei_plugin/imei_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpModel implements ISignUpModel {

  @override
  Future<SignUpResponse> postSignUpRequest(SignUpRequest request) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('postSignUpRequest');

    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    await ApiToken.requestInitApiToken();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}SignUpCardNo';

    print(url);
    List<SignUpResponse> data = [];

      try {
        var res = await http.post(
            url,
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
            "UserAccount": _email,
          },
          body: {
            "userid":_api_user,
            "password":_api_pass,
            "cardno":request.cardNo,
            "birthday":request.birthday,
            "email":request.email,
            "mobileno":request.mobileNo,
            "username":request.username,
            "userpassword":request.userPassword.replaceAll('&', '%26'),
            "newsletter":request.newsletter.toString(),
            "deviceid":request.deviceId
          }
        );
        var json = jsonDecode(jsonDecode(res.body));
        print("Signup Response: $json");
        json.forEach((entity) {
          data.add(SignUpResponse.fromJson(entity));
        });
        await ApiToken.registerApiToken();
        return data[0];
      } on Exception catch (e) {
        print(e);
        return SignUpResponse(message: 'Connection Error Occured.');
      }


  }
}