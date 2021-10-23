// To parse this JSON data, do
//
//     final member = memberFromJson(jsonString);

import 'dart:convert';

List<Member> memberFromJson(String str) => List<Member>.from(json.decode(str).map((x) => Member.fromJson(x)));

String memberToJson(List<Member> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Member {
  String cardno;
  String lastName;
  String firstName;
  String midname;
  String dob;
  String gender;
  String reldesc;
  String coverstartdt;
  String coverenddt;
  String qrcode;
  String policyholder;
  String roomnboard;
  String limit;
  String status;
  String email;
  String mobileno;
  String message;
  String displaypic;

  Member({
    this.cardno,
    this.lastName,
    this.firstName,
    this.midname,
    this.dob,
    this.gender,
    this.reldesc,
    this.coverstartdt,
    this.coverenddt,
    this.qrcode,
    this.policyholder,
    this.roomnboard,
    this.limit,
    this.status,
    this.email,
    this.mobileno,
    this.message,
    this.displaypic,
  });

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    cardno: json["cardno"] == null ? null : json["cardno"],
    lastName: json["last_name"] == null ? null : json["last_name"],
    firstName: json["first_name"] == null ? null : json["first_name"],
    midname: json["midname"] == null ? null : json["midname"],
    dob: json["dob"] == null ? null : json["dob"],
    gender: json["gender"] == null ? null : json["gender"],
    reldesc: json["reldesc"] == null ? null : json["reldesc"],
    coverstartdt: json["coverstartdt"] == null ? null : json["coverstartdt"],
    coverenddt: json["coverenddt"] == null ? null : json["coverenddt"],
    qrcode: json["qrcode"] == null ? null : json["qrcode"],
    policyholder: json["policyholder"] == null ? null : json["policyholder"],
    roomnboard: json["roomnboard"] == null ? null : json["roomnboard"],
    limit: json["limit"] == null ? null : json["limit"],
    status: json["status"] == null ? null : json["status"],
    email: json["email"] == null ? null : json["email"],
    mobileno: json["mobileno"] == null ? null : json["mobileno"],
    message: json["message"] == null ? null : json["message"],
    displaypic: json["displaypic"] == null ? null : json["displaypic"],
  );

  Map<String, dynamic> toJson() => {
    "cardno": cardno == null ? null : cardno,
    "last_name": lastName == null ? null : lastName,
    "first_name": firstName == null ? null : firstName,
    "midname": midname == null ? null : midname,
    "dob": dob == null ? null : dob,
    "gender": gender == null ? null : gender,
    "reldesc": reldesc == null ? null : reldesc,
    "coverstartdt": coverstartdt == null ? null : coverstartdt,
    "coverenddt": coverenddt == null ? null : coverenddt,
    "qrcode": qrcode == null ? null : qrcode,
    "policyholder": policyholder == null ? null : policyholder,
    "roomnboard": roomnboard == null ? null : roomnboard,
    "limit": limit == null ? null : limit,
    "status": status == null ? null : status,
    "email": email == null ? null : email,
    "mobileno": mobileno == null ? null : mobileno,
    "message": message == null ? null : message,
    "displaypic": displaypic == null ? null : displaypic,
  };
}
