// To parse this JSON data, do
//
//     final principalInfo = principalInfoFromJson(jsonString);

import 'dart:convert';

List<PrincipalInfo> principalInfoFromJson(String str) => List<PrincipalInfo>.from(json.decode(str).map((x) => PrincipalInfo.fromJson(x)));

String principalInfoToJson(List<PrincipalInfo> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PrincipalInfo {
  String certificateno;
  String employeename;
  String age;
  String gender;
  String civilstatus;
  String email;
  String mobileno;
  String policyholder;
  String message;

  PrincipalInfo({
    this.certificateno,
    this.employeename,
    this.age,
    this.gender,
    this.civilstatus,
    this.email,
    this.mobileno,
    this.policyholder,
    this.message
  });

  factory PrincipalInfo.fromJson(Map<String, dynamic> json) => PrincipalInfo(
    certificateno: json["certificateno"] == null ? null : json["certificateno"],
    employeename: json["employeename"] == null ? null : json["employeename"],
    age: json["age"] == null ? null : json["age"].toString(),
    gender: json["gender"] == null ? null : json["gender"],
    civilstatus: json["civilstatus"] == null ? null : json["civilstatus"],
    email: json["email"] == null ? null : json["email"],
    mobileno: json["mobileno"] == null ? null : json["mobileno"],
    policyholder: json["policyholder"] == null ? null : json["policyholder"],
    message: json["message"] == null ? null : json["message"],
  );

  Map<String, dynamic> toJson() => {
    "certificateno": certificateno == null ? null : certificateno,
    "employeename": employeename == null ? null : employeename,
    "age": age == null ? null : age,
    "gender": gender == null ? null : gender,
    "civilstatus": civilstatus == null ? null : civilstatus,
    "email": email == null ? null : email,
    "mobileno": mobileno == null ? null : mobileno,
    "policyholder": policyholder == null ? null : policyholder,
    "message": message == null ? null : message,
  };
}
