// To parse this JSON data, do
//
//     final claims = claimsFromJson(jsonString);

import 'dart:convert';

List<Claims> claimsFromJson(String str) => List<Claims>.from(json.decode(str).map((x) => Claims.fromJson(x)));

String claimsToJson(List<Claims> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Claims {
  String reqId;
  String patientName;
  String hospitalName;
  DateTime dateRequested;
  String status;

  Claims({
    this.reqId,
    this.patientName,
    this.hospitalName,
    this.dateRequested,
    this.status,
  });

  factory Claims.fromJson(Map<String, dynamic> json) => Claims(
    reqId: json["ReqID"] == null ? null : json["ReqID"],
    patientName: json["PatientName"] == null ? null : json["PatientName"],
    hospitalName: json["HospitalName"] == null ? null : json["HospitalName"],
    dateRequested: json["DateRequested"] == null ? null : DateTime.parse(json["DateRequested"]),
    status: json["Status"] == null ? null : json["Status"],
  );

  Map<String, dynamic> toJson() => {
    "ReqID": reqId == null ? null : reqId,
    "PatientName": patientName == null ? null : patientName,
    "HospitalName": hospitalName == null ? null : hospitalName,
    "DateRequested": dateRequested == null ? null : dateRequested.toIso8601String(),
    "Status": status == null ? null : status,
  };
}
