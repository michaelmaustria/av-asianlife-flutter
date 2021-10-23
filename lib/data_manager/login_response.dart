// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

List<LoginResponse> loginResponseFromJson(String str) => List<LoginResponse>.from(json.decode(str).map((x) => LoginResponse.fromJson(x)));

String loginResponseToJson(List<LoginResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LoginResponse {
  String cardno;
  String company;
  String status;
  String errorCode;
  String notif;
  String message;
  String msgCode;
  String msgDescription;
  String displaypic;

  LoginResponse({
    this.cardno,
    this.company,
    this.status,
    this.errorCode,
    this.notif,
    this.message,
    this.msgCode,
    this.msgDescription,
    this.displaypic
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    cardno: json["cardno"] == null ? null : json["cardno"],
    company: json["company"] == null ? null : json["company"],
    status: json["status"] == null ? null : json["status"],
    errorCode: json["errorCode"] == null ? null : json["errorCode"],
    notif: json["notif"] == null ? null : json["notif"],
    message: json["Message"] == null ? null : json["Message"],
    msgCode: json["msgCode"] == null ? null : json["msgCode"],
    msgDescription: json["msgDescription"] == null ? null : json["msgDescription"],
    displaypic: json["displaypic"] == null ? null : json["displaypic"],
  );

  Map<String, dynamic> toJson() => {
    "cardno": cardno == null ? null : cardno,
    "company": company == null ? null : company,
    "status": status == null ? null : status,
    "errorCode": errorCode == null ? null : errorCode,
    "notif": notif == null ? null : notif,
    "Message": message == null ? null : message,
    "msgCode": msgCode == null ? null : msgCode,
    "msgDescription": msgDescription == null ? null : msgDescription,
    "displaypic": displaypic == null ? null : displaypic,
  };
}
