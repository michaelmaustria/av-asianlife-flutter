// To parse this JSON data, do
//
//     final logResponse = logResponseFromJson(jsonString);

import 'dart:convert';

List<LogResponse> logResponseFromJson(String str) => List<LogResponse>.from(json.decode(str).map((x) => LogResponse.fromJson(x)));

String logResponseToJson(List<LogResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LogResponse {
  String msgCode;
  String msgDescription;
  String message;

  LogResponse({
    this.msgCode,
    this.msgDescription,
    this.message,
  });

  factory LogResponse.fromJson(Map<String, dynamic> json) => LogResponse(
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
