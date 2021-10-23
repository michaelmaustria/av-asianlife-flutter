
import 'dart:convert';
import 'dart:io';

import 'package:av_asian_life/data_manager/api_token.dart';
import 'package:av_asian_life/data_manager/requests.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../letter_of_guarantee_contract.dart';
import 'package:av_asian_life/request_log/view/request_log_page.dart';

class LetterOfGuaranteeModel implements ILetterOfGuaranteeModel{

  @override
  Future<List<Requests>> getLogHistory(User user, String availType) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _email = prefs.getString('_email');
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();
    var token = await ApiToken.getApiToken();

    String url = '${_base_url}GetLOGRequests';
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
        "availtype" : availType
      }
    );
    var json = jsonDecode(jsonDecode(res.body));

    List<Requests> data = [];
    json.forEach((entity) {
      data.add(Requests.fromJson(entity));
    });

    print('getLogHistory: Done');
    return data;
  }
}