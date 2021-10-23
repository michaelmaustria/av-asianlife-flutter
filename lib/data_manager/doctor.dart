// To parse this JSON data, do
//
//     final doctor = doctorFromJson(jsonString);

import 'dart:convert';

List<Doctor> doctorFromJson(String str) => List<Doctor>.from(json.decode(str).map((x) => Doctor.fromJson(x)));

String doctorToJson(List<Doctor> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Doctor {
  String docId;
  String doctor;
  String specialty;
  String schedule;
  String hospitalName;
  String address;
  String province;
  String city;
  String contactNumber;
  double latitude;
  double longitude;
  String distance;

  Doctor({
    this.docId,
    this.doctor,
    this.specialty,
    this.schedule,
    this.hospitalName,
    this.address,
    this.province,
    this.city,
    this.contactNumber,
    this.latitude,
    this.longitude,
    this.distance,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    docId: json["DocID"] == null ? null : json["DocID"],
    doctor: json["Doctor"] == null ? null : json["Doctor"],
    specialty: json["Specialty"] == null ? null : json["Specialty"],
    schedule: json["Schedule"] == null ? null : json["Schedule"],
    hospitalName: json["HospitalName"] == null ? null : json["HospitalName"],
    address: json["Address"] == null ? null : json["Address"],
    province: json["province"] == null ? null : json["province"],
    city: json["city"] == null ? null : json["city"],
    contactNumber: json["ContactNumber"] == null ? null : json["ContactNumber"],
    latitude: json["latitude"] == null ? null : json["latitude"].toDouble(),
    longitude: json["longitude"] == null ? null : json["longitude"].toDouble(),
    distance: json["distance"] == null ? null : json["distance"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "DocID": docId == null ? null : docId,
    "Doctor": doctor == null ? null : doctor,
    "Specialty": specialty == null ? null : specialty,
    "Schedule": schedule == null ? null : schedule,
    "HospitalName": hospitalName == null ? null : hospitalName,
    "Address": address == null ? null : address,
    "province": province == null ? null : province,
    "city": city == null ? null : city,
    "ContactNumber": contactNumber == null ? null : contactNumber,
    "latitude": latitude == null ? null : latitude,
    "longitude": longitude == null ? null : longitude,
    "distance": distance == null ? null : distance,
  };
}
