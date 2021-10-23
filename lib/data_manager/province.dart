// To parse this JSON data, do
//
//     final province = provinceFromJson(jsonString);

import 'dart:convert';

List<Province> provinceFromJson(String str) => new List<Province>.from(json.decode(str).map((x) => Province.fromJson(x)));

String provinceToJson(List<Province> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Province {
  String province;

  Province({
    this.province,
  });

  factory Province.fromJson(Map<String, dynamic> json) => new Province(
    province: json["Province"] == null ? null : json["Province"],
  );

  Map<String, dynamic> toJson() => {
    "Province": province == null ? null : province,
  };
}
