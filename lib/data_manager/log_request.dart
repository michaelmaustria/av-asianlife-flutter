
import 'dart:io';

class LogRequest {
  String apiUser;
  String apiPass;
  String username;
  String cardNo;
  String availType;
  String availDate;
  String providerCode;
  String patient;
  String complaint;
  List<String> procedures;
  String contactNo;
  String doctors;
  List<File> attachments;

  LogRequest({this.apiUser, this.apiPass, this.username, this.cardNo, this.availType,
      this.availDate, this.providerCode, this.patient, this.complaint, this.procedures,
      this.contactNo, this.doctors, this.attachments});


}