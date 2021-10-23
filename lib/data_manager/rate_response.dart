// To parse this JSON data, do
//
//     final logResponse = logResponseFromJson(jsonString);

import 'dart:convert';

List<RateResponse> logResponseFromJson(String str) => List<RateResponse>.from(json.decode(str).map((x) => RateResponse.fromJson(x)));

String logResponseToJson(List<RateResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RateResponse {
  String msgCode;
  String msgDescription;
  String message;

  RateResponse({
    this.msgCode,
    this.msgDescription,
    this.message,
  });

  factory RateResponse.fromJson(Map<String, dynamic> json) => RateResponse(
    msgCode: json["msgCode"] == null ? null : json["msgCode"],
    msgDescription: json["msgDescription"] == null ? null : json["msgDescription"],
    message: json["Message"] == null ? null : json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "msgCode": msgCode == null ? null : msgCode,
    "msgDescription": msgDescription == null ? null : msgDescription,
    "Message": message == null ? null : message,
  };
}
