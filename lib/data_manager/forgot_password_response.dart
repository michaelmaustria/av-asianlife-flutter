// To parse this JSON data, do
//
//     final forgotPasswordResponse = forgotPasswordResponseFromJson(jsonString);

import 'dart:convert';

List<ForgotPasswordResponse> forgotPasswordResponseFromJson(String str) => List<ForgotPasswordResponse>.from(json.decode(str).map((x) => ForgotPasswordResponse.fromJson(x)));

String forgotPasswordResponseToJson(List<ForgotPasswordResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForgotPasswordResponse {
  String cardno;
  String msgCode;
  String msgDescription;
  String message;

  ForgotPasswordResponse({
    this.cardno,
    this.msgCode,
    this.msgDescription,
    this.message,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) => ForgotPasswordResponse(
    cardno: json["cardno"] == null ? null : json["cardno"],
    msgCode: json["msgCode"] == null ? null : json["msgCode"],
    msgDescription: json["msgDescription"] == null ? null : json["msgDescription"],
    message: json["Message"] == null ? null : json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "cardno": cardno == null ? null : cardno,
    "msgCode": msgCode == null ? null : msgCode,
    "msgDescription": msgDescription == null ? null : msgDescription,
    "Message": message == null ? null : message,
  };
}
