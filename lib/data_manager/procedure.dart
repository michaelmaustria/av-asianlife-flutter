// To parse this JSON data, do
//
//     final procedure = procedureFromJson(jsonString);

import 'dart:convert';

List<Procedure> procedureFromJson(String str) => List<Procedure>.from(json.decode(str).map((x) => Procedure.fromJson(x)));

String procedureToJson(List<Procedure> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Procedure {
  String procCode;
  String procDesc;

  Procedure({
    this.procCode,
    this.procDesc,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) => Procedure(
    procCode: json["proccode"] == null ? null : json["proccode"],
    procDesc: json["procdesc"] == null ? null : json["procdesc"],
  );

  Map<String, dynamic> toJson() => {
    "proccode": procCode == null ? null : procCode,
    "procdesc": procDesc == null ? null : procDesc,
  };
}
