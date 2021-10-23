// To parse this JSON data, do
//
//     final chooseWhereToSendCodeResponse = chooseWhereToSendCodeResponseFromJson(jsonString);

import 'dart:convert';

List<ChooseWhereToSendCodeResponse> chooseWhereToSendCodeResponseFromJson(String str) => List<ChooseWhereToSendCodeResponse>.from(json.decode(str).map((x) => ChooseWhereToSendCodeResponse.fromJson(x)));

String chooseWhereToSendCodeResponseToJson(List<ChooseWhereToSendCodeResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChooseWhereToSendCodeResponse {
  String email;
  String mobileno;
  String message;

  ChooseWhereToSendCodeResponse({
    this.email,
    this.mobileno,
    this.message,
  });

  factory ChooseWhereToSendCodeResponse.fromJson(Map<String, dynamic> json) => ChooseWhereToSendCodeResponse(
    email: json["email"] == null ? null : json["email"],
    mobileno: json["mobileno"] == null ? null : json["mobileno"],
    message: json["Message"] == null ? null : json["Message"],
  );

  Map<String, dynamic> toJson() => {
    "email": email == null ? null : email,
    "mobileno": mobileno == null ? null : mobileno,
    "Message": message == null ? null : message,
  };
}
