import 'dart:io';

class ClaimRequest{
  String appUserId;
  String cardNo;
  String claimAmount;
  String availmentDate;
  String complaints;
  String remarksConsult;
  String remarksLab;
  String remarksMed;
  String diagnosis;
  String fundTransfer;
  String bnkCode;
  String acctNo;
  String acctName;
  String acctAddress;
  String resideWithEnsured;
  String isEmployed;
  String employer;
  String patientDesignation;
  String symptomNoticed;
  String consultedDoc;
  String consultedDocDate;
  String findings;
  String physicianName;
  String physicianAddress;
  String dueToInjury;
  String whenWhereHappened;
  String injuryWhatHappened;
  String injuryHowHappened;
  String withOtherInsurance;
  String insuranceCompany;
  String hospCode;
  String attendingPhysician;
  String otherHosp;
  String insuredHospitalized;
  String amountLab;
  String amountMed;
  List<File> doctorStatementList;
  List<File> attachments;
  List<File> claimForm;
  List<File> chargeSlipList;
  List<File> officialReceiptList;

  ClaimRequest({
    this.appUserId,
    this.cardNo,
    this.claimAmount,
    this.availmentDate,
    this.complaints,
    this.remarksConsult,
    this.remarksLab,
    this.remarksMed,
    this.diagnosis,
    this.fundTransfer,
    this.bnkCode,
    this.acctNo,
    this.acctName,
    this.acctAddress,
    this.attachments,
    this.resideWithEnsured,
    this.isEmployed,
    this.employer,
    this.patientDesignation,
    this.symptomNoticed,
    this.consultedDoc,
    this.consultedDocDate,
    this.findings,
    this.physicianName,
    this.physicianAddress,
    this.dueToInjury,
    this.whenWhereHappened,
    this.injuryWhatHappened,
    this.injuryHowHappened,
    this.withOtherInsurance,
    this.insuranceCompany,
    this.hospCode,
    this.attendingPhysician,
    this.otherHosp,
    this.insuredHospitalized,
    this.amountLab,
    this.amountMed,
    this.claimForm,
    this.doctorStatementList,
    this.chargeSlipList,
    this.officialReceiptList
  });
}