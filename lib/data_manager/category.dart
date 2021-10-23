// To parse this JSON data, do
//
//     final category = categoryFromJson(jsonString);

import 'dart:convert';

List<Category> categoryFromJson(String str) => new List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) => json.encode(new List<Category>.from(data.map((x) => x.toJson())));

class Category {
  String code;
  String description;

  Category({
    this.code,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) => new Category(
    code: json["code"] == null ? null : json["code"],
    description: json["description"] == null ? null : json["description"],
  );

  Map<String, dynamic> toJson() => {
    "code": code == null ? null : code,
    "description": description == null ? null : description,
  };
}
