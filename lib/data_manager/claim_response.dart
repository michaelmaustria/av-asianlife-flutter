// To parse this JSON data, do
//
//     final logResponse = logResponseFromJson(jsonString);

import 'dart:convert';

List<ClaimResponse> claimResponseFromJson(String str) => List<ClaimResponse>.from(json.decode(str).map((x) => ClaimResponse.fromJson(x)));

String claimResponseToJson(List<ClaimResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClaimResponse {
  String msgCode;
  String msgDescription;

  ClaimResponse({
    this.msgCode,
    this.msgDescription,
  });

  factory ClaimResponse.fromJson(Map<String, dynamic> json) => ClaimResponse(
    msgCode: json["msgCode"] == null ? null : json["msgCode"],
    msgDescription: json["msgDescription"] == null ? null : json["msgDescription"],
  );

  Map<String, dynamic> toJson() => {
    "msgCode": msgCode == null ? null : msgCode,
    "msgDescription": msgDescription == null ? null : msgDescription,
  };
}
