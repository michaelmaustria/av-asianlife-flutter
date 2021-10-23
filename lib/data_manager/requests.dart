// To parse this JSON data, do
//
//     final requests = requestsFromJson(jsonString);

import 'dart:convert';

List<Requests> requestsFromJson(String str) => List<Requests>.from(json.decode(str).map((x) => Requests.fromJson(x)));

String requestsToJson(List<Requests> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Requests {
  String reqId;
  DateTime dateRequested;
  String hospitalName;
  String patientName;
  String approvalCode;
  String status;

  Requests({
    this.reqId,
    this.dateRequested,
    this.hospitalName,
    this.patientName,
    this.approvalCode,
    this.status,
  });

  factory Requests.fromJson(Map<String, dynamic> json) => Requests(
    reqId: json["ReqID"] == null ? null : json["ReqID"],
    dateRequested: json["DateRequested"] == null ? null : DateTime.parse(json["DateRequested"]),
    hospitalName: json["HospitalName"] == null ? null : json["HospitalName"],
    patientName: json["PatientName"] == null ? null : json["PatientName"],
    approvalCode: json["ApprovalCode"] == null ? null : json["ApprovalCode"],
    status: json["Status"] == null ? null : json["Status"],
  );

  Map<String, dynamic> toJson() => {
    "ReqID": reqId == null ? null : reqId,
    "DateRequested": dateRequested == null ? null : dateRequested.toIso8601String(),
    "HospitalName": hospitalName == null ? null : hospitalName,
    "PatientName": patientName == null ? null : patientName,
    "ApprovalCode": approvalCode == null ? null : approvalCode,
    "Status": status == null ? null : status,
  };
}
