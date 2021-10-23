// To parse this JSON data, do
//
//     final specialty = specialtyFromJson(jsonString);

import 'dart:convert';

List<Specialization> specialtyFromJson(String str) => List<Specialization>.from(json.decode(str).map((x) => Specialization.fromJson(x)));

String specialtyToJson(List<Specialization> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Specialization {
  String specialty;

  Specialization({
    this.specialty,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) => Specialization(
    specialty: json["Specialty"] == null ? null : json["Specialty"],
  );

  Map<String, dynamic> toJson() => {
    "Specialty": specialty == null ? null : specialty,
  };
}
