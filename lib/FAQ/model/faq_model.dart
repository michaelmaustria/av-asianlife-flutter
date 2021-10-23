
import 'dart:convert';

import 'package:av_asian_life/data_manager/faq.dart';
import 'package:av_asian_life/data_manager/user.dart';
import 'package:av_asian_life/utility/api_helper.dart';
import 'package:http/http.dart' as http;

import '../faq_contract.dart';

class FaqModel implements IFaqModel{
  @override
  Future<List<Faq>> getFaq() async {
    var _base_url = await ApiHelper.getBaseUrl();
    var _api_user = await ApiHelper.getApiUser();
    var _api_pass = await ApiHelper.getApiPass();

    String url = '${_base_url}GetFAQs?userid=$_api_user&password=$_api_pass';
    var res = await http.get(url);
    var json = jsonDecode(jsonDecode(res.body));

    List<Faq> data = [];
    json.forEach((entity) {
      data.add(Faq.fromJson(entity));
    });
    return data;
  }

}