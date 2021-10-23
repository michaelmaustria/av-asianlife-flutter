
import 'dart:convert';

import 'package:av_asian_life/data_manager/faq.dart';
import 'package:av_asian_life/data_manager/rate_request.dart';
import 'package:av_asian_life/data_manager/rate_response.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:http/http.dart' as http;

import '../rating_contract.dart';

class RateModel implements IRateModel{

   @override
  Future<RateResponse> postRate(RateRequest request) async {
    List<RateResponse> data = [];

    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();

    String url = '${_base_url}PostLOGRequest?userid=$_api_user';
    print('postLogRequest: $url');

    var res = await http.get(url);
    try {
      var json = jsonDecode(jsonDecode(res.body));
      print(json);

      json.forEach((entity) {
        data.add(RateResponse.fromJson(entity));
      });
    } catch (e) {
      print(res.body);
      data.add(RateResponse(msgDescription: 'An error has occurred.'));
    }

    return data[0];

  }

}