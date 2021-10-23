// To parse this JSON data, do
//
//     final city = cityFromJson(jsonString);

import 'dart:convert';

List<City> cityFromJson(String str) => new List<City>.from(json.decode(str).map((x) => City.fromJson(x)));

String cityToJson(List<City> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class City {
  String city;

  City({
    this.city,
  });

  factory City.fromJson(Map<String, dynamic> json) => new City(
    city: json["City"] == null ? null : json["City"],
  );

  Map<String, dynamic> toJson() => {
    "City": city == null ? null : city,
  };
}
