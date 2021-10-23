// To parse this JSON data, do
//
//     final provider = providerFromJson(jsonString);

import 'dart:convert';

List<Provider> providerFromJson(String str) => new List<Provider>.from(json.decode(str).map((x) => Provider.fromJson(x)));

String providerToJson(List<Provider> data) => json.encode(new List<dynamic>.from(data.map((x) => x.toJson())));

class Provider {
  String hospitalId;
  String hospitalName;
  String address;
  String province;
  String city;
  String contactNumber;
  int isHospital;
  double latitude;
  double longitude;
  String distance;

  Provider({
    this.hospitalId,
    this.hospitalName,
    this.address,
    this.province,
    this.city,
    this.contactNumber,
    this.isHospital,
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory Provider.fromJson(Map<String, dynamic> json) => new Provider(
    hospitalId: json["HospitalID"] == null ? null : json["HospitalID"],
    hospitalName: json["HospitalName"] == null ? null : json["HospitalName"],
    address: json["Address"] == null ? null : json["Address"],
    province: json["Province"] == null ? null : json["Province"],
    city: json["City"] == null ? null : json["City"],
    contactNumber: json["ContactNumber"] == null ? null : json["ContactNumber"],
    isHospital: json["isHospital"] == null ? null : json["isHospital"],
    latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
    longitude: json["longitude"] == null ? null : json["longitude"].toDouble(),
    distance: json["distance"] == null ? null : json["distance"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "HospitalID": hospitalId == null ? null : hospitalId,
    "HospitalName": hospitalName == null ? null : hospitalName,
    "Address": address == null ? null : address,
    "Province": province == null ? null : province,
    "City": city == null ? null : city,
    "ContactNumber": contactNumber == null ? null : contactNumber,
    "isHospital": isHospital == null ? null : isHospital,
    "latitude": latitude == null ? null : latitude,
    "longitude": longitude == null ? null : longitude,
    "distance": distance == null ? null : distance,
  };
}
