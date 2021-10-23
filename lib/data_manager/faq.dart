// To parse this JSON data, do
//
//     final requests = requestsFromJson(jsonString);

import 'dart:convert';

List<Faq> requestsFromJson(String str) => List<Faq>.from(json.decode(str).map((x) => Faq.fromJson(x)));

String requestsToJson(List<Faq> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Faq {
  String faqId;
  String faqTitle;
  String faqBody;

  Faq({
    this.faqId,
    this.faqTitle,
    this.faqBody,
  });

  factory Faq.fromJson(Map<String, dynamic> json) => Faq(
    faqId: json["FaqID"] == null ? null : json["FaqID"],
    faqTitle: json["FaqTitle"] == null ? null : json["FaqTitle"],
    faqBody: json["FaqBody"] == null ? null : json["FaqBody"],
  );

  Map<String, dynamic> toJson() => {
    "FaqID": faqId == null ? null : faqId,
    "FaqTitle": faqTitle == null ? null : faqTitle,
    "FaqBody": faqBody == null ? null : faqBody,
  };
}
