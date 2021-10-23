// To parse this JSON data, do
//
//     final availment = availmentFromJson(jsonString);

import 'dart:convert';

List<Availment> availmentFromJson(String str) => List<Availment>.from(json.decode(str).map((x) => Availment.fromJson(x)));

String availmentToJson(List<Availment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Availment {
  String code;
  String description;

  Availment({
    this.code,
    this.description,
  });

  factory Availment.fromJson(Map<String, dynamic> json) => Availment(
    code: json["code"] == null ? null : json["code"],
    description: json["description"] == null ? null : json["description"],
  );

  Map<String, dynamic> toJson() => {
    "code": code == null ? null : code,
    "description": description == null ? null : description,
  };
}
