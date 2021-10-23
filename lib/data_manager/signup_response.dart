// To parse this JSON data, do
//
//     final signUpResponse = signUpResponseFromJson(jsonString);

import 'dart:convert';

List<SignUpResponse> signUpResponseFromJson(String str) => List<SignUpResponse>.from(json.decode(str).map((x) => SignUpResponse.fromJson(x)));

String signUpResponseToJson(List<SignUpResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SignUpResponse {
  String cardno;
  String msgCode;
  String msgDescription;
  String message;

  SignUpResponse({
    this.cardno,
    this.msgCode,
    this.msgDescription,
    this.message,
  });

  factory SignUpResponse.fromJson(Map<String, dynamic> json) => SignUpResponse(
    cardno: json["CARDNO"] == null ? null : json["CARDNO"],
    msgCode: json["msgCode"] == null ? null : json["msgCode"],
    msgDescription: json["msgDescription"] == null ? null : json["msgDescription"],
    message: json["Message"] == null ? null : json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "CARDNO": cardno == null ? null : cardno,
    "msgCode": msgCode == null ? null : msgCode,
    "msgDescription": msgDescription == null ? null : msgDescription,
    "Message": message == null ? null : message,
  };
}
