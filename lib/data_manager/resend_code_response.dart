// To parse this JSON data, do
//
//     final resendCodedResponse = resendCodedResponseFromJson(jsonString);

import 'dart:convert';

List<ResendCodeResponse> resendCodedResponseFromJson(String str) => List<ResendCodeResponse>.from(json.decode(str).map((x) => ResendCodeResponse.fromJson(x)));

String resendCodedResponseToJson(List<ResendCodeResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResendCodeResponse {
  String cardno;
  String message;

  ResendCodeResponse({
    this.cardno,
    this.message,
  });

  factory ResendCodeResponse.fromJson(Map<String, dynamic> json) => ResendCodeResponse(
    cardno: json["cardno"] == null ? null : json["cardno"],
    message: json["Message"] == null ? null : json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "cardno": cardno == null ? null : cardno,
    "Message": message == null ? null : message,
  };
}
